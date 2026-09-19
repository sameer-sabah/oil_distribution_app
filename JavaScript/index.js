const { setGlobalOptions } = require("firebase-functions");
const {
  onValueCreated,
  onValueUpdated,
} = require("firebase-functions/v2/database");
const { onCall, HttpsError } =
  require("firebase-functions/v2/https");

const { initializeApp } =
  require("firebase-admin/app");

const { getDatabase } =
  require("firebase-admin/database");

const { getMessaging } =
  require("firebase-admin/messaging");

const logger =
  require("firebase-functions/logger");

initializeApp();

setGlobalOptions({
  maxInstances: 10,
});

/*
========================================================
إرسال إشعار إلى مستخدم محدد
========================================================
*/
async function sendNotificationToUser({
  uid,
  title,
  body,
  type,
  data = {},
}) {
  if (!uid || !uid.trim()) {
    logger.warn("UID غير موجود");
    return false;
  }

  const db = getDatabase();

  const userSnapshot =
    await db.ref(`users/${uid}`).get();

  if (!userSnapshot.exists()) {
    logger.warn(`المستخدم غير موجود: ${uid}`);
    return false;
  }

  const user = userSnapshot.val() || {};

  const token =
    user.fcmToken?.toString().trim();

  if (!token) {
    logger.warn(
      `لا يوجد FCM Token للمستخدم ${uid}`
    );
    return false;
  }

  /*
  حفظ الإشعار داخل قاعدة البيانات
  */
  const notificationRef =
    db
      .ref(`notifications/users/${uid}`)
      .push();

  await notificationRef.set({
    id: notificationRef.key,
    userId: uid,
    title: title,
    body: body,
    type: type,
    data: data,
    createdAt: new Date().toISOString(),
    read: false,
  });

  /*
  إرسال Push Notification عبر FCM
  */
  const message = {
    token: token,

    notification: {
      title: title,
      body: body,
    },

    data: {
      type: String(type ?? ""),
      title: String(title ?? ""),
      body: String(body ?? ""),
      ...Object.fromEntries(
        Object.entries(data).map(
          ([key, value]) => [
            key,
            String(value ?? ""),
          ]
        )
      ),
    },

    android: {
      priority: "high",

      notification: {
        sound: "default",
        channelId:
          "oil_distribution_channel",
      },
    },
  };

  try {
    const response =
      await getMessaging().send(message);

    logger.info(
      `تم إرسال الإشعار إلى المستخدم ${uid}`,
      {
        response: response,
      }
    );

    return true;

  } catch (error) {

    logger.error(
      `فشل إرسال الإشعار إلى ${uid}`,
      error
    );

    return false;
  }
}


/*
========================================================
1
طلب تسجيل محطة جديد
pendingStations/{requestId}

إرسال إشعار إلى مدير الفرع
الذي branchId الخاص به يطابق الطلب
========================================================
*/

exports.notifyBranchManagerNewStation =
  onValueCreated(
    "/pendingStations/{requestId}",
    async (event) => {

      const request =
        event.data.val();

      if (!request) {
        return;
      }

      const branchId =
        request.branchId
          ?.toString()
          .trim();

      if (!branchId) {

        logger.warn(
          "طلب المحطة لا يحتوي branchId"
        );

        return;
      }

      const db =
        getDatabase();

      const usersSnapshot =
        await db.ref("users").get();

      if (!usersSnapshot.exists()) {
        return;
      }

      const users =
        usersSnapshot.val() || {};

      for (
        const [uid, user]
        of Object.entries(users)
      ) {

        if (!user) {
          continue;
        }

        const role =
          user.role?.toString();

        const userBranchId =
          user.branchId
            ?.toString()
            .trim();

        if (
          role === "branchManager" &&
          userBranchId === branchId
        ) {

          await sendNotificationToUser({

            uid: uid,

            title:
              "طلب تسجيل محطة جديد",

            body:
              `لديك طلب تسجيل محطة جديد: ${
                request.name ?? "محطة جديدة"
              }`,

            type:
              "new_station_registration",

            data: {

              requestId:
                event.params.requestId,

              stationName:
                request.name ?? "",

              branchId:
                branchId,
            },
          });
        }
      }
    }
  );


