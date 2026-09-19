import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/user_model.dart';

class UserService {
  UserService._();

  static final UserService instance = UserService._();

  final FirebaseDatabase database = FirebaseDatabase.instance;

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  DatabaseReference get usersRef =>
      database.ref("users");

  DatabaseReference get notificationsRef =>
      database.ref("notifications");

  // =====================================================
  // معرفة المستخدم الحالي وصلاحيته
  // =====================================================

  Future<AppUser?> _getCurrentAppUser() async {
    final firebaseUser = firebaseAuth.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    final snapshot = await usersRef
        .child(firebaseUser.uid)
        .get();

    if (!snapshot.exists || snapshot.value == null) {
      return null;
    }

    final data = Map<String, dynamic>.from(
      snapshot.value as Map,
    );

    return AppUser.fromMap(
      firebaseUser.uid,
      data,
    );
  }

  // =====================================================
  // إضافة مستخدم
  // =====================================================

  Future<void> addUser(AppUser user) async {
    await usersRef
        .child(user.id)
        .set({
      "uid": user.id,
      "fullName": user.fullName,
      "username": user.username,
      // SECURITY: كلمة المرور لا تُحفظ في Realtime Database.
      "email": user.email,
      "phone": user.phone,
      "role": user.role,
      "governorateId": user.governorateId,
      "governorateName": user.governorateName,
      "branchId": user.branchId,
      "branchName": user.branchName,
      "stationId": user.stationId,
      "stationName": user.stationName,
      "position": user.position,
      "image": user.image,
      "active": user.active,
      "createdAt": user.createdAt.toIso8601String(),
      "updatedAt": user.updatedAt.toIso8601String(),
      "lastLogin": user.lastLogin.toIso8601String(),
    });
  }

  // =====================================================
  // إنشاء مستخدم
  // =====================================================

  Future<String?> createUser({
    required String fullName,
    required String username,
    required String password,
    required String email,
    required String phone,
    required String role,
    required String governorateId,
    required String governorateName,
    required String branchId,
    required String branchName,
    required String stationId,
    required String stationName,
    required String position,
  }) async {
    try {
      final uid = usersRef.push().key;

      if (uid == null) {
        return "تعذر إنشاء معرف المستخدم";
      }

      await usersRef.child(uid).set({
        "uid": uid,
        "fullName": fullName,
        "username": username,
        // SECURITY: password يُستخدم فقط في مسار Firebase Auth إن وُجد،
        // ولا يُحفظ كنص داخل Realtime Database.
        "email": email,
        "phone": phone,
        "role": role,
        "governorateId": governorateId,
        "governorateName": governorateName,
        "branchId": branchId,
        "branchName": branchName,
        "stationId": stationId,
        "stationName": stationName,
        "position": position,
        "active": true,
        "createdAt":
        DateTime.now().toIso8601String(),
        "updatedAt":
        DateTime.now().toIso8601String(),
        "lastLogin":
        DateTime.now().toIso8601String(),
      });

      return null;
    } on FirebaseException catch (e) {
      return "Firebase ${e.code}: ${e.message}";
    } catch (e) {
      return e.toString();
    }
  }

  // =====================================================
  // بث مباشر للحي وحقيقي للمستخدمين
  // =====================================================

  Stream<List<Map<String, dynamic>>> usersStream() {
    return usersRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null || value is! Map) {
        return <Map<String, dynamic>>[];
      }

      final data = Map<dynamic, dynamic>.from(value);
      final List<Map<String, dynamic>> list = [];

      data.forEach((key, val) {
        if (val is Map) {
          final user = Map<String, dynamic>.from(val);
          user["uid"] = key.toString();
          list.add(user);
        }
      });

      list.sort((a, b) {
        final aDate = (a["createdAt"] ?? a["updatedAt"] ?? "").toString();
        final bDate = (b["createdAt"] ?? b["updatedAt"] ?? "").toString();
        return bDate.compareTo(aDate);
      });

      return list;
    });
  }

  // =====================================================
  // جلب المستخدمين
  //
  // admin:
  //     جميع المستخدمين
  //
  // branchManager:
  //     مستخدمو فرعه فقط
  // =====================================================

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final currentUser =
      await _getCurrentAppUser();

      if (currentUser == null) {
        throw Exception(
          "تعذر قراءة بيانات المستخدم الحالي",
        );
      }

      // -------------------------------------------------
      // مدير النظام
      // -------------------------------------------------

      if (currentUser.role == "admin") {
        final snapshot =
        await usersRef.get();

        if (!snapshot.exists ||
            snapshot.value == null) {
          return [];
        }

        if (snapshot.value is! Map) {
          return [];
        }

        final data =
        Map<dynamic, dynamic>.from(
          snapshot.value as Map,
        );

        return data.entries.map((entry) {
          final user =
          Map<String, dynamic>.from(
            entry.value as Map,
          );

          user["uid"] =
              entry.key.toString();

          return user;
        }).toList();
      }

      // -------------------------------------------------
      // مدير الفرع
      // -------------------------------------------------

      if (currentUser.role ==
          "branchManager") {
        final branchId =
        currentUser.branchId.trim();

        if (branchId.isEmpty) {
          throw Exception(
            "مدير الفرع لا يحتوي على branchId",
          );
        }

        final snapshot =
        await usersRef
            .orderByChild("branchId")
            .equalTo(branchId)
            .get();

        if (!snapshot.exists ||
            snapshot.value == null) {
          return [];
        }

        if (snapshot.value is! Map) {
          return [];
        }

        final data =
        Map<dynamic, dynamic>.from(
          snapshot.value as Map,
        );

        return data.entries.map((entry) {
          final user =
          Map<String, dynamic>.from(
            entry.value as Map,
          );

          user["uid"] =
              entry.key.toString();

          return user;
        }).toList();
      }

      // -------------------------------------------------
      // باقي المستخدمين
      // -------------------------------------------------

      return [];
    } on FirebaseException catch (e) {
      throw Exception(
        "Firebase ${e.code}: ${e.message}",
      );
    } catch (e) {
      throw Exception(
        "فشل جلب المستخدمين: $e",
      );
    }
  }

  // =====================================================
  // عدد المستخدمين
  // =====================================================

  Future<int> getUsersCount() async {
    final users = await getUsers();

    return users.length;
  }

  // =====================================================
  // حذف مستخدم
  // =====================================================

  Future<void> deleteUser(
      String uid,
      ) async {
    await usersRef
        .child(uid)
        .remove();
  }

  // =====================================================
  // تحديث مستخدم
  // =====================================================

  Future<void> updateUser(
      String uid,
      Map<String, dynamic> data,
      ) async {
    await usersRef
        .child(uid)
        .update(data);
  }

  // =====================================================
  // جلب مستخدم واحد
  // =====================================================

  Future<Map<String, dynamic>?> getUser(
      String uid,
      ) async {
    final snapshot =
    await usersRef
        .child(uid)
        .get();

    if (!snapshot.exists ||
        snapshot.value == null) {
      return null;
    }

    return Map<String, dynamic>.from(
      snapshot.value as Map,
    );
  }

  // =====================================================
  // إرسال إشعار
  // =====================================================

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
  }) async {
    final id =
        notificationsRef.push().key;

    if (id == null) {
      throw Exception(
        "تعذر إنشاء معرف الإشعار",
      );
    }

    await notificationsRef
        .child(id)
        .set({
      "id": id,
      "userId": userId,
      "title": title,
      "body": body,
      "read": false,
      "createdAt":
      DateTime.now().toIso8601String(),
    });
  }
}