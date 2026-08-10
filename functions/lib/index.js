"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendStationNotification = void 0;
const firebase_functions_1 = require("firebase-functions");
const database_1 = require("firebase-functions/v2/database");
const app_1 = require("firebase-admin/app");
const database_2 = require("firebase-admin/database");
const messaging_1 = require("firebase-admin/messaging");
(0, app_1.initializeApp)();
(0, firebase_functions_1.setGlobalOptions)({
    maxInstances: 10,
});
// =====================================================
// إرسال إشعار حقيقي إلى هاتف مسؤول المحطة
// عند إنشاء إشعار جديد في Realtime Database
// =====================================================
exports.sendStationNotification = (0, database_1.onValueCreated)("/notifications/{notificationId}", async (event) => {
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
    // =================================================
    // إرسال Push Notification
    // =================================================
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
        // تسجيل نجاح الإرسال
        await (0, database_2.getDatabase)()
            .ref(`notifications/${event.params.notificationId}`)
            .update({
            pushSent: true,
            pushSentAt: new Date().toISOString(),
        });
    }
    catch (error) {
        console.error("فشل إرسال الإشعار:", error);
        // تسجيل فشل الإرسال
        await (0, database_2.getDatabase)()
            .ref(`notifications/${event.params.notificationId}`)
            .update({
            pushSent: false,
            pushError: String(error),
        });
    }
});
//# sourceMappingURL=index.js.map