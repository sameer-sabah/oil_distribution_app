import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/user_roles.dart';
import '../models/user_model.dart';
import 'push_notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';


class AuthService {
  AuthService._();

  static final AuthService instance =
  AuthService._();

  final FirebaseDatabase _database =
      FirebaseDatabase.instance;

  DatabaseReference get usersRef =>
      _database.ref("users");

  AppUser? currentUser;

  //====================================
  // تسجيل الدخول
  //====================================

  Future<AppUser?> login({
    required String username,
    required String password,
  }) async {
    debugPrint("========== LOGIN START ==========");

    try {
      String email;

      if (username.trim() == "admin") {
        email = "admin@opdc.iq";
      } else {
        final enteredUsername =
        username.trim();

        email = enteredUsername.contains("@")
            ? enteredUsername
            : "$enteredUsername@opdc.iq";
      }

      debugPrint(
        "Signing in with Firebase Authentication...",
      );

      final credential =
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser =
          credential.user;

      if (firebaseUser == null) {
        debugPrint("Firebase user is null");
        return null;
      }

      debugPrint(
        "Firebase UID = ${firebaseUser.uid}",
      );

      final userSnapshot =
      await usersRef
          .child(firebaseUser.uid)
          .get();

      if (!userSnapshot.exists ||
          userSnapshot.value == null) {
        debugPrint(
          "No user profile found for UID: "
              "${firebaseUser.uid}",
        );

        await FirebaseAuth.instance.signOut();

        return null;
      }

      final map =
      Map<String, dynamic>.from(
        userSnapshot.value as Map,
      );

      final user =
      AppUser.fromMap(
        firebaseUser.uid,
        map,
      );

      if (!user.active) {
        debugPrint(
          "User account is inactive",
        );

        await FirebaseAuth.instance.signOut();

        return null;
      }

      currentUser = user;

      // تحديث lastLogin وحفظ FCM لا يجب أن يؤخرا دخول المستخدم.
      // نبدأهما بالخلفية بعد نجاح Authentication وقراءة ملف المستخدم.
      usersRef
          .child(firebaseUser.uid)
          .update({
        "lastLogin":
        DateTime.now()
            .toIso8601String(),
      }).catchError((e) {
        debugPrint(
          "lastLogin update error: $e",
        );
      });

      PushNotificationService
          .instance
          .saveCurrentUserToken(
        userId:
        firebaseUser.uid,
      ).catchError((e) {
        debugPrint(
          "FCM Token save error: $e",
        );
      });

      debugPrint(
        "========== LOGIN SUCCESS ==========",
      );

      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        "Firebase Auth Error: ${e.code}",
      );

      return null;
    } catch (e) {
      debugPrint(
        "LOGIN ERROR: $e",
      );

      return null;
    }
  }

  //====================================
  // تسجيل الخروج
  //====================================

  Future<void> logout() async {
    try {
      currentUser = null;

      await FirebaseAuth.instance.signOut();

      debugPrint("تم تسجيل الخروج بالكامل");
    } catch (e) {
      debugPrint("LOGOUT ERROR: $e");
    }
  }

  //====================================
  // إنشاء مدير النظام الافتراضي
  //====================================

  Future<void> createDefaultAdmin() async {
    final snapshot =
    await usersRef.get();

    if (snapshot.exists &&
        snapshot.value != null) {
      final data =
      Map<dynamic, dynamic>.from(
        snapshot.value as Map,
      );

      for (final item
      in data.entries) {
        final uid =
        item.key.toString();

        final map =
        Map<String, dynamic>.from(
          item.value as Map,
        );

        if ((map["role"] ?? "") ==
            UserRoles.admin) {
          await usersRef
              .child(uid)
              .update({
            "fullName":
            map["fullName"] ??
                "مدير النظام",
            "username":
            map["username"] ??
                "admin",
            // لا نخزن كلمة المرور في Realtime Database.
            "email":
            map["email"] ??
                "admin@opdc.iq",
            "phone":
            map["phone"] ?? "",
            "branchId":
            map["branchId"] ?? "",
            "stationId":
            map["stationId"] ?? "",
            "active": true,
            "createdAt":
            map["createdAt"] ??
                DateTime.now()
                    .toIso8601String(),
          });

          return;
        }
      }
    }

    final admin = AppUser(
      id: "admin",
      fullName: "مدير النظام",
      username: "admin",
      password: "123456",
      email: "admin@opdc.iq",
      phone: "",
      role: UserRoles.admin,
      governorateId: "",
      governorateName: "",
      branchId: "",
      branchName: "",
      stationId: "",
      stationName: "",
      position: "مدير النظام",
      image: "",
      active: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );

    await usersRef
        .child(admin.id)
        .set(admin.toMap());
  }

  //====================================
  // ترقية المستخدمين القدامى
  //====================================

  Future<void> upgradeOldUsers() async {
    final snapshot =
    await usersRef.get();

    if (!snapshot.exists ||
        snapshot.value == null) {
      return;
    }

    final data =
    Map<dynamic, dynamic>.from(
      snapshot.value as Map,
    );

    for (final item
    in data.entries) {
      final uid =
      item.key.toString();

      final map =
      Map<String, dynamic>.from(
        item.value as Map,
      );

      final updates =
      <String, dynamic>{};

      if (!map.containsKey("fullName")) {
        updates["fullName"] = "";
      }

      if (!map.containsKey("username")) {
        updates["username"] = uid;
      }

      if (!map.containsKey("email")) {
        updates["email"] = "";
      }

      if (!map.containsKey("phone")) {
        updates["phone"] = "";
      }

      if (!map.containsKey("branchId")) {
        updates["branchId"] = "";
      }

      if (!map.containsKey("stationId")) {
        updates["stationId"] = "";
      }

      if (!map.containsKey("branchName")) {
        updates["branchName"] = "";
      }

      if (!map.containsKey("stationName")) {
        updates["stationName"] = "";
      }

      if (!map.containsKey("governorateId")) {
        updates["governorateId"] = "";
      }

      if (!map.containsKey("governorateName")) {
        updates["governorateName"] = "";
      }

      if (!map.containsKey("position")) {
        updates["position"] = "";
      }

      if (!map.containsKey("image")) {
        updates["image"] = "";
      }

      if (!map.containsKey("updatedAt")) {
        updates["updatedAt"] =
            DateTime.now()
                .toIso8601String();
      }

      if (!map.containsKey("lastLogin")) {
        updates["lastLogin"] =
            DateTime.now()
                .toIso8601String();
      }

      if (!map.containsKey("active")) {
        updates["active"] = true;
      }

      if (!map.containsKey("createdAt")) {
        updates["createdAt"] =
            DateTime.now()
                .toIso8601String();
      }

      if (updates.isNotEmpty) {
        await usersRef
            .child(uid)
            .update(updates);
      }
    }
  }

  //====================================
  // المستخدم الحالي
  //====================================

  bool get isLoggedIn =>
      currentUser != null;
  Future<AppUser?> restoreCurrentUser() async {
    try {
      final firebaseUser =
          FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        return null;
      }

      final snapshot =
      await usersRef
          .child(firebaseUser.uid)
          .get();

      if (!snapshot.exists ||
          snapshot.value == null) {
        return null;
      }

      final map =
      Map<String, dynamic>.from(
        snapshot.value as Map,
      );

      final user =
      AppUser.fromMap(
        firebaseUser.uid,
        map,
      );

      if (!user.active) {
        return null;
      }

      currentUser = user;

      return user;
    } catch (e) {
      debugPrint(
        "RESTORE USER ERROR: $e",
      );

      return null;
    }
  }
  bool get isAdmin =>
      UserRoles.isAdmin(currentUser?.role);

  bool get isBranchManager =>
      UserRoles.isBranchManager(currentUser?.role);

  bool get isDistributionManager =>
      UserRoles.isDistributionManager(currentUser?.role);

  bool get isStationManager =>
      UserRoles.isStationManager(currentUser?.role);

  //====================================
  // إضافة مستخدم
  //====================================

  Future<void> addUser(
      AppUser user) async {
    await usersRef
        .child(user.id)
        .set(user.toMap());
  }

  //====================================
  // تحديث مستخدم
  //====================================

  Future<void> updateUser(
      AppUser user) async {
    await usersRef
        .child(user.id)
        .update(user.toMap());
  }

  //====================================
  // حذف مستخدم
  //====================================

  Future<void> deleteUser(
      String id) async {
    await usersRef
        .child(id)
        .remove();
  }

  //====================================
  // جلب مستخدم واحد
  //====================================

  Future<AppUser?> getUserById(
      String id) async {
    final snapshot =
    await usersRef
        .child(id)
        .get();

    if (!snapshot.exists ||
        snapshot.value == null) {
      return null;
    }

    return AppUser.fromMap(
      id,
      Map<String, dynamic>.from(
        snapshot.value as Map,
      ),
    );
  }

