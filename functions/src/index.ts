import { setGlobalOptions } from "firebase-functions";
import { onValueCreated } from "firebase-functions/v2/database";
import { initializeApp } from "firebase-admin/app";
import { getDatabase } from "firebase-admin/database";
import { getMessaging } from "firebase-admin/messaging";
import { getAuth } from "firebase-admin/auth";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";

initializeApp();

setGlobalOptions({
  maxInstances: 10,
});

// =====================================================
// WhatsApp Business API
// =====================================================

// لا تضع التوكن داخل الكود.
// سيتم تخزينه كـ Secret في Firebase.
const WHATSAPP_TOKEN =
  defineSecret("WHATSAPP_TOKEN");

const WHATSAPP_PHONE_NUMBER_ID =
  defineSecret("WHATSAPP_PHONE_NUMBER_ID");

// =====================================================
// إرسال إشعار حقيقي إلى هاتف مسؤول المحطة
// عند إنشاء إشعار جديد في Realtime Database
// =====================================================

export const sendStationNotification = onValueCreated(
  {
    ref: "/notifications/{notificationId}",
  },
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
      notification.title ??
      "نافذة المنتوج النفطي";

    const message =
      notification.message ??
      "";

    const type =
      notification.type ??
      "station";

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
            channelId:
              "oil_product_notifications",
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

      await getDatabase()
        .ref(
          `notifications/${event.params.notificationId}`
        )
        .update({
          pushSent: true,
          pushSentAt:
            new Date().toISOString(),
        });

    } catch (error) {

      console.error(
        "فشل إرسال الإشعار:",
        error
      );

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

// =====================================================
// إرسال WhatsApp تلقائي
//
// أي رسالة جديدة في:
// /whatsappMessages/{messageId}
//
// سيتم إرسالها تلقائيًا إلى WhatsApp
// =====================================================

export const sendWhatsAppMessage = onValueCreated(
  {
    ref: "/whatsappMessages/{messageId}",
    secrets: [
      WHATSAPP_TOKEN,
      WHATSAPP_PHONE_NUMBER_ID,
    ],
  },

  async (event) => {

    const data = event.data.val();

    if (!data) {
      console.log(
        "لا توجد بيانات لرسالة WhatsApp"
      );
      return;
    }

    const phone =
      data.phone?.toString().trim();

    const message =
      data.message?.toString().trim();

    if (!phone) {
      console.log(
        "رسالة WhatsApp لا تحتوي على رقم هاتف"
      );

      await event.data.ref.update({
        sent: false,
        error: "رقم الهاتف غير موجود",
      });

      return;
    }

    if (!message) {
      console.log(
        "رسالة WhatsApp لا تحتوي على نص"
      );

      await event.data.ref.update({
        sent: false,
        error: "نص الرسالة غير موجود",
      });

      return;
    }

    // =================================================
    // تنظيف رقم الهاتف
    // =================================================

    let whatsappPhone = phone
      .replace(/\s/g, "")
      .replace(/-/g, "")
      .replace(/\(/g, "")
      .replace(/\)/g, "");

    // 078xxxxxxxx
    // يصبح 96478xxxxxxxx

    if (whatsappPhone.startsWith("0")) {
      whatsappPhone =
        "964" +
        whatsappPhone.substring(1);
    }

    // +96478xxxxxxxx
    if (whatsappPhone.startsWith("+")) {
      whatsappPhone =
        whatsappPhone.substring(1);
    }

    // =================================================
    // بيانات Meta WhatsApp
    // =================================================

    const token =
      WHATSAPP_TOKEN.value();

    const phoneNumberId =
      WHATSAPP_PHONE_NUMBER_ID.value();

    if (!token || !phoneNumberId) {

      console.error(
        "WhatsApp Secrets غير موجودة"
      );

      await event.data.ref.update({
        sent: false,
        error:
          "WhatsApp API غير مهيأ",
      });

      return;
    }

    // =================================================
    // إرسال الرسالة
    // =================================================

    try {

      const response =
        await fetch(
          `https://graph.facebook.com/v23.0/${phoneNumberId}/messages`,
          {
            method: "POST",

            headers: {
              "Authorization":
                `Bearer ${token}`,

              "Content-Type":
                "application/json",
            },

            body: JSON.stringify({
              messaging_product:
                "whatsapp",

              recipient_type:
                "individual",

              to: whatsappPhone,

              type: "text",

              text: {
                preview_url: false,
                body: message,
              },
            }),
          }
        );

      const result =
        await response.json();

      if (!response.ok) {

        console.error(
          "فشل إرسال WhatsApp:",
          result
        );

        await event.data.ref.update({
          sent: false,
          sentAt:
            new Date().toISOString(),
          error:
            JSON.stringify(result),
        });

        return;
      }

      console.log(
        "تم إرسال WhatsApp بنجاح:",
        result
      );

      await event.data.ref.update({
        sent: true,

        sentAt:
          new Date().toISOString(),

        messageId:
          result.messages?.[0]?.id ??
          null,
      });

    } catch (error) {

      console.error(
        "خطأ أثناء إرسال WhatsApp:",
        error
      );

      await event.data.ref.update({
        sent: false,

        sentAt:
          new Date().toISOString(),

        error:
          String(error),
      });
    }
  }
);
export const deleteBranchManagerAuth = onCall(async (request) => {
  const callerUid = request.auth?.uid;

  if (!callerUid) {
    throw new HttpsError(
      "unauthenticated",
      "يجب تسجيل الدخول أولاً."
    );
  }

  const callerSnapshot = await getDatabase()
    .ref(`users/${callerUid}`)
    .get();

  if (!callerSnapshot.exists()) {
    throw new HttpsError(
      "permission-denied",
      "المستخدم غير موجود."
    );
  }

  const callerData = callerSnapshot.val();

  if (callerData?.role !== "admin") {
    throw new HttpsError(
      "permission-denied",
      "هذه العملية متاحة لمدير النظام فقط."
    );
  }

  const managerUid =
    String(request.data?.managerUid ?? "").trim();

  if (!managerUid) {
    throw new HttpsError(
      "invalid-argument",
      "managerUid مطلوب."
    );
  }

  if (managerUid === callerUid) {
    throw new HttpsError(
      "failed-precondition",
      "لا يمكن حذف حساب مدير النظام."
    );
  }

  try {
    await getAuth().deleteUser(managerUid);

    return {
      success: true,
      deletedUid: managerUid,
    };
  } catch (error: any) {
    if (error?.code === "auth/user-not-found") {
      return {
        success: true,
        deletedUid: managerUid,
        alreadyDeleted: true,
      };
    }

    console.error(
      "Failed to delete branch manager:",
      error
    );

    throw new HttpsError(
      "internal",
      "تعذر حذف حساب مدير الفرع."
    );
  }
});