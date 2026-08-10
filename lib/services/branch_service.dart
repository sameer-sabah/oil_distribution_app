import 'package:firebase_database/firebase_database.dart';

import '../models/branch_model.dart';
import '../core/constants/user_roles.dart';
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

final String branchId =
branchesRef.push().key!;

final String managerId =
usersRef.push().key!;

final branch = BranchModel(
id: branchId,

governorateId: governorateId,

governorateName: governorateName,

name: branchName,

managerId: managerId,

managerName: managerName,

phone: phone,

email: email,

address: address,

governmentStations: 0,

privateStations: 0,

usersCount: 1,

active: true,

createdAt: DateTime.now(),

updatedAt: DateTime.now(),
);

await branchesRef
.child(branch.id)
.set(branch.toMap());

await usersRef.child(managerId).set({

"id": managerId,

"fullName": managerName,

"username": username,

"password": password,

"email": email,

"phone": phone,

  "role": "branchManager",

"governorateId": governorateId,

  "governorateName": governorateName,

"branchId": branch.id,

"branchName": branch.name,

"stationId": "",

"stationName": "",

"active": true,

"createdAt":
DateTime.now().toIso8601String(),
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


    if(!snapshot.exists)
      return;


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

  Future<void> deleteBranch(
      String branchId,
      ) async {

    // جلب بيانات الفرع قبل الحذف
    final branchSnapshot =
    await branchesRef.child(branchId).get();


    if(branchSnapshot.exists &&
        branchSnapshot.value != null){

      final branch =
      Map<String,dynamic>.from(
        branchSnapshot.value as Map,
      );


      final managerId =
          branch["managerId"] ?? "";


      // حذف حساب مدير الفرع
      if(managerId.toString().isNotEmpty){

        await usersRef
            .child(managerId)
            .remove();

      }

    }


    // حذف الفرع
    await branchesRef
        .child(branchId)
        .remove();

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