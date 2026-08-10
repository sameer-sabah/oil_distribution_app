import 'package:firebase_database/firebase_database.dart';

import '../models/governorate_model.dart';

class GovernorateService {
GovernorateService._();

static final GovernorateService instance =
GovernorateService._();

final FirebaseDatabase _database =
FirebaseDatabase.instance;

DatabaseReference get governoratesRef =>
_database.ref("governorates");

//=========================================
// إنشاء المحافظات لأول مرة
//=========================================

Future<void> createDefaultGovernorates() async {
final snapshot = await governoratesRef.get();

if (snapshot.exists) return;

final governorates = [

{"id":"anbar","name":"الأنبار","code":"ANB"},

{"id":"baghdad","name":"بغداد","code":"BGD"},

{"id":"basra","name":"البصرة","code":"BAS"},

{"id":"nineveh","name":"نينوى","code":"NIN"},

{"id":"kirkuk","name":"كركوك","code":"KIR"},

{"id":"salahaddin","name":"صلاح الدين","code":"SAL"},

{"id":"diyala","name":"ديالى","code":"DIY"},

{"id":"wasit","name":"واسط","code":"WAS"},

{"id":"babylon","name":"بابل","code":"BAB"},

{"id":"karbala","name":"كربلاء","code":"KAR"},

{"id":"najaf","name":"النجف","code":"NAJ"},

{"id":"qadisiyah","name":"القادسية","code":"QAD"},

{"id":"muthanna","name":"المثنى","code":"MUT"},

{"id":"dhiqar","name":"ذي قار","code":"DHI"},

{"id":"maysan","name":"ميسان","code":"MAY"},

{"id":"erbil","name":"أربيل","code":"ERB"},

{"id":"sulaymaniyah","name":"السليمانية","code":"SUL"},

{"id":"duhok","name":"دهوك","code":"DUH"},

];

for (final item in governorates) {

final governorate = GovernorateModel(

id: item["id"]!,

name: item["name"]!,

code: item["code"]!,

managerId: "",

managerName: "",

branchesCount: 0,

governmentStations: 0,

privateStations: 0,

active: true,

createdAt: DateTime.now(),

updatedAt: DateTime.now(),

);

await governoratesRef
.child(governorate.id)
.set(governorate.toMap());

}
}
//=========================================
// جلب جميع المحافظات
//=========================================

Future<List<GovernorateModel>>
getGovernorates() async {
final snapshot = await governoratesRef.get();

if (!snapshot.exists ||
snapshot.value == null) {
return [];
}

final data = Map<dynamic, dynamic>.from(
snapshot.value as Map,
);

return data.entries.map((e) {
return GovernorateModel.fromMap(
e.key.toString(),
Map<String, dynamic>.from(
e.value as Map,
),
);
}).toList();
}

//=========================================
// جلب محافظة واحدة
//=========================================

Future<GovernorateModel?> getGovernorate(
String governorateId,
) async {
final snapshot = await governoratesRef
.child(governorateId)
.get();

if (!snapshot.exists ||
snapshot.value == null) {
return null;
}

return GovernorateModel.fromMap(
governorateId,
Map<String, dynamic>.from(
snapshot.value as Map,
),
);
}

//=========================================
// البحث بواسطة الرمز
//=========================================

Future<GovernorateModel?>
getGovernorateByCode(
String code,
) async {
final governorates =
await getGovernorates();

try {
return governorates.firstWhere(
(g) =>
g.code.toLowerCase() ==
code.toLowerCase(),
);
} catch (_) {
return null;
}
}

//=========================================
// التحقق من وجود المحافظة
//=========================================

Future<bool> governorateExists(
String governorateId,
) async {
final snapshot =
await governoratesRef
.child(governorateId)
.get();

return snapshot.exists;
}
//=========================================
// إضافة محافظة
//=========================================

Future<void> addGovernorate(
GovernorateModel governorate,
) async {
await governoratesRef
.child(governorate.id)
.set(governorate.toMap());
}

//=========================================
// تعديل محافظة
//=========================================

Future<void> updateGovernorate(
GovernorateModel governorate,
) async {
await governoratesRef
.child(governorate.id)
.update(
governorate.copyWith(
updatedAt: DateTime.now(),
).toMap(),
);
}

//=========================================
// تحديث مدير الفرع
//=========================================

Future<void> updateManager({
required String governorateId,
required String managerId,
required String managerName,
}) async {
await governoratesRef
.child(governorateId)
.update({
"managerId": managerId,
"managerName": managerName,
"updatedAt":
DateTime.now().toIso8601String(),
});
}

//=========================================
// تحديث عدد الفروع
//=========================================

Future<void> updateBranchesCount({
required String governorateId,
required int branchesCount,
}) async {
await governoratesRef
.child(governorateId)
.update({
"branchesCount": branchesCount,
"updatedAt":
DateTime.now().toIso8601String(),
});
}

//=========================================
// تحديث عدد المحطات
//=========================================

Future<void> updateStationsCount({
required String governorateId,
required int governmentStations,
required int privateStations,
}) async {
await governoratesRef
.child(governorateId)
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
  // حذف محافظة
  //=========================================

  Future<void> deleteGovernorate(
      String governorateId,
      ) async {
    await governoratesRef
        .child(governorateId)
        .remove();
  }

  //=========================================
  // تفعيل المحافظة
  //=========================================

  Future<void> activateGovernorate(
      String governorateId,
      ) async {
    await governoratesRef
        .child(governorateId)
        .update({
      "active": true,
      "updatedAt":
      DateTime.now().toIso8601String(),
    });
  }

  //=========================================
  // إيقاف المحافظة
  //=========================================

  Future<void> deactivateGovernorate(
      String governorateId,
      ) async {
    await governoratesRef
        .child(governorateId)
        .update({
      "active": false,
      "updatedAt":
      DateTime.now().toIso8601String(),
    });
  }

  //=========================================
  // إعادة حفظ المحافظة كاملة
  //=========================================

  Future<void> saveGovernorate(
      GovernorateModel governorate,
      ) async {
    await governoratesRef
        .child(governorate.id)
        .set(governorate.toMap());
  }

  //=========================================
  // عدد المحافظات
  //=========================================

  Future<int> getGovernoratesCount() async {
    final governorates =
    await getGovernorates();

    return governorates.length;
  }

  //=========================================
  // المحافظات الفعالة
  //=========================================

  Future<List<GovernorateModel>>
  getActiveGovernorates() async {
    final governorates =
    await getGovernorates();

    return governorates
        .where((g) => g.active)
        .toList();
  }

  //=========================================
  // المحافظات غير الفعالة
  //=========================================

  Future<List<GovernorateModel>>
  getInactiveGovernorates() async {
    final governorates =
    await getGovernorates();

    return governorates
        .where((g) => !g.active)
        .toList();
  }
  //=========================================
// المحافظات الخاصة بالتسجيل
//=========================================

  Future<List<GovernorateModel>> getForRegister() async {

    final data =
    await getGovernorates();

    return data
        .where((g)=> g.active)
        .toList();

  }
}