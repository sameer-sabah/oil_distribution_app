import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/user_roles.dart';
import '../models/user_model.dart';
import 'push_notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  debugPrint("Reading Firebase...");

  final snapshot = await usersRef.get();

  debugPrint("Firebase response received");

  if (!snapshot.exists || snapshot.value == null) {
    return null;
  }

final data = Map<dynamic, dynamic>.from(
snapshot.value as Map,
);

  for (final item in data.entries) {
    final user = AppUser.fromMap(
      item.key.toString(),
      Map<String, dynamic>.from(
        item.value as Map,
      ),
    );

    if (user.username == username &&
        user.password == password &&
        user.active) {

      currentUser = user;

      // حفظ FCM Token
      try {
        await PushNotificationService.instance
            .saveCurrentUserToken(
          userId: user.id,
        );
      } catch (e) {
        debugPrint(
          "FCM Token save error: $e",
        );
      }

      return user;
    }
  }

return null;
}

//====================================
// تسجيل الخروج
//====================================

Future<void> logout() async {
currentUser = null;
}
//====================================
// إنشاء مدير النظام الافتراضي
//====================================

Future<void> createDefaultAdmin() async {
final snapshot = await usersRef.get();

if (snapshot.exists && snapshot.value != null) {
final data = Map<dynamic, dynamic>.from(
snapshot.value as Map,
);

for (final item in data.entries) {
final uid = item.key.toString();

final map = Map<String, dynamic>.from(
item.value as Map,
);

if ((map["role"] ?? "") == UserRoles.admin) {
await usersRef.child(uid).update({
"fullName":
map["fullName"] ??
"مدير النظام",
"username":
map["username"] ?? "admin",
"password":
map["password"] ?? "123456",
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
DateTime.now().toIso8601String(),
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

await usersRef.child(admin.id).set(
admin.toMap(),
);
}

//====================================
// ترقية المستخدمين القدامى
//====================================

Future<void> upgradeOldUsers() async {
final snapshot = await usersRef.get();

if (!snapshot.exists || snapshot.value == null) {
return;
}

final data = Map<dynamic, dynamic>.from(
snapshot.value as Map,
);

for (final item in data.entries) {
final uid = item.key.toString();

final map = Map<String, dynamic>.from(
item.value as Map,
);

final updates = <String, dynamic>{};

if (!map.containsKey("fullName")) {
updates["fullName"] = "";
}

if (!map.containsKey("username")) {
updates["username"] = uid;
}

if (!map.containsKey("password")) {
updates["password"] = "123456";
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
  updates["station.governorateName"] = "";
}

if (!map.containsKey("position")) {
  updates["position"] = "";
}

if (!map.containsKey("image")) {
  updates["image"] = "";
}

if (!map.containsKey("updatedAt")) {
  updates["updatedAt"] =
      DateTime.now().toIso8601String();
}

if (!map.containsKey("lastLogin")) {
  updates["lastLogin"] =
      DateTime.now().toIso8601String();
}

if (!map.containsKey("active")) {
updates["active"] = true;
}

if (!map.containsKey("createdAt")) {
updates["createdAt"] =
DateTime.now().toIso8601String();
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

  bool get isLoggedIn => currentUser != null;

  bool get isAdmin =>
      currentUser?.role == UserRoles.admin;

  bool get isBranchManager =>
      currentUser?.role == UserRoles.branchManager;

  bool get isDistributionManager =>
      currentUser?.role == UserRoles.distributionManager;

  bool get isStationManager =>
      currentUser?.role == UserRoles.stationManager;

  //====================================
  // إضافة مستخدم
  //====================================

  Future<void> addUser(AppUser user) async {
    await usersRef
        .child(user.id)
        .set(user.toMap());
  }

  //====================================
  // تحديث مستخدم
  //====================================

  Future<void> updateUser(AppUser user) async {
    await usersRef
        .child(user.id)
        .update(user.toMap());
  }

  //====================================
  // حذف مستخدم
  //====================================

  Future<void> deleteUser(String id) async {
    await usersRef
        .child(id)
        .remove();
  }

  //====================================
  // جلب مستخدم واحد
  //====================================

  Future<AppUser?> getUserById(String id) async {
    final snapshot = await usersRef.child(id).get();

    if (!snapshot.exists || snapshot.value == null) {
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
  // جلب جميع المستخدمين
  //====================================

  Future<List<AppUser>> getUsers() async {
    final snapshot = await usersRef.get();

    if (!snapshot.exists || snapshot.value == null) {
      return [];
    }

    final data = Map<dynamic, dynamic>.from(
      snapshot.value as Map,
    );

    return data.entries.map((e) {
      return AppUser.fromMap(
        e.key.toString(),
        Map<String, dynamic>.from(
          e.value as Map,
        ),
      );
    }).toList();
  }
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}