/*
========================================================
2
إنشاء محطة جديدة مع managerUid

stations/{stationId}

إرسال إشعار إلى مدير المحطة
========================================================
*/

exports.notifyStationManagerApproved =
  onValueCreated(
    "/stations/{stationId}",
    async (event) => {

      const station =
        event.data.val();

      if (!station) {
        return;
      }

      const managerUid =
        station.managerUid
          ?.toString()
          .trim();

      if (!managerUid) {

        logger.info(
          `المحطة ${event.params.stationId} لا تحتوي managerUid`
        );

        return;
      }

      await sendNotificationToUser({

        uid: managerUid,

        title:
          "تم اعتماد المحطة",

        body:
          `تمت الموافقة على تسجيل ${
            station.name ?? "المحطة"
          } بنجاح.`,

        type:
          "station_approved",

        data: {

          stationId:
            event.params.stationId,

          stationName:
            station.name ?? "",

          branchId:
            station.branchId ?? "",
        },
      });
    }
  );


/*
========================================================
3
رفض طلب تسجيل محطة

يعمل فقط إذا كان الطلب يحتوي requesterUid

pendingStations/{requestId}
========================================================
*/

exports.notifyStationRegistrationRejected =
  onValueUpdated(
    "/pendingStations/{requestId}",
    async (event) => {

      const before =
        event.data.before.val();

      const after =
        event.data.after.val();

      if (!after) {
        return;
      }

      const oldStatus =
        before?.status?.toString();

      const newStatus =
        after?.status?.toString();

      if (
        oldStatus === "rejected" ||
        newStatus !== "rejected"
      ) {
        return;
      }

      const requesterUid =
        after.requesterUid
          ?.toString()
          .trim();

      if (!requesterUid) {

        logger.info(
          "الطلب مرفوض ولكن requesterUid غير موجود"
        );

        return;
      }

      const reason =
        after.rejectReason
          ?.toString()
          .trim() ||
        "لم يتم ذكر سبب الرفض";

      await sendNotificationToUser({

        uid: requesterUid,

        title:
          "تم رفض طلب تسجيل المحطة",

        body:
          `تم رفض طلب ${
            after.name ?? "المحطة"
          }. السبب: ${reason}`,

        type:
          "station_registration_rejected",

        data: {

          requestId:
            event.params.requestId,

          stationName:
            after.name ?? "",

          reason:
            reason,
        },
      });
    }
  );


/*
========================================================
4
إرسال إشعار يدوي بين المديرين

مدير النظام ↔ مدير الفرع
مدير الفرع ↔ مدير المحطة
مدير النظام → مدير المحطة
========================================================
*/

