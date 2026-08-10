import 'package:firebase_database/firebase_database.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance =
  NotificationService._();

  final FirebaseDatabase database =
      FirebaseDatabase.instance;

  DatabaseReference get notificationsRef =>
      database.ref("notifications");

  // =========================================
  // إضافة إشعار
  // =========================================

  Future<void> addNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
  }) async {
    final id = notificationsRef.push().key!;

    await notificationsRef.child(id).set({
      "id": id,
      "userId": userId,
      "title": title,
      "message": message,
      "type": type,
      "read": false,
      "createdAt": DateTime.now().toIso8601String(),
    });
  }

  // =========================================
  // إرسال إشعار لمحطة محددة
  // =========================================

  Future<bool> sendToStation({
    required String stationId,
    required String title,
    required String message,
    String type = "station",
  }) async {
    String? managerUid;

    // =========================================
    // 1. البحث عن managerUid داخل المحطة
    // =========================================

    final stationSnapshot = await database
        .ref("stations/$stationId")
        .get();

    if (stationSnapshot.exists &&
        stationSnapshot.value != null) {
      final station = Map<String, dynamic>.from(
        stationSnapshot.value as Map,
      );

      final value = station["managerUid"];

      if (value != null &&
          value.toString().isNotEmpty) {
        managerUid = value.toString();
      }
    }

    // =========================================
    // 2. إذا غير موجود، البحث داخل users
    // =========================================

    if (managerUid == null) {
      final usersSnapshot =
      await database.ref("users").get();

      if (usersSnapshot.exists &&
          usersSnapshot.value != null) {
        final users =
        Map<dynamic, dynamic>.from(
          usersSnapshot.value as Map,
        );

        for (final entry in users.entries) {
          final user =
          Map<String, dynamic>.from(
            entry.value as Map,
          );

          if (user["stationId"]?.toString() ==
              stationId) {
            managerUid = entry.key.toString();
            break;
          }
        }
      }
    }

    // =========================================
    // 3. لا يوجد مدير مرتبط
    // =========================================

    if (managerUid == null ||
        managerUid!.isEmpty) {
      return false;
    }

    // =========================================
    // 4. حفظ الإشعار للمدير
    // =========================================

    await addNotification(
      userId: managerUid!,
      title: title,
      message: message,
      type: type,
    );

    return true;
  }

  // =========================================
  // إشعار تحديث كمية منتج في محطة
  // =========================================

  Future<void> notifyQuantityUpdate({
    required String stationId,
    required String stationName,
    required String productName,
    required int quantity,
  }) async {
    String title;
    String message;
    String type;

    if (quantity <= 0) {
      title = "🔴 نفاد المنتج";

      message =
      "المنتج $productName غير متوفر حالياً في محطة $stationName.";

      type = "product_empty";
    } else if (quantity < 5000) {
      title = "🟠 تنبيه كمية منخفضة";

      message =
      "كمية $productName في محطة $stationName أصبحت قليلة.\n"
          "الكمية الحالية: $quantity لتر.";

      type = "low_quantity";
    } else {
      title = "🟢 تحديث كمية المنتج";

      message =
      "المنتج $productName متوفر في محطة $stationName.\n"
          "الكمية الحالية: $quantity لتر.";

      type = "quantity_update";
    }

    await sendToStation(
      stationId: stationId,
      title: title,
      message: message,
      type: type,
    );

  }

  // =========================================
  // جلب إشعارات مستخدم
  // =========================================

  Future<List<Map<String, dynamic>>> getUserNotifications(
      String userId,
      ) async {
    final snapshot = await notificationsRef
        .orderByChild("userId")
        .equalTo(userId)
        .get();

    if (!snapshot.exists || snapshot.value == null) {
      return [];
    }

    final data =
    Map<dynamic, dynamic>.from(snapshot.value as Map);

    return data.entries.map((e) {
      final item =
      Map<String, dynamic>.from(e.value as Map);

      item["id"] = e.key.toString();

      return item;
    }).toList();
  }

  // =========================================
  // تعليم الإشعار كمقروء
  // =========================================

  Future<void> markAsRead(String id) async {
    await notificationsRef.child(id).update({
      "read": true,
    });
  }

  // =========================================
  // حذف إشعار
  // =========================================

  Future<void> deleteNotification(String id) async {
    await notificationsRef.child(id).remove();
  }

  // =========================================
  // إرسال إشعار عام لجميع المستخدمين
  // =========================================

  Future<void> sendToAll({
    required String title,
    required String message,
    required String type,
  }) async {
    final snapshot = await database.ref("users").get();

    if (!snapshot.exists || snapshot.value == null) {
      return;
    }

    final users =
    Map<dynamic, dynamic>.from(snapshot.value as Map);

    for (final user in users.entries) {
      await addNotification(
        userId: user.key.toString(),
        title: title,
        message: message,
        type: type,
      );
    }
  }
}