//====================================
// جلب المستخدمين
// مدير النظام = جميع المستخدمين
// مدير الفرع = مستخدمو فرعه فقط
//====================================

  Future<List<AppUser>> getUsers() async {
    try {
      final user = currentUser;

      debugPrint("====================================");
      debugPrint("GET USERS START");
      debugPrint(
        "Firebase UID: ${FirebaseAuth.instance.currentUser?.uid}",
      );
      debugPrint(
        "ROLE: ${user?.role}",
      );
      debugPrint(
        "BRANCH ID: ${user?.branchId}",
      );
      debugPrint(
        "BRANCH NAME: ${user?.branchName}",
      );
      debugPrint("====================================");

      if (user == null) {
        throw Exception(
          "لا يوجد مستخدم مسجل الدخول",
        );
      }

      // ====================================
      // مدير النظام
      // ====================================

      if (user.role == UserRoles.admin) {
        debugPrint(
          "GET USERS: Admin - قراءة جميع المستخدمين",
        );

        final snapshot =
        await usersRef.get();

        if (!snapshot.exists ||
            snapshot.value == null) {
          debugPrint(
            "GET USERS: لا توجد بيانات",
          );

          return [];
        }

        final rawData =
            snapshot.value;

        if (rawData is! Map) {
          throw Exception(
            "بيانات المستخدمين غير صحيحة",
          );
        }

        final data =
        Map<dynamic, dynamic>.from(
          rawData,
        );

        final List<AppUser> result = [];

        for (final entry in data.entries) {
          if (entry.value is! Map) {
            continue;
          }

          try {
            result.add(
              AppUser.fromMap(
                entry.key.toString(),
                Map<String, dynamic>.from(
                  entry.value as Map,
                ),
              ),
            );
          } catch (e) {
            debugPrint(
              "تجاهل مستخدم غير صالح: $e",
            );
          }
        }

        debugPrint(
          "GET USERS SUCCESS: ${result.length}",
        );

        return result;
      }

      // ====================================
      // مدير الفرع
      // ====================================

      if (user.role ==
          UserRoles.branchManager) {

        final branchId =
        user.branchId.trim();

        debugPrint(
          "Branch Manager branchId = $branchId",
        );

        if (branchId.isEmpty) {
          throw Exception(
            "حساب مدير الفرع لا يحتوي على branchId",
          );
        }

        debugPrint(
          "تنفيذ استعلام users حسب branchId",
        );

        final snapshot =
        await usersRef
            .orderByChild("branchId")
            .equalTo(branchId)
            .get();

        debugPrint(
          "QUERY COMPLETED",
        );

        if (!snapshot.exists ||
            snapshot.value == null) {
          debugPrint(
            "لا يوجد مستخدمون في هذا الفرع",
          );

          return [];
        }

        final rawData =
            snapshot.value;

        if (rawData is! Map) {
          throw Exception(
            "بيانات المستخدمين غير صحيحة",
          );
        }

        final data =
        Map<dynamic, dynamic>.from(
          rawData,
        );

        final List<AppUser> result = [];

        for (final entry in data.entries) {
          if (entry.value is! Map) {
            continue;
          }

          try {
            result.add(
              AppUser.fromMap(
                entry.key.toString(),
                Map<String, dynamic>.from(
                  entry.value as Map,
                ),
              ),
            );
          } catch (e) {
            debugPrint(
              "تجاهل مستخدم غير صالح: $e",
            );
          }
        }

        debugPrint(
          "GET USERS SUCCESS: ${result.length}",
        );

        return result;
      }

      // ====================================
      // باقي الصلاحيات
      // ====================================

      debugPrint(
        "GET USERS: الصلاحية لا تسمح",
      );

      return [];
    }

    // ====================================
    // Firebase Error
    // ====================================

    on FirebaseException catch (e) {
      debugPrint(
        "====================================",
      );
      debugPrint(
        "GET USERS FIREBASE ERROR",
      );
      debugPrint(
        "CODE: ${e.code}",
      );
      debugPrint(
        "MESSAGE: ${e.message}",
      );
      debugPrint(
        "====================================",
      );

      throw Exception(
        "Firebase ${e.code}: ${e.message}",
      );
    }

    // ====================================
    // خطأ عام
    // ====================================

    catch (e) {
      debugPrint(
        "GET USERS ERROR: $e",
      );

      throw Exception(
        "فشل جلب المستخدمين: $e",
      );
    }
  }
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  //====================================
  // ترحيل مدير النظام إلى Firebase Auth
  //====================================

  Future<void>
  migrateAdminToFirebaseAuth() async {
    const authUid =
        'TzeL8wJ37kVsYFqiQel9rHxsOS33';

    final oldSnapshot =
    await usersRef
        .child('admin')
        .get();

    if (!oldSnapshot.exists ||
        oldSnapshot.value == null) {
      throw Exception(
        'users/admin غير موجود',
      );
    }

    final oldData =
    Map<String, dynamic>.from(
      oldSnapshot.value as Map,
    );

    oldData.remove('password');

    oldData['username'] =
    'admin';

    oldData['email'] =
    'admin@opdc.iq';

    oldData['role'] =
        UserRoles.admin;

    oldData['active'] =
    true;

    oldData['updatedAt'] =
        DateTime.now()
            .toIso8601String();

    await usersRef
        .child(authUid)
        .set(oldData);

    debugPrint(
      'Admin migrated successfully: $authUid',
    );
  }

  //====================================
  // إنشاء حساب Firebase Authentication
  //
  // مهم:
  // هذه الدالة تنشئ حساب Auth فقط.
  //
  // لا تكتب users/{uid}
  //
  // حتى تبقى جلسة مدير الفرع الرئيسية
  // هي التي تنفذ كتابة Database.
  //====================================

  Future<AppUser?> createUserAccount({
    required AppUser user,
  }) async {
    FirebaseApp? secondaryApp;

    try {
      secondaryApp =
      await Firebase.initializeApp(
        name: 'secondaryAuthApp',
        options:
        DefaultFirebaseOptions
            .currentPlatform,
      );

      final secondaryAuth =
      FirebaseAuth.instanceFor(
        app: secondaryApp,
      );

      final credential =
      await secondaryAuth
          .createUserWithEmailAndPassword(
        email:
        user.email.trim(),
        password:
        user.password.trim(),
      );

      final firebaseUser =
          credential.user;

      if (firebaseUser == null) {
        throw Exception(
          "فشل إنشاء حساب Firebase",
        );
      }

      final uid =
          firebaseUser.uid;

      debugPrint(
        "NEW FIREBASE USER UID = $uid",
      );

      // لا نكتب users هنا.
      //
      // مهم جداً:
      // لا نستخدم usersRef هنا لأننا نريد
      // أن تبقى جلسة Firebase الرئيسية
      // هي المسؤولة عن كتابة Database.

      return AppUser.fromMap(
        uid,
        {
          "uid": uid,
          "fullName":
          user.fullName,
          "username":
          user.username,
          "email":
          user.email,
          "phone":
          user.phone,
          "role":
          user.role,
          "governorateId":
          user.governorateId,
          "governorateName":
          user.governorateName,
          "branchId":
          user.branchId,
          "branchName":
          user.branchName,
          "stationId":
          user.stationId,
          "stationName":
          user.stationName,
          "position":
          user.position,
          "image":
          user.image,
          "active": true,
          "createdAt":
          user.createdAt
              .toIso8601String(),
          "updatedAt":
          user.updatedAt
              .toIso8601String(),
          "lastLogin":
          user.lastLogin
              .toIso8601String(),
        },
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
        "Create Firebase User Error: "
            "${e.code}",
      );

      rethrow;
    } catch (e) {
      debugPrint(
        "Create User Error: $e",
      );

      rethrow;
    } finally {
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
    }
  }
}