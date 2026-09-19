import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';

Future<void> updateFcmToken(String userId) async {
  final messaging = FirebaseMessaging.instance;

  await messaging.requestPermission();

  final token = await messaging.getToken();

  if (token != null) {
    await FirebaseDatabase.instance
        .ref('users/$userId')
        .update({
      'fcmToken': token,
      'fcmTokenUpdatedAt': DateTime.now().toIso8601String(),
    });
  }

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    await FirebaseDatabase.instance
        .ref('users/$userId')
        .update({
      'fcmToken': newToken,
      'fcmTokenUpdatedAt': DateTime.now().toIso8601String(),
    });
  });
}