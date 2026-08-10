const {
  onValueCreated,
} = require("firebase-functions/v2/database");

const {
  initializeApp,
} = require("firebase-admin/app");

const {
  getDatabase,
} = require("firebase-admin/database");

const {
  getMessaging,
} = require("firebase-admin/messaging");


initializeApp();


const db = getDatabase();

const messaging = getMessaging();


// =========================================================
// 1. إشعار خاص بمحطة
//
// المسار الحقيقي عندك:
//
// notifications/{stationId}/{notificationId}
// =========================================================

exports.sendStationNotification =
  onValueCreated(
    {
      ref:
        "/notifications/{stationId}/{notificationId}",

      region:
        "asia-southeast1",
    },

    async (event) => {

      try {

        const notification =
          event.data.val();

        if (!notification) {

          console.log(
            "لا توجد بيانات للإشعار"
          );

          return;
        }


        // -----------------------------------------
        // الحصول على Station ID
        // -----------------------------------------

        const stationId =
          event.params.stationId;


        console.log(
          "Station ID:",
          stationId
        );


        // -----------------------------------------
        // جلب المحطة
        // -----------------------------------------

        const stationSnapshot =
          await db
            .ref(
              `stations/${stationId}`
            )
            .get();


        if (!stationSnapshot.exists()) {

          console.log(
            "المحطة غير موجودة:",
            stationId
          );

          return;
        }


        const station =
          stationSnapshot.val();


        // -----------------------------------------
        // مدير المحطة
        // -----------------------------------------

        const managerUid =
          station.managerUid;


        if (!managerUid) {

          console.log(
            "المحطة لا تحتوي managerUid"
          );

          return;
        }


        console.log(
          "Manager UID:",
          managerUid
        );


        // -----------------------------------------
        // جلب حساب مدير المحطة
        // -----------------------------------------

        const userSnapshot =
          await db
            .ref(
              `users/${managerUid}`
            )
            .get();


        if (!userSnapshot.exists()) {

          console.log(
            "حساب مدير المحطة غير موجود:",
            managerUid
          );

          return;
        }


        const user =
          userSnapshot.val();


        // -----------------------------------------
        // FCM Token
        // -----------------------------------------

        const token =
          user.fcmToken;


        if (!token) {

          console.log(
            "مدير المحطة لا يمتلك FCM Token"
          );

          return;
        }


        // -----------------------------------------
        // عنوان الإشعار
        // -----------------------------------------

        const title =
          notification.title ||
          "نافذة المنتوج النفطي";


        // -----------------------------------------
        // نص الإشعار
        // -----------------------------------------

        const body =
          notification.body ||
          notification.message ||
          "";


        // -----------------------------------------
        // رسالة FCM
        // -----------------------------------------

        const message = {

          token: token,


          notification: {

            title: title,

            body: body,

          },


          data: {

            notificationId:
              event.params.notificationId,

            stationId:
              stationId,

            stationName:
              notification.stationName ||
              station.name ||
              "",

            type:
              "station",

          },


          android: {

            priority:
              "high",


            notification: {

              channelId:
                "oil_distribution_channel",

              sound:
                "default",

              priority:
                "high",

            },

          },

        };


        // -----------------------------------------
        // إرسال الإشعار
        // -----------------------------------------

        const response =
          await messaging.send(
            message
          );


        console.log(
          "تم إرسال إشعار المحطة بنجاح:",
          response
        );


      } catch (error) {


        console.error(
          "خطأ في إرسال إشعار المحطة:",
          error
        );


        // ---------------------------------------
        // حذف Token غير الصالح
        // ---------------------------------------

        if (
          error.code ===
            "messaging/registration-token-not-registered" ||

          error.code ===
            "messaging/invalid-registration-token"
        ) {

          const stationId =
            event.params.stationId;


          const stationSnapshot =
            await db
              .ref(
                `stations/${stationId}`
              )
              .get();


          if (
            stationSnapshot.exists()
          ) {

            const station =
              stationSnapshot.val();


            const managerUid =
              station.managerUid;


            if (managerUid) {

              await db
                .ref(
                  `users/${managerUid}/fcmToken`
                )
                .remove();


              console.log(
                "تم حذف FCM Token غير الصالح"
              );

            }

          }

        }

      }

    }
  );


// =========================================================
// 2. إشعار عام للمواطنين
//
// المسار:
//
// notifications/public/{notificationId}
// =========================================================

exports.sendPublicNotification =
  onValueCreated(
    {
      ref:
        "/notifications/public/{notificationId}",

      region:
        "asia-southeast1",
    },

    async (event) => {

      try {

        const notification =
          event.data.val();


        if (!notification) {

          console.log(
            "لا توجد بيانات للإشعار العام"
          );

          return;
        }


        // -----------------------------------------
        // جلب أجهزة المواطنين
        // -----------------------------------------

        const snapshot =
          await db
            .ref(
              "deviceTokens/citizens"
            )
            .get();


        if (!snapshot.exists()) {

          console.log(
            "لا توجد أجهزة مواطنين"
          );

          return;
        }


        const data =
          snapshot.val();


        const tokens = [];


        // -----------------------------------------
        // استخراج Tokens
        // -----------------------------------------

        for (
          const key in data
        ) {

          const item =
            data[key];


          if (
            item &&
            item.active !== false &&
            item.token
          ) {

            tokens.push(
              item.token
            );

          }

        }


        if (
          tokens.length === 0
        ) {

          console.log(
            "لا توجد FCM Tokens للمواطنين"
          );

          return;
        }


        // -----------------------------------------
        // عنوان الإشعار
        // -----------------------------------------

        const title =
          notification.title ||
          "نافذة المنتوج النفطي";


        // -----------------------------------------
        // النص
        // -----------------------------------------

        const body =
          notification.body ||
          notification.message ||
          "";


        // -----------------------------------------
        // تقسيم إلى مجموعات
        // FCM يسمح بحد أقصى 500 Token
        // -----------------------------------------

        const chunkSize =
          500;


        for (
          let i = 0;

          i < tokens.length;

          i += chunkSize
        ) {

          const chunk =
            tokens.slice(
              i,
              i + chunkSize
            );


          const message = {

            tokens: chunk,


            notification: {

              title: title,

              body: body,

            },


            data: {

              notificationId:
                event.params
                  .notificationId,

              type:
                "public",

            },


            android: {

              priority:
                "high",


              notification: {

                channelId:
                  "oil_distribution_channel",

                sound:
                  "default",

                priority:
                  "high",

              },

            },

          };


          const response =
            await messaging
              .sendEachForMulticast(
                message
              );


          console.log(
            `تم إرسال ${response.successCount} إشعار للمواطنين`
          );


          console.log(
            `فشل ${response.failureCount} إشعار`
          );

        }


      } catch (error) {

        console.error(
          "خطأ في إرسال الإشعار العام:",
          error
        );

      }

    }
  );