exports.sendRoleNotification =
  onCall(
    async (request) => {

      if (!request.auth) {

        throw new HttpsError(
          "unauthenticated",
          "يجب تسجيل الدخول أولاً"
        );
      }

      const senderUid =
        request.auth.uid;

      const data =
        request.data || {};

      const targetUid =
        data.targetUid
          ?.toString()
          .trim();

      const title =
        data.title
          ?.toString()
          .trim();

      const body =
        data.body
          ?.toString()
          .trim();

      if (!targetUid) {

        throw new HttpsError(
          "invalid-argument",
          "targetUid غير موجود"
        );
      }

      if (!title || !body) {

        throw new HttpsError(
          "invalid-argument",
          "العنوان والرسالة مطلوبان"
        );
      }

      const db =
        getDatabase();

      const senderSnapshot =
        await db
          .ref(`users/${senderUid}`)
          .get();

      const targetSnapshot =
        await db
          .ref(`users/${targetUid}`)
          .get();

      if (
        !senderSnapshot.exists() ||
        !targetSnapshot.exists()
      ) {

        throw new HttpsError(
          "not-found",
          "المستخدم غير موجود"
        );
      }

      const sender =
        senderSnapshot.val();

      const target =
        targetSnapshot.val();

      const senderRole =
        sender.role?.toString();

      const targetRole =
        target.role?.toString();

      /*
      مدير النظام ↔ مدير الفرع
      */

      const adminBranchAllowed =
        (
          senderRole === "admin" &&
          targetRole === "branchManager"
        ) ||
        (
          senderRole === "branchManager" &&
          targetRole === "admin"
        );

      /*
      مدير الفرع ↔ مدير المحطة
      يجب أن يكونا في نفس الفرع
      */

      const branchStationAllowed =
        (
          senderRole === "branchManager" &&
          targetRole === "stationManager" &&
          sender.branchId === target.branchId
        ) ||
        (
          senderRole === "stationManager" &&
          targetRole === "branchManager" &&
          sender.branchId === target.branchId
        );

      /*
      مدير النظام → مدير المحطة
      */

      const adminStationAllowed =
        senderRole === "admin" &&
        targetRole === "stationManager";

      if (
        !adminBranchAllowed &&
        !branchStationAllowed &&
        !adminStationAllowed
      ) {

        throw new HttpsError(
          "permission-denied",
          "لا توجد صلاحية لإرسال إشعار لهذا المستخدم"
        );
      }

      const sent =
        await sendNotificationToUser({

          uid: targetUid,

          title: title,

          body: body,

          type:
            "role_notification",

          data: {

            senderUid:
              senderUid,

            senderRole:
              senderRole ?? "",

            targetRole:
              targetRole ?? "",
          },
        });

      if (!sent) {

        throw new HttpsError(
          "failed-precondition",
          "المستخدم لا يملك FCM Token صالح"
        );
      }

      return {
        success: true,
      };
    }
  );
  /*
  ========================================================
  5
  إنشاء طلب تغيير كلمة المرور
  يتم البحث عن المستخدم من جهة الخادم
  حتى لا يحتاج المستخدم غير المسجل إلى قراءة users
  ========================================================
  */

  exports.createPasswordResetRequest = onCall(
    async (request) => {

      const data = request.data || {};

      const username =
        data.username?.toString().trim();

      const verificationPhotoUrl =
        data.verificationPhotoUrl?.toString().trim();

      if (!username) {
        throw new HttpsError(
          "invalid-argument",
          "اسم المستخدم مطلوب"
        );
      }

      if (!verificationPhotoUrl) {
        throw new HttpsError(
          "invalid-argument",
          "صورة المطابقة مطلوبة"
        );
      }

      const db = getDatabase();

      /*
      البحث عن المستخدم بواسطة اسم المستخدم
      البحث يتم بواسطة Admin SDK من الخادم
      */

      const usersSnapshot =
        await db.ref("users")
          .orderByChild("username")
          .equalTo(username)
          .get();

      if (!usersSnapshot.exists()) {
        throw new HttpsError(
          "not-found",
          "اسم المستخدم غير موجود"
        );
      }

      const users =
        usersSnapshot.val() || {};

      const entries =
        Object.entries(users);

      if (entries.length === 0) {
        throw new HttpsError(
          "not-found",
          "لم يتم العثور على الحساب"
        );
      }

      const [uid, user] =
        entries[0];

      const userData =
        user || {};

      const requestRef =
        db.ref("passwordResetRequests").push();

      const requestId =
        requestRef.key;

      if (!requestId) {
        throw new HttpsError(
          "internal",
          "تعذر إنشاء رقم الطلب"
        );
      }

      /*
      إنشاء الطلب
      */

      await requestRef.set({

        requestId: requestId,

        uid: uid,

        username: username,

        userName:
          userData.fullName?.toString() ||
          username,

        phone:
          userData.phone?.toString() || "",

        branchId:
          userData.branchId?.toString() || "",

        stationId:
          userData.stationId?.toString() || "",

        /*
        الصورة الأصلية المسجلة للحساب
        */

        originalPhotoUrl:
          userData.image?.toString() || "",

        /*
        الصورة الجديدة المرسلة
        */

        verificationPhotoUrl:
          verificationPhotoUrl,

        /*
        حالة الطلب
        */

        status: "pending",

        /*
        لم تبدأ المطابقة بعد
        */

        matchStatus: "waiting",

        matchScore: 0,

        requestedAt:
          new Date().toISOString(),

        processedAt: "",

        processedBy: "",

        rejectReason: "",
      });

      logger.info(
        `تم إنشاء طلب تغيير كلمة المرور: ${requestId}`,
        {
          username: username,
          uid: uid,
        }
      );

      return {
        success: true,
        requestId: requestId,
      };
    }
  );