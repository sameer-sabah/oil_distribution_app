import 'package:firebase_database/firebase_database.dart';

import '../models/branch_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
class BranchService {
  BranchService._();

  static final BranchService instance =
  BranchService._();

  final FirebaseDatabase _database =
      FirebaseDatabase.instance;

  DatabaseReference get branchesRef =>
      _database.ref("branches");

  DatabaseReference get usersRef =>
      _database.ref("users");

//=========================================
// إنشاء فرع جديد
//=========================================

  Future<void> addBranch({
    required String governorateId,
    required String governorateName,
    required String branchName,
    required String managerName,
    required String username,
    required String password,
    required String phone,
    required String email,
    required String address,
  }) async {
    final cleanUsername = username.trim();
    final cleanPassword = password.trim();
    final cleanContactEmail = email.trim();

    if (cleanUsername.isEmpty) {
      throw Exception("اسم المستخدم مطلوب");
    }

    if (cleanPassword.length < 6) {
      throw Exception("كلمة المرور يجب أن تكون 6 أحرف على الأقل");
    }

    // تسجيل الدخول في التطبيق يعتمد على username@opdc.iq،
    // لذلك يجب إنشاء حساب Firebase Authentication بنفس البريد.
    final authEmail = cleanUsername.contains('@')
        ? cleanUsername.toLowerCase()
        : "${cleanUsername.toLowerCase()}@opdc.iq";

    final branchId = branchesRef.push().key!;
    final now = DateTime.now();

    // 1) إنشاء حساب مدير الفرع الحقيقي في Firebase Authentication.
    // يتم الإنشاء من خلال Secondary Firebase App حتى تبقى جلسة مدير النظام فعالة.
    final manager = AppUser(
      id: "",
      fullName: managerName.trim(),
      username: cleanUsername,
      password: cleanPassword,
      email: authEmail,
      phone: phone.trim(),
      role: "branchManager",
      governorateId: governorateId,
      governorateName: governorateName,
      branchId: branchId,
      branchName: branchName.trim(),
      stationId: "",
      stationName: "",
      position: "مدير الفرع",
      image: "",
      active: true,
      createdAt: now,
      updatedAt: now,
      lastLogin: now,
    );

    final createdManager =
    await AuthService.instance.createUserAccount(user: manager);

    if (createdManager == null || createdManager.id.isEmpty) {
      throw Exception("فشل إنشاء حساب مدير الفرع");
    }

    // مهم: هذا هو UID الحقيقي من Firebase Authentication،
    // وليس push key عشوائياً.
    final managerId = createdManager.id;

    final branch = BranchModel(
      id: branchId,
      governorateId: governorateId,
      governorateName: governorateName,
      name: branchName.trim(),
      managerId: managerId,
      managerName: managerName.trim(),
      phone: phone.trim(),
      email: cleanContactEmail,
      address: address.trim(),
      governmentStations: 0,
      privateStations: 0,
      usersCount: 1,
      active: true,
      createdAt: now,
      updatedAt: now,
    );

    final managerData = manager.toMap();
    managerData["id"] = managerId;
    managerData["uid"] = managerId;
    managerData["email"] = authEmail;

    // الاحتفاظ بالبريد الذي أدخله مدير النظام كبريد تواصل،
    // بينما email يبقى بريد تسجيل الدخول المطابق لطريقة login الحالية.
    if (cleanContactEmail.isNotEmpty &&
        cleanContactEmail.toLowerCase() != authEmail) {
      managerData["contactEmail"] = cleanContactEmail;
    }

    // 2) حفظ الفرع وملف مديره بعملية واحدة، حتى لا يتكوّن فرع
    // بدون مستخدم أو مستخدم بدون ربط صحيح بالفرع.
    await _database.ref().update({
      "branches/$branchId": branch.toMap(),
      "users/$managerId": managerData,
    });
  }
//=========================================
// جلب جميع الفروع
//=========================================

  Future<List<BranchModel>> getBranches() async {
    final snapshot = await branchesRef.get();

    if (!snapshot.exists || snapshot.value == null) {
      return [];
    }

    final data = Map<dynamic, dynamic>.from(
      snapshot.value as Map,
    );

    return data.entries.map((e) {
      return BranchModel.fromMap(
        e.key.toString(),
        Map<String, dynamic>.from(
          e.value as Map,
        ),
      );
    }).toList();
  }
//=========================================
// جلب فرع واحد
//=========================================

  Future<BranchModel?> getBranch(
      String branchId,
      ) async {
    final snapshot =
    await branchesRef.child(branchId).get();

    if (!snapshot.exists || snapshot.value == null) {
      return null;
    }

    return BranchModel.fromMap(
      branchId,
      Map<String, dynamic>.from(
        snapshot.value as Map,
      ),
    );
  }

//=========================================
// جلب فروع محافظة معينة
//=========================================

  Future<List<BranchModel>> getGovernorateBranches(
      String governorateId,
      ) async {
    final branches = await getBranches();

    return branches.where((branch) {
      return branch.governorateId ==
          governorateId;
    }).toList();
  }

//=========================================
// التحقق من وجود الفرع
//=========================================

  Future<bool> branchExists(
      String branchId,
      ) async {
    final snapshot =
    await branchesRef.child(branchId).get();

    return snapshot.exists;
  }

//=========================================
// تحديث فرع
//=========================================

  Future<void> updateBranch(
      BranchModel branch,
      ) async {
    await branchesRef
        .child(branch.id)
        .update(
      branch.copyWith(
        updatedAt: DateTime.now(),
      ).toMap(),
    );
  }
  Future<void> updateDefaultBranchesFields() async {


    final snapshot =
    await branchesRef.get();


    if(!snapshot.exists) {
      return;
    }


    final data =
    Map<dynamic,dynamic>.from(
        snapshot.value as Map
    );


    for(final id in data.keys){


      await branchesRef
          .child(id.toString())
          .update({

        "governmentStations":0,

        "privateStations":0,

        "usersCount":0,

        "updatedAt":
        DateTime.now()
            .toIso8601String(),

      });


    }


  }
//=========================================
// تحديث مدير الفرع
//=========================================

  Future<void> updateManager({
    required String branchId,
    required String managerId,
    required String managerName,
  }) async {
    await branchesRef
        .child(branchId)
        .update({
      "managerId": managerId,
      "managerName": managerName,
      "updatedAt":
      DateTime.now().toIso8601String(),
    });
  }

//=========================================
// تحديث عدد المحطات
//=========================================

  Future<void> updateStationsCount({
    required String branchId,
    required int governmentStations,
    required int privateStations,
  }) async {
    await branchesRef
        .child(branchId)
        .update({
      "governmentStations":
      governmentStations,
      "privateStations":
      privateStations,
      "updatedAt":
      DateTime.now().toIso8601String(),
    });
  }

//=========================================
// تحديث عدد المستخدمين
//=========================================

  Future<void> updateUsersCount({
    required String branchId,
    required int usersCount,
  }) async {
    await branchesRef
        .child(branchId)
        .update({
      "usersCount": usersCount,
      "updatedAt":
      DateTime.now().toIso8601String(),
    });
  }

//=========================================
// تفعيل الفرع
//=========================================

  Future<void> activateBranch(
      String branchId,
      ) async {
    await branchesRef
        .child(branchId)
        .update({
      "active": true,
      "updatedAt":
      DateTime.now().toIso8601String(),
    });
  }

//=========================================
// إيقاف الفرع
//=========================================

  Future<void> deactivateBranch(
      String branchId,
      ) async {
    await branchesRef
        .child(branchId)
        .update({
      "active": false,
      "updatedAt":
      DateTime.now().toIso8601String(),
    });
  }
  //=========================================
  // حذف فرع
  //=========================================

  Future<void> deleteBranch(String branchId) async {
    final updates = <String, Object?>{};

    // =========================================================
    // حذف مدير الفرع المسجل داخل بيانات الفرع
    // =========================================================
    final branchSnapshot = await branchesRef.child(branchId).get();

    if (branchSnapshot.exists && branchSnapshot.value != null) {
      final branch = Map<String, dynamic>.from(
        branchSnapshot.value as Map,
      );

      final managerId = branch["managerId"]?.toString() ?? "";

      if (managerId.isNotEmpty) {
        updates["users/$managerId"] = null;
      }
    }

    // =========================================================
    // حذف جميع المحطات التابعة للفرع
    // =========================================================
    final stationsSnapshot = await _database
        .ref("stations")
        .orderByChild("branchId")
        .equalTo(branchId)
        .get();

    if (stationsSnapshot.exists &&
        stationsSnapshot.value != null) {
      final stations = Map<dynamic, dynamic>.from(
        stationsSnapshot.value as Map,
      );

      for (final entry in stations.entries) {
        updates["stations/${entry.key}"] = null;
      }
    }

    // =========================================================
    // حذف المحطات المعلقة التابعة للفرع
    // =========================================================
    final pendingStationsSnapshot = await _database
        .ref("pendingStations")
        .orderByChild("branchId")
        .equalTo(branchId)
        .get();

    if (pendingStationsSnapshot.exists &&
        pendingStationsSnapshot.value != null) {
      final pendingStations =
      Map<dynamic, dynamic>.from(
        pendingStationsSnapshot.value as Map,
      );

      for (final entry in pendingStations.entries) {
        updates["pendingStations/${entry.key}"] = null;
      }
    }

    // =========================================================
    // حذف حسابات المستخدمين المرتبطة بالفرع
    // مدير الفرع + مدراء المحطات
    // =========================================================
    final usersSnapshot = await usersRef
        .orderByChild("branchId")
        .equalTo(branchId)
        .get();

    if (usersSnapshot.exists &&
        usersSnapshot.value != null) {
      final users = Map<dynamic, dynamic>.from(
        usersSnapshot.value as Map,
      );

      for (final entry in users.entries) {
        final data = Map<String, dynamic>.from(
          entry.value as Map,
        );

        final role = data["role"]?.toString() ?? "";

        if (role == "branchManager" ||
            role == "branch_manager" ||
            role == "stationManager" ||
            role == "station_manager" ||
            role == "station") {
          updates["users/${entry.key}"] = null;
        }
      }
    }

    // =========================================================
    // حذف الفرع نفسه
    // =========================================================
    updates["branches/$branchId"] = null;

    // تنفيذ الحذف كله دفعة واحدة
    await _database.ref().update(updates);
  }

  //=========================================
  // إعادة حفظ الفرع بالكامل
  //=========================================

  Future<void> saveBranch(
      BranchModel branch,
      ) async {
    await branchesRef
        .child(branch.id)
        .set(branch.toMap());
  }

  //=========================================
  // عدد الفروع
  //=========================================

  Future<int> getBranchesCount() async {
    final branches = await getBranches();

    return branches.length;
  }

  //=========================================
  // الفروع الفعالة
  //=========================================

  Future<List<BranchModel>>
  getActiveBranches() async {
    final branches = await getBranches();

    return branches
        .where((branch) => branch.active)
        .toList();
  }

  //=========================================
  // الفروع غير الفعالة
  //=========================================

  Future<List<BranchModel>>
  getInactiveBranches() async {
    final branches = await getBranches();

    return branches
        .where((branch) => !branch.active)
        .toList();
  }

  //=========================================
  // البحث باسم الفرع
  //=========================================

  Future<List<BranchModel>>
  searchBranches(
      String keyword,
      ) async {
    final branches = await getBranches();

    return branches.where((branch) {
      return branch.name
          .toLowerCase()
          .contains(keyword.toLowerCase());
    }).toList();
  }
  //=========================================
// إنشاء الفروع الافتراضية
//=========================================

  Future<void> createDefaultBranches() async {


    final snapshot =
    await branchesRef.get();


    if(snapshot.exists) return;



    final branches = [

      {
        "id":"branch_anbar",
        "name":"فرع الأنبار",
        "governorateId":"anbar",
        "governorateName":"الأنبار",
      },


      {
        "id":"branch_baghdad",
        "name":"فرع بغداد",
        "governorateId":"baghdad",
        "governorateName":"بغداد",
      },


      {
        "id":"branch_basra",
        "name":"فرع البصرة",
        "governorateId":"basra",
        "governorateName":"البصرة",
      },


      {
        "id":"branch_nineveh",
        "name":"فرع نينوى",
        "governorateId":"nineveh",
        "governorateName":"نينوى",
      },


      {
        "id":"branch_kirkuk",
        "name":"فرع كركوك",
        "governorateId":"kirkuk",
        "governorateName":"كركوك",
      },


      {
        "id":"branch_salahaddin",
        "name":"فرع صلاح الدين",
        "governorateId":"salahaddin",
        "governorateName":"صلاح الدين",
      },

    ];



    for(final item in branches){

      await branchesRef
          .child(item["id"]!)
          .set({

        "id": item["id"],

        "name": item["name"],

        "governorateId":
        item["governorateId"],

        "governorateName":
        item["governorateName"],


        "governmentStations":
        0,


        "privateStations":
        0,


        "usersCount":
        0,


        "managerId":
        "",


        "managerName":
        "",


        "phone":
        "",


        "email":
        "",


        "address":
        "",


        "active":
        true,


        "createdAt":
        DateTime.now()
            .toIso8601String(),


        "updatedAt":
        DateTime.now()
            .toIso8601String(),

      });
    }

  }
}