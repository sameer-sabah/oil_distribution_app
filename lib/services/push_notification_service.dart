import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance =
  PushNotificationService._();

  // =========================================================
  // Firebase Messaging
  // =========================================================

  final FirebaseMessaging messaging =
      FirebaseMessaging.instance;

  // =========================================================
  // Firebase Realtime Database
  // =========================================================

  final FirebaseDatabase database =
      FirebaseDatabase.instance;

  // =========================================================
  // Local Notifications
  // =========================================================

  final FlutterLocalNotificationsPlugin
  localNotifications =
  FlutterLocalNotificationsPlugin();

  // =========================================================
  // Subscriptions
  // =========================================================

  StreamSubscription<RemoteMessage>?
  _foregroundSubscription;

  StreamSubscription<String>?
  _tokenSubscription;

  StreamSubscription<DatabaseEvent>?
  _publicNotificationSubscription;

  StreamSubscription<DatabaseEvent>?
  _stationNotificationSubscription;

  // =========================================================
  // منع عرض نفس الإشعار أكثر من مرة
  // =========================================================

  final Set<String> _shownNotificationIds = {};

  // =========================================================
  // حالة الجهاز
  //
  // true = جهاز مواطن
  // false = ليس جهاز مواطن
  //
  // مهم حتى لا يتم تسجيل أجهزة الموظفين كأجهزة مواطنين.
  // =========================================================

  bool _isCitizenDevice = false;

  // =========================================================
  // تهيئة خدمة الإشعارات
  // =========================================================
  Future<void> initialize({
    bool isCitizen = false,
  }) async {
    _isCitizenDevice = isCitizen;

    // ---------------------------------------------------------
    // 1. إعداد الإشعارات المحلية
    // ---------------------------------------------------------

    const androidSettings =
    AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings =
    InitializationSettings(
      android: androidSettings,
    );

    await localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse response) {
        debugPrint(
          "Notification clicked: ${response.payload}",
        );
      },
    );

    // ---------------------------------------------------------
    // 2. إنشاء قناة الإشعارات
    // ---------------------------------------------------------

    const channel =
    AndroidNotificationChannel(
      'oil_distribution_channel',
      'إشعارات نافذة المنتوج النفطي',
      description:
      'إشعارات نظام نافذة المنتوج النفطي',
      importance: Importance.high,
      playSound: true,
    );

    await localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
      channel,
    );

    // ---------------------------------------------------------
    // 3. طلب صلاحية الإشعارات من Android
    // ---------------------------------------------------------

    final androidPlugin =
    localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    // ---------------------------------------------------------
    // 4. طلب صلاحية Firebase Messaging
    // ---------------------------------------------------------

    final settings =
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint(
      "Notification permission: "
          "${settings.authorizationStatus}",
    );

    // ---------------------------------------------------------
    // 5. Background handler
    // ---------------------------------------------------------

    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    // ---------------------------------------------------------
    // 6. الحصول على FCM Token
    // ---------------------------------------------------------

    final token =
    await messaging.getToken();

    debugPrint(
      "==============================",
    );

    debugPrint(
      "FCM TOKEN:",
    );

    debugPrint(token);

    debugPrint(
      "==============================",
    );

    // ---------------------------------------------------------
    // 7. إذا كان الجهاز مواطن
    //
    // نحفظ Token في:
    //
    // deviceTokens/citizens
    // ---------------------------------------------------------

    if (_isCitizenDevice) {
      await saveCitizenToken();
    }

    // ---------------------------------------------------------
    // 8. مراقبة الإشعارات العامة للمواطنين
    //
    // notifications/public
    // ---------------------------------------------------------

    if (_isCitizenDevice) {
      if (_isCitizenDevice) {
        try {
          await startPublicNotificationsListener();
        } catch (e) {
          debugPrint(
            "تعذر تشغيل Listener الإشعارات العامة: $e",
          );
        }
      }
    }

    // ---------------------------------------------------------
    // 9. استقبال FCM عندما التطبيق مفتوح
    // ---------------------------------------------------------

    await _foregroundSubscription
        ?.cancel();

    _foregroundSubscription =
        FirebaseMessaging.onMessage.listen(
              (RemoteMessage message) async {
            debugPrint(
              "FOREGROUND MESSAGE",
            );

            debugPrint(
              "Title: "
                  "${message.notification?.title}",
            );

            debugPrint(
              "Body: "
                  "${message.notification?.body}",
            );

            debugPrint(
              "Data: ${message.data}",
            );

            await _showForegroundNotification(
              message,
            );
          },
        );

    // ---------------------------------------------------------
    // 10. الضغط على إشعار والتطبيق بالخلفية
    // ---------------------------------------------------------

    FirebaseMessaging.onMessageOpenedApp.listen(
          (RemoteMessage message) {
        debugPrint(
          "Notification opened: "
              "${message.data}",
        );
      },
    );

    // ---------------------------------------------------------
    // 11. التطبيق كان مغلقاً وتم فتحه من FCM
    // ---------------------------------------------------------

    final initialMessage =
    await messaging.getInitialMessage();

    if (initialMessage != null) {
      debugPrint(
        "App opened from notification: "
            "${initialMessage.data}",
      );
    }

    // ---------------------------------------------------------
    // 12. مراقبة تغير FCM Token
    // ---------------------------------------------------------

    await _tokenSubscription
        ?.cancel();

    _tokenSubscription =
        messaging.onTokenRefresh.listen(
              (newToken) async {
            debugPrint(
              "FCM Token تغير: $newToken",
            );

            // فقط جهاز المواطن يسجل Token
            // داخل deviceTokens/citizens
            if (_isCitizenDevice) {
              await updateCitizenToken(
                newToken,
              );
            }
          },
        );
  }

  // =========================================================
  // إشعارات المواطنين العامة
  //
  // المسار:
  //
  // notifications/public/{notificationId}
  //
  // لا يحتاج المواطن تسجيل دخول.
  // =========================================================

  Future<void> startPublicNotificationsListener() async {
    final ref =
    database.ref(
      "notifications/public",
    );

    // ---------------------------------------------------------
    // إيقاف Listener قديم
    // ---------------------------------------------------------

    await _publicNotificationSubscription
        ?.cancel();

    // ---------------------------------------------------------
    // قراءة الإشعارات الموجودة مسبقاً
    //
    // حتى لا تظهر للمواطن كلها عند تشغيل التطبيق.
    // ---------------------------------------------------------

    final initialSnapshot =
    await ref.get();

    if (initialSnapshot.exists &&
        initialSnapshot.value is Map) {
      final data =
      Map<dynamic, dynamic>.from(
        initialSnapshot.value as Map,
      );

      for (final key in data.keys) {
        _shownNotificationIds.add(
          "public_${key.toString()}",
        );
      }
    }

    // ---------------------------------------------------------
    // مراقبة الإشعارات الجديدة
    // ---------------------------------------------------------

    _publicNotificationSubscription =
        ref.onChildAdded.listen(
              (event) async {
            try {
              final id =
              event.snapshot.key?.toString();

              if (id == null) {
                return;
              }

              final uniqueId =
                  "public_$id";

              // منع التكرار
              if (_shownNotificationIds
                  .contains(uniqueId)) {
                return;
              }

              _shownNotificationIds.add(
                uniqueId,
              );

              if (event.snapshot.value == null) {
                return;
              }

              if (event.snapshot.value
              is! Map) {
                return;
              }

              final value =
              Map<dynamic, dynamic>.from(
                event.snapshot.value as Map,
              );

              final title =
                  value["title"]?.toString() ??
                      "إشعار جديد";

              final body =
                  value["body"]?.toString() ??
                      value["message"]?.toString() ??
                      "";

              if (body.trim().isEmpty) {
                return;
              }

              await showLocalNotification(
                id: id.hashCode,
                title: title,
                body: body,
                payload:
                "public:$id",
              );
            } catch (e) {
              debugPrint(
                "خطأ في إشعار المواطن: $e",
              );
            }
          },
        );

    debugPrint(
      "تم تشغيل Listener الإشعارات العامة",
    );
  }

  // =========================================================
  // إشعارات مدير المحطة
  //
  // المسار:
  //
  // notifications/{stationId}/{notificationId}
  //
  // =========================================================

  Future<void> startStationNotificationsListener(
      String stationId,
      ) async {
    if (stationId.trim().isEmpty) {
      debugPrint(
        "Station ID غير موجود",
      );

      return;
    }

    final ref =
    database
        .ref("notifications")
        .child(stationId);

    // ---------------------------------------------------------
    // إيقاف Listener سابق
    // ---------------------------------------------------------

    await _stationNotificationSubscription
        ?.cancel();

    // ---------------------------------------------------------
    // قراءة الإشعارات الموجودة مسبقاً
    //
    // حتى لا تظهر القديمة مرة أخرى.
    // ---------------------------------------------------------

    final initialSnapshot =
    await ref.get();

    if (initialSnapshot.exists &&
        initialSnapshot.value is Map) {
      final data =
      Map<dynamic, dynamic>.from(
        initialSnapshot.value as Map,
      );

      for (final key in data.keys) {
        _shownNotificationIds.add(
          "${stationId}_$key",
        );
      }
    }

    // ---------------------------------------------------------
    // مراقبة الإشعارات الجديدة
    // ---------------------------------------------------------

    _stationNotificationSubscription =
        ref.onChildAdded.listen(
              (event) async {
            try {
              final id =
              event.snapshot.key?.toString();

              if (id == null) {
                return;
              }

              final uniqueId =
                  "${stationId}_$id";

              // منع التكرار
              if (_shownNotificationIds
                  .contains(uniqueId)) {
                return;
              }

              _shownNotificationIds.add(
                uniqueId,
              );

              if (event.snapshot.value == null) {
                return;
              }

              if (event.snapshot.value
              is! Map) {
                return;
              }

              final value =
              Map<dynamic, dynamic>.from(
                event.snapshot.value as Map,
              );

              final title =
                  value["title"]?.toString() ??
                      "إشعار المحطة";

              final body =
                  value["body"]?.toString() ??
                      value["message"]?.toString() ??
                      "";

              if (body.trim().isEmpty) {
                return;
              }

              await showLocalNotification(
                id: id.hashCode,
                title: title,
                body: body,
                payload:
                "station:$stationId:$id",
              );
            } catch (e) {
              debugPrint(
                "خطأ في إشعار المحطة: $e",
              );
            }
          },
        );

    debugPrint(
      "تم تشغيل إشعارات المحطة: $stationId",
    );
  }

  // =========================================================
  // عرض إشعار محلي
  // =========================================================

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails =
    AndroidNotificationDetails(
      'oil_distribution_channel',
      'إشعارات نافذة المنتوج النفطي',
      channelDescription:
      'إشعارات نظام نافذة المنتوج النفطي',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const details =
    NotificationDetails(
      android: androidDetails,
    );

    await localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  // =========================================================
  // Background Message Handler
  //
  // خاص بـ FCM
  // =========================================================

  @pragma('vm:entry-point')
  static Future<void>
  firebaseMessagingBackgroundHandler(
      RemoteMessage message,
      ) async {
    await Firebase.initializeApp();

    debugPrint(
      "Background notification: "
          "${message.notification?.title}",
    );

    debugPrint(
      "Background data: "
          "${message.data}",
    );
  }

  // =========================================================
  // عرض إشعار FCM عندما التطبيق مفتوح
  // =========================================================

  Future<void> _showForegroundNotification(
      RemoteMessage message,
      ) async {
    final title =
        message.notification?.title ??
            message.data["title"] ??
            "إشعار جديد";

    final body =
        message.notification?.body ??
            message.data["body"] ??
            "";

    const details =
    AndroidNotificationDetails(
      'oil_distribution_channel',
      'إشعارات نافذة المنتوج النفطي',
      channelDescription:
      'إشعارات نظام نافذة المنتوج النفطي',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    await localNotifications.show(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .remainder(100000),
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: details,
      ),
      payload: message.data.toString(),
    );
  }

  // =========================================================
  // الحصول على FCM Token
  // =========================================================

  Future<String?> getToken() async {
    return await messaging.getToken();
  }

  // =========================================================
  // حفظ Token للمستخدم
  //
  // مدير المحطة / الموظف / المدير
  //
  // users/{userId}/fcmToken
  // =========================================================

  Future<void> saveFcmToken({
    required String userId,
    required String token,
  }) async {
    await database
        .ref("users")
        .child(userId)
        .update({
      "fcmToken": token,
      "fcmTokenUpdatedAt":
      DateTime.now()
          .toIso8601String(),
    });
  }

  // =========================================================
  // حفظ Token المستخدم الحالي
  // =========================================================

  Future<void> saveCurrentUserToken({
    required String userId,
  }) async {
    final token =
    await getToken();

    if (token == null ||
        token.isEmpty) {
      debugPrint(
        "FCM Token غير موجود",
      );

      return;
    }

    await saveFcmToken(
      userId: userId,
      token: token,
    );

    debugPrint(
      "تم حفظ FCM Token للمستخدم: "
          "$userId",
    );
  }

  // =========================================================
  // مراقبة تغير Token
  //
  // هذه الدالة أبقيتها حتى لا تتأثر
  // الأكواد الأخرى التي تستخدمها.
  // =========================================================

  StreamSubscription<String>
  listenTokenChanges(
      Future<void> Function(String token)
      onToken,
      ) {
    return messaging.onTokenRefresh.listen(
          (String token) async {
        await onToken(token);
      },
    );
  }

  // =========================================================
  // حفظ Token المواطن
  //
  // المسار:
  //
  // deviceTokens/citizens/{generatedId}
  //
  // نستخدم push() حتى لا نضع FCM Token
  // كمفتاح Firebase.
  // =========================================================

  Future<void> saveCitizenToken() async {
    try {
      final token = await messaging.getToken();

      if (token == null || token.isEmpty) {
        debugPrint(
          "FCM Token المواطن غير موجود",
        );
        return;
      }

      final ref =
      database.ref("deviceTokens/citizens");

      // =======================================================
      // ننشئ ID آمن بواسطة Firebase
      // ولا نستخدم FCM Token كمفتاح
      // =======================================================

      final deviceRef = ref.push();

      await deviceRef.set({
        "token": token,
        "active": true,
        "platform": "android",
        "createdAt":
        DateTime.now().toIso8601String(),
        "updatedAt":
        DateTime.now().toIso8601String(),
      });

      debugPrint(
        "تم تسجيل جهاز المواطن بنجاح",
      );

      debugPrint(
        "Device ID: ${deviceRef.key}",
      );
    } catch (e) {
      debugPrint(
        "خطأ في حفظ Token المواطن: $e",
      );
    }
  }

  // =========================================================
  // تحديث Token المواطن عند تغيّره
  // =========================================================

  Future<void> updateCitizenToken(
      String newToken,
      ) async {
    if (newToken.isEmpty) {
      return;
    }

    final ref =
    database.ref(
      "deviceTokens/citizens",
    );

    final snapshot =
    await ref.get();

    if (snapshot.exists &&
        snapshot.value is Map) {
      final data =
      Map<dynamic, dynamic>.from(
        snapshot.value as Map,
      );

      String? oldId;

      for (final entry
      in data.entries) {
        final item =
            entry.value;

        if (item is Map &&
            item["token"] ==
                newToken) {
          oldId =
              entry.key.toString();

          break;
        }
      }

      if (oldId != null) {
        await ref
            .child(oldId)
            .update({
          "active": true,
          "updatedAt":
          DateTime.now()
              .toIso8601String(),
        });

        debugPrint(
          "تم تحديث Token المواطن",
        );

        return;
      }
    }

    // ---------------------------------------------------------
    // Token جديد
    // ---------------------------------------------------------

    final deviceRef =
    ref.push();

    await deviceRef.set({
      "token": newToken,
      "active": true,
      "platform": "android",
      "createdAt":
      DateTime.now()
          .toIso8601String(),
      "updatedAt":
      DateTime.now()
          .toIso8601String(),
    });

    debugPrint(
      "تم تسجيل Token جديد للمواطن",
    );
  }

  // =========================================================
  // تفعيل إشعارات محطة
  //
  // نستدعيها بعد تسجيل دخول مدير المحطة
  //
  // مثال:
  //
  // await PushNotificationService.instance
  //     .startStationNotificationsListener(
  //       stationId,
  //     );
  //
  // =========================================================

  // =========================================================
  // إيقاف الخدمة
  // =========================================================

  Future<void> dispose() async {
    await _foregroundSubscription
        ?.cancel();

    await _tokenSubscription
        ?.cancel();

    await _publicNotificationSubscription
        ?.cancel();

    await _stationNotificationSubscription
        ?.cancel();

    _foregroundSubscription =
    null;

    _tokenSubscription =
    null;

    _publicNotificationSubscription =
    null;

    _stationNotificationSubscription =
    null;
  }
}