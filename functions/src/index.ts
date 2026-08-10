import {setGlobalOptions} from "firebase-functions";
import {onValueCreated} from "firebase-functions/v2/database";
import {initializeApp} from "firebase-admin/app";
import {getDatabase} from "firebase-admin/database";
import {getMessaging} from "firebase-admin/messaging";

initializeApp();

setGlobalOptions({
  maxInstances: 10,
});

// =====================================================
// إرسال إشعار حقيقي إلى هاتف مسؤول المحطة
// عند إنشاء إشعار جديد في Realtime Database
// =====================================================

export const sendStationNotification = onValueCreated(
  "/notifications/{notificationId}",
  async (event) => {
    const notification = event.data.val();

    if (!notification) {
      console.log("لا توجد بيانات للإشعار");
      return;
    }

    const userId = notification.userId;

    if (!userId) {
      console.log("الإشعار لا يحتوي على userId");
      return;
    }

    // جلب بيانات المستخدم
    const userSnapshot = await getDatabase()
      .ref(`users/${userId}`)
      .get();

    if (!userSnapshot.exists()) {
      console.log(`المستخدم غير موجود: ${userId}`);
      return;
    }

    const user = userSnapshot.val();

    // FCM Token الخاص بهاتف المستخدم
    const fcmToken = user.fcmToken;

    if (!fcmToken) {
      console.log(
        `لا يوجد FCM Token للمستخدم: ${userId}`
      );
      return;
    }

    const title =
      notification.title ?? "نافذة المنتوج النفطي";

    const message =
      notification.message ?? "";

    const type =
      notification.type ?? "station";

    // =================================================
    // إرسال Push Notification
    // =================================================

    try {
      const response = await getMessaging().send({
        token: fcmToken,

        notification: {
          title: title,
          body: message,
        },

        data: {
          notificationId:
            String(
              notification.id ??
              event.params.notificationId
            ),

          userId: String(userId),

          type: String(type),
        },

        android: {
          priority: "high",

          notification: {
            channelId: "oil_product_notifications",
            sound: "default",
          },
        },

        apns: {
          payload: {
            aps: {
              sound: "default",
            },
          },
        },
      });

      console.log(
        "تم إرسال الإشعار بنجاح:",
        response
      );

      // تسجيل نجاح الإرسال
      await getDatabase()
        .ref(
          `notifications/${event.params.notificationId}`
        )
        .update({
          pushSent: true,
          pushSentAt: new Date().toISOString(),
        });
    } catch (error) {
      console.error(
        "فشل إرسال الإشعار:",
        error
      );

      // تسجيل فشل الإرسال
      await getDatabase()
        .ref(
          `notifications/${event.params.notificationId}`
        )
        .update({
          pushSent: false,
          pushError: String(error),
        });
    }
  }
);
