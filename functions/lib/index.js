"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteBranchManagerAuth = exports.sendWhatsAppMessage = exports.sendStationNotification = void 0;
const firebase_functions_1 = require("firebase-functions");
const database_1 = require("firebase-functions/v2/database");
const app_1 = require("firebase-admin/app");
const database_2 = require("firebase-admin/database");
const messaging_1 = require("firebase-admin/messaging");
const auth_1 = require("firebase-admin/auth");
const https_1 = require("firebase-functions/v2/https");
const params_1 = require("firebase-functions/params");
(0, app_1.initializeApp)();
(0, firebase_functions_1.setGlobalOptions)({
    maxInstances: 10,
});
// =====================================================
// WhatsApp Business API
// =====================================================
// لا تضع التوكن داخل الكود.
// سيتم تخزينه كـ Secret في Firebase.
const WHATSAPP_TOKEN = (0, params_1.defineSecret)("WHATSAPP_TOKEN");
const WHATSAPP_PHONE_NUMBER_ID = (0, params_1.defineSecret)("WHATSAPP_PHONE_NUMBER_ID");
// =====================================================
// إرسال إشعار حقيقي إلى هاتف مسؤول المحطة
// عند إنشاء إشعار جديد في Realtime Database
// =====================================================
exports.sendStationNotification = (0, database_1.onValueCreated)({
    ref: "/notifications/{notificationId}",
}, async (event) => {
    var _a, _b, _c, _d;
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
    const userSnapshot = await (0, database_2.getDatabase)()
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
        console.log(`لا يوجد FCM Token للمستخدم: ${userId}`);
        return;
    }
    const title = (_a = notification.title) !== null && _a !== void 0 ? _a : "نافذة المنتوج النفطي";
    const message = (_b = notification.message) !== null && _b !== void 0 ? _b : "";
    const type = (_c = notification.type) !== null && _c !== void 0 ? _c : "station";
    try {
        const response = await (0, messaging_1.getMessaging)().send({
            token: fcmToken,
            notification: {
                title: title,
                body: message,
            },
            data: {
                notificationId: String((_d = notification.id) !== null && _d !== void 0 ? _d : event.params.notificationId),
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
        console.log("تم إرسال الإشعار بنجاح:", response);
        await (0, database_2.getDatabase)()
            .ref(`notifications/${event.params.notificationId}`)
            .update({
            pushSent: true,
            pushSentAt: new Date().toISOString(),
        });
    }
    catch (error) {
        console.error("فشل إرسال الإشعار:", error);
        await (0, database_2.getDatabase)()
            .ref(`notifications/${event.params.notificationId}`)
            .update({
            pushSent: false,
            pushError: String(error),
        });
    }
});
// =====================================================
// إرسال WhatsApp تلقائي
//
// أي رسالة جديدة في:
// /whatsappMessages/{messageId}
//
// سيتم إرسالها تلقائيًا إلى WhatsApp
// =====================================================
exports.sendWhatsAppMessage = (0, database_1.onValueCreated)({
    ref: "/whatsappMessages/{messageId}",
    secrets: [
        WHATSAPP_TOKEN,
        WHATSAPP_PHONE_NUMBER_ID,
    ],
}, async (event) => {
    var _a, _b, _c, _d, _e;
    const data = event.data.val();
    if (!data) {
        console.log("لا توجد بيانات لرسالة WhatsApp");
        return;
    }
    const phone = (_a = data.phone) === null || _a === void 0 ? void 0 : _a.toString().trim();
    const message = (_b = data.message) === null || _b === void 0 ? void 0 : _b.toString().trim();
    if (!phone) {
        console.log("رسالة WhatsApp لا تحتوي على رقم هاتف");
        await event.data.ref.update({
            sent: false,
            error: "رقم الهاتف غير موجود",
        });
        return;
    }
    if (!message) {
        console.log("رسالة WhatsApp لا تحتوي على نص");
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
    const token = WHATSAPP_TOKEN.value();
    const phoneNumberId = WHATSAPP_PHONE_NUMBER_ID.value();
    if (!token || !phoneNumberId) {
        console.error("WhatsApp Secrets غير موجودة");
        await event.data.ref.update({
            sent: false,
            error: "WhatsApp API غير مهيأ",
        });
        return;
    }
    // =================================================
    // إرسال الرسالة
    // =================================================
    try {
        const response = await fetch(`https://graph.facebook.com/v23.0/${phoneNumberId}/messages`, {
            method: "POST",
            headers: {
                "Authorization": `Bearer ${token}`,
                "Content-Type": "application/json",
            },
            body: JSON.stringify({
                messaging_product: "whatsapp",
                recipient_type: "individual",
                to: whatsappPhone,
                type: "text",
                text: {
                    preview_url: false,
                    body: message,
                },
            }),
        });
        const result = await response.json();
        if (!response.ok) {
            console.error("فشل إرسال WhatsApp:", result);
            await event.data.ref.update({
                sent: false,
                sentAt: new Date().toISOString(),
                error: JSON.stringify(result),
            });
            return;
        }
        console.log("تم إرسال WhatsApp بنجاح:", result);
        await event.data.ref.update({
            sent: true,
            sentAt: new Date().toISOString(),
            messageId: (_e = (_d = (_c = result.messages) === null || _c === void 0 ? void 0 : _c[0]) === null || _d === void 0 ? void 0 : _d.id) !== null && _e !== void 0 ? _e : null,
        });
    }
    catch (error) {
        console.error("خطأ أثناء إرسال WhatsApp:", error);
        await event.data.ref.update({
            sent: false,
            sentAt: new Date().toISOString(),
            error: String(error),
        });
    }
});
exports.deleteBranchManagerAuth = (0, https_1.onCall)(async (request) => {
    var _a, _b, _c;
    const callerUid = (_a = request.auth) === null || _a === void 0 ? void 0 : _a.uid;
    if (!callerUid) {
        throw new https_1.HttpsError("unauthenticated", "يجب تسجيل الدخول أولاً.");
    }
    const callerSnapshot = await (0, database_2.getDatabase)()
        .ref(`users/${callerUid}`)
        .get();
    if (!callerSnapshot.exists()) {
        throw new https_1.HttpsError("permission-denied", "المستخدم غير موجود.");
    }
    const callerData = callerSnapshot.val();
    if ((callerData === null || callerData === void 0 ? void 0 : callerData.role) !== "admin") {
        throw new https_1.HttpsError("permission-denied", "هذه العملية متاحة لمدير النظام فقط.");
    }
    const managerUid = String((_c = (_b = request.data) === null || _b === void 0 ? void 0 : _b.managerUid) !== null && _c !== void 0 ? _c : "").trim();
    if (!managerUid) {
        throw new https_1.HttpsError("invalid-argument", "managerUid مطلوب.");
    }
    if (managerUid === callerUid) {
        throw new https_1.HttpsError("failed-precondition", "لا يمكن حذف حساب مدير النظام.");
    }
    try {
        await (0, auth_1.getAuth)().deleteUser(managerUid);
        return {
            success: true,
            deletedUid: managerUid,
        };
    }
    catch (error) {
        if ((error === null || error === void 0 ? void 0 : error.code) === "auth/user-not-found") {
            return {
                success: true,
                deletedUid: managerUid,
                alreadyDeleted: true,
            };
        }
        console.error("Failed to delete branch manager:", error);
        throw new https_1.HttpsError("internal", "تعذر حذف حساب مدير الفرع.");
    }
});
//# sourceMappingURL=index.js.map