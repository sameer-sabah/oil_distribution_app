import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/station.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';


class StationService {
  StationService._();
  static final StationService instance =
  StationService._();
  final FirebaseDatabase database =
      FirebaseDatabase.instance;


  DatabaseReference get stationsRef =>
      database.ref("stations");


  DatabaseReference get pendingRef =>
      database.ref("pendingStations");
  DatabaseReference get usersRef =>
      database.ref("users");
  //================================================
// إضافة طلب تسجيل محطة جديد
//================================================
  Future<void> addPendingStation(
      Map<String, dynamic> data,
      ) async {

    // =================================================
    // تسجيل مجهول فقط لإرسال طلب تسجيل المحطة
    // =================================================
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }

    final authUser =
        FirebaseAuth.instance.currentUser;

    if (authUser == null) {
      throw Exception(
        "تعذر إنشاء جلسة إرسال الطلب",
      );
    }

    // =================================================
    // التحقق من بيانات الطلب
    // =================================================

    final branchId =
        data["branchId"]?.toString().trim() ?? "";

    final branchName =
        data["branchName"]?.toString().trim() ?? "";

    final stationName =
        data["name"]?.toString().trim() ?? "";

    if (stationName.isEmpty) {
      throw Exception(
        "اسم المحطة غير موجود",
      );
    }

    if (branchId.isEmpty) {
      throw Exception(
        "يجب اختيار الفرع قبل إرسال الطلب",
      );
    }

    if (branchName.isEmpty) {
      throw Exception(
        "اسم الفرع غير موجود",
      );
    }

    // =================================================
    // إنشاء معرف طلب
    // =================================================

    final id =
        pendingRef.push().key;

    if (id == null || id.isEmpty) {
      throw Exception(
        "فشل إنشاء معرف طلب المحطة",
      );
    }

    // =================================================
    // تثبيت بيانات الطلب
    // =================================================

    data["id"] =
        id;

    data["branchId"] =
        branchId;

    data["branchName"] =
        branchName;

    data["status"] =
    "pending";

    data["approved"] =
    false;

    data["active"] =
    false;

    data["createdAt"] =
        data["createdAt"] ??
            DateTime.now()
                .toIso8601String();

    // =================================================
    // حفظ الطلب
    // =================================================

    await pendingRef
        .child(id)
        .set(data);
  }
//================================================
// جلب طلبات التسجيل
//================================================

  Future<List<Map<String,dynamic>>>
  getPendingStationRequests() async {

    final snapshot =
    await pendingRef.get();

    if(!snapshot.exists ||
        snapshot.value == null){

      return [];

    }

    final data =
    Map<dynamic,dynamic>.from(
        snapshot.value as Map
    );

    final requests = <Map<String,dynamic>>[];

    for(final entry in data.entries){

      if(entry.value is! Map){
        continue;
      }

      final item =
      Map<String,dynamic>.from(
          entry.value as Map
      );

      item["id"] =
          entry.key.toString();

      final status =
          item["status"]?.toString() ?? "pending";

// القائمة تعرض الطلبات التي لم تتم معالجتها فقط.
      if(status != "pending"){
        continue;
      }

      requests.add(item);

    }

    return requests;

  }

//================================================
// الموافقة على طلب محطة
//================================================

  Future<Map<String,dynamic>>
  approveRegistration({

    required Map<String,dynamic> request,

  }) async {

    final stationId =
        request["id"]?.toString().trim() ?? "";

    if(stationId.isEmpty){
      throw Exception("معرف طلب المحطة غير موجود");
    }

// نقرأ الطلب من Firebase مرة ثانية حتى لا نعتمد
// على نسخة قديمة موجودة في الشاشة.
    final pendingSnapshot =
    await pendingRef.child(stationId).get();

    if(!pendingSnapshot.exists ||
        pendingSnapshot.value == null){
      throw Exception("طلب المحطة غير موجود أو تمت معالجته مسبقاً");
    }

    final pendingData =
    Map<String,dynamic>.from(
        pendingSnapshot.value as Map
    );

    final currentStatus =
        pendingData["status"]?.toString() ?? "pending";

    if(currentStatus != "pending"){
      throw Exception("هذا الطلب تمت معالجته مسبقاً");
    }

// نعمل نسخة حتى لا نغيّر request الموجود في الشاشة.
    final stationData =
    Map<String,dynamic>.from(pendingData);

    stationData.remove("id");

// بيانات المحطة
    stationData["approved"] = true;
    stationData["active"] = true;
    stationData["status"] = "approved";

    stationData["branchId"] =
        stationData["branchId"] ?? "";

    stationData["branchName"] =
        stationData["branchName"] ?? "";

    stationData["governorateId"] =
        stationData["governorateId"] ?? "";

    stationData["governorateName"] =
        stationData["governorateName"] ?? "";

    // توحيد نوع المحطة قبل حفظها حتى تظهر بعد الموافقة
    // في فولدر الحكومية أو الأهلية بصورة صحيحة.
    final rawStationType =
        stationData["stationType"]
            ?.toString()
            .trim() ?? "";

    final normalizedStationType =
    rawStationType == "government" ||
        rawStationType == "حكومية" ||
        rawStationType == "حكومي"
        ? "حكومية"
        : rawStationType == "private" ||
        rawStationType == "أهلية" ||
        rawStationType == "اهلية" ||
        rawStationType == "خاصة"
        ? "أهلية"
        : rawStationType.isEmpty
        ? "حكومية"
        : rawStationType;

    stationData["stationType"] =
        normalizedStationType;

    stationData["workingStatus"] =
        stationData["workingStatus"] ?? "مفتوحة";

    stationData["updatedAt"] =
        DateTime.now().toIso8601String();

    final branchId =
        stationData["branchId"]?.toString().trim() ?? "";

    final managerName =
        stationData["managerName"]?.toString().trim() ?? "";

    final stationName =
        stationData["name"]?.toString().trim() ?? "";

    final phone =
        stationData["phone"]?.toString().trim() ?? "";

    if(branchId.isEmpty){
      throw Exception("معرف الفرع غير موجود في طلب المحطة");
    }

    if(stationName.isEmpty){
      throw Exception("اسم المحطة غير موجود");
    }

    if(managerName.isEmpty){
      throw Exception("اسم مدير المحطة غير موجود");
    }

//=====================================
// إنشاء بيانات حساب مدير المحطة
//=====================================

    final String stationPrefix =
    stationData["stationType"] == "حكومية"
        ? "G"
        : "P";

    final password =
        "$stationPrefix${DateTime.now()
        .millisecondsSinceEpoch
        .remainder(100000)
        .toString()
        .padLeft(7, '0')}";

    final username =
        "OPDC${DateTime.now()
        .millisecondsSinceEpoch
        .remainder(100000)
        .toString()
        .padLeft(4, '0')}";

    final emailFromRequest =
        stationData["email"]?.toString().trim() ?? "";

    final email =
    emailFromRequest.isNotEmpty
        ? emailFromRequest
        : "${username.toLowerCase()}@opdc.iq";

    final now = DateTime.now();

// إنشاء حساب Firebase Authentication الحقيقي
// باستخدام AuthService الموجود بالمشروع.
// AuthService يستخدم Secondary Firebase App، لذلك
// حساب مدير الفرع الحالي لا يخرج من الجلسة.
    final stationManager = AppUser(
      id: "",
      fullName: managerName,
      username: username,
      password: password,
      email: email,
      phone: phone,
      role: "stationManager",
      governorateId:
      stationData["governorateId"]?.toString() ?? "",
      governorateName:
      stationData["governorateName"]?.toString() ?? "",
      branchId: branchId,
      branchName:
      stationData["branchName"]?.toString() ?? "",
      stationId: stationId,
      stationName: stationName,
      position: "مدير محطة",
      image: "",
      active: true,
      createdAt: now,
      updatedAt: now,
      lastLogin: now,
    );

    final createdManager =
    await AuthService.instance.createUserAccount(
      user: stationManager,
    );

    if (createdManager == null) {
      throw Exception(
        "فشل إنشاء حساب مدير المحطة",
      );
    }

    final managerUid =
        createdManager.id;

    final managerData =
    stationManager.toMap();

    managerData.remove("password");

    managerData["uid"] =
        managerUid;

    managerData["active"] =
    true;

// ربط مدير المحطة بالمحطة
    stationData["managerUid"] = managerUid;
    stationData["managerName"] = managerName;
    stationData["managerPhone"] = phone;
    stationData["managerEmail"] = email;
    stationData["updatedAt"] =
        DateTime.now().toIso8601String();

// =====================================================
// تنفيذ كتابات الموافقة دفعة واحدة
//
// سابقاً كانت هذه العمليات تُرسل إلى Firebase واحدة بعد الأخرى:
// 1- حفظ المستخدم
// 2- حفظ المحطة
// 3- تحديث عداد الفرع
// 4- حذف الطلب
//
// الآن تُرسل كلها في update واحد متعدد المسارات.
// النتيجة التشغيلية نفسها، لكن بعدد أقل من رحلات الشبكة
// وبشكل ذري: إما تنجح المجموعة أو تفشل.
// =====================================================

    final Map<String, Object?> approvalUpdates = {
      "users/$managerUid":
      managerData,

      "stations/$stationId":
      stationData,

      "pendingStations/$stationId":
      null,
    };

    if (stationData["stationType"] == "حكومية") {
      approvalUpdates[
      "branches/$branchId/governmentStations"
      ] = ServerValue.increment(1);
    } else {
      approvalUpdates[
      "branches/$branchId/privateStations"
      ] = ServerValue.increment(1);
    }

    await database
        .ref()
        .update(approvalUpdates);

// =====================================================
// إنشاء رسالة WhatsApp في قاعدة البيانات
// =====================================================
// هذه Queue؛ الإرسال الفعلي عبر Meta يحتاج Backend/Cloud Function.

// إرجاع بيانات الحساب للشاشة
    return {
      "username": username,
      "password": password,
      "stationName": stationName,
      "email": email,
      "managerUid": managerUid,
      "stationId": stationId,
      "phone": phone,
      "branchId": branchId,
    };

  }
//================================================
// جلب جميع المحطات
//================================================

  Future<List<Station>> getStations() async {


    final snapshot =
    await stationsRef.get();



    if(!snapshot.exists ||
        snapshot.value == null){

      return [];

    }



    final data =
    Map<dynamic,dynamic>.from(
        snapshot.value as Map
    );



    return data.entries.map((e){

      debugPrint("اسم المحطة: ${e.key}");
      debugPrint("وقت التحديث: ${(e.value as Map)["updatedAt"]}");
      return Station.fromMap(

        e.key.toString(),


        Map<String,dynamic>.from(
            e.value as Map
        ),


      );


    }).toList();


  }





//================================================
// جلب محطة واحدة
//================================================

  Future<Station?> getStation(
      String id
      ) async {


    final snapshot =
    await stationsRef
        .child(id)
        .get();



    if(!snapshot.exists ||
        snapshot.value == null){

      return null;

    }



    return Station.fromMap(

      id,


      Map<String,dynamic>.from(
          snapshot.value as Map
      ),


    );


  }


  String generateStationUsername({
    required String branchName,
    required String stationType,
    required int number,
  })
  {


    String branch =
    branchName
        .toLowerCase()
        .replaceAll(" ", "")
        .replaceAll("فرع", "");


    String type =
    stationType == "حكومية"
        ? "H"
        : "A";


    String serial =
    number
        .toString()
        .padLeft(4,"0");


    return "$branch$type$serial";

  }



//================================================
// تعديل محطة
//================================================

  Future<void> updateStation(
      Station station,
      ) async {

    final stationId = station.id.trim();

    if (stationId.isEmpty ||
        stationId == "null") {
      throw Exception(
        "معرف المحطة غير موجود، لا يمكن تعديل المحطة",
      );
    }

    // قراءة المحطة الأصلية حتى نحافظ على branchId
    final snapshot =
    await stationsRef
        .child(stationId)
        .get();

    if (!snapshot.exists ||
        snapshot.value == null ||
        snapshot.value is! Map) {
      throw Exception(
        "المحطة غير موجودة في قاعدة البيانات",
      );
    }

    final existing =
    Map<String, dynamic>.from(
      snapshot.value as Map,
    );

    final originalBranchId =
        existing["branchId"]?.toString().trim() ?? "";

    if (originalBranchId.isEmpty) {
      throw Exception(
        "المحطة لا تحتوي على branchId صحيح",
      );
    }

    final updatedData =
    Map<String, dynamic>.from(
      station.toMap(),
    );

    // الحفاظ على الفرع الأصلي
    updatedData["branchId"] =
        originalBranchId;

    updatedData["updatedAt"] =
        DateTime.now().toIso8601String();

    await stationsRef
        .child(stationId)
        .update(updatedData);
  }


//================================================
// حذف محطة
//================================================

  Future<void> deleteStation(
      String id,
      ) async {

    final stationId = id.trim();

    if (stationId.isEmpty ||
        stationId == "null") {

      throw Exception(
        "معرف المحطة غير موجود، لا يمكن حذف المحطة",
      );
    }

    //================================================
    // قراءة المحطة الأصلية
    //================================================

    final stationSnapshot =
    await stationsRef
        .child(stationId)
        .get();

    if (!stationSnapshot.exists ||
        stationSnapshot.value == null ||
        stationSnapshot.value is! Map) {

      throw Exception(
        "المحطة غير موجودة في قاعدة البيانات",
      );
    }

    final station =
    Map<String, dynamic>.from(
      stationSnapshot.value as Map,
    );

    final managerUid =
        station["managerUid"]?.toString().trim() ?? "";

    final branchId =
        station["branchId"]?.toString().trim() ?? "";

    final stationType =
        station["stationType"]?.toString().trim() ?? "";

    if (branchId.isEmpty) {

      throw Exception(
        "المحطة لا تحتوي على branchId صحيح",
      );
    }

    //================================================
    // 1 - حذف المحطة
    //================================================

    await stationsRef
        .child(stationId)
        .remove();

    //================================================
    // 2 - حذف طلب التسجيل إن كان موجوداً فقط
    //
    // مهم جداً:
    // لا ننفذ remove() إذا لم يكن الطلب موجوداً،
    // حتى لا نحصل على Permission denied.
    //================================================

    try {

      final pendingSnapshot =
      await pendingRef
          .child(stationId)
          .get();

      if (pendingSnapshot.exists) {

        await pendingRef
            .child(stationId)
            .remove();
      }

    } catch (e) {

      debugPrint(
        "تعذر حذف طلب التسجيل إن وجد: $e",
      );

      // لا نوقف حذف المحطة بسبب pendingStations
    }

    //================================================
    // 3 - تعطيل حساب مدير المحطة بدلاً من حذفه
    //================================================

    if (managerUid.isNotEmpty) {

      try {

        await usersRef
            .child(managerUid)
            .update({

          "active": false,

          "stationId": "",

          "updatedAt":
          DateTime.now().toIso8601String(),

        });

      } catch (e) {

        debugPrint(
          "تعذر تعطيل حساب مدير المحطة: $e",
        );
      }
    }

    //================================================
    // 4 - تحديث عداد الفرع
    //================================================

    if (stationType == "حكومية") {

      await database
          .ref("branches")
          .child(branchId)
          .update({

        "governmentStations":
        ServerValue.increment(-1),

      });

    } else if (
    stationType == "أهلية" ||
        stationType == "خاصة") {

      await database
          .ref("branches")
          .child(branchId)
          .update({

        "privateStations":
        ServerValue.increment(-1),

      });
    }
  }
//================================================
// إضافة محطة مباشرة
//================================================

  Future<void> addStation(
      Station station
      ) async {

    final stationId = station.id.trim();

    if (stationId.isEmpty ||
        stationId == "null") {
      throw Exception(
        "معرف المحطة غير موجود، لا يمكن إضافة المحطة",
      );
    }

    final data =
    Map<String, dynamic>.from(
      station.toMap(),
    );

    if ((data["branchId"]?.toString().trim() ?? "")
        .isEmpty) {
      throw Exception(
        "معرف الفرع غير موجود في بيانات المحطة",
      );
    }

    await stationsRef
        .child(stationId)
        .set(data);
  }
// =====================================================
// تحديث المنتجات المعتمدة في المحطة
// =====================================================

  Future<void> updateSupportedProducts({
    required String stationId,
    required Map<String, bool> supportedProducts,
  }) async {

    final cleanStationId =
    stationId.trim();

    if (cleanStationId.isEmpty ||
        cleanStationId == "null") {

      throw Exception(
        "معرف المحطة غير موجود",
      );
    }

    await stationsRef
        .child(cleanStationId)
        .update({

      "supportedProducts":
      supportedProducts,

      "updatedAt":
      DateTime.now()
          .toIso8601String(),

    });
  }

//================================================
// كلمة مرور
//================================================

  String generatePassword(){

    final random =
    DateTime.now()
        .millisecondsSinceEpoch
        .toString()
        .substring(7);

    return "OPD@$random";
  }


//================================================
// تحديث الوقود
//================================================

  Future<void> updateFuel({

    required String stationId,

    required int regular95,

    required int improved95,

    required int super95,

    required int diesel,

    required int whiteOil,

    required int lpg,

    required String workingStatus,

  }) async {

    final cleanStationId =
    stationId.trim();

    if (cleanStationId.isEmpty ||
        cleanStationId == "null") {
      throw Exception(
        "معرف المحطة غير موجود، لا يمكن تحديث الوقود",
      );
    }

    await stationsRef
        .child(cleanStationId)
        .update({

      "regular95":
      regular95,

      "improved95":
      improved95,

      "super95":
      super95,

      "diesel":
      diesel,

      "whiteOil":
      whiteOil,

      "lpg":
      lpg,

      "workingStatus":
      workingStatus,

      "updatedAt":
      DateTime.now()
          .toIso8601String(),

    });
  }
//================================================
// تحديث حالة المحطة
//================================================

  Future<void> updateStatus({

    required String stationId,

    required String status,

  }) async {

    final cleanStationId = stationId.trim();

    if (cleanStationId.isEmpty ||
        cleanStationId == "null") {
      throw Exception(
        "معرف المحطة غير موجود، لا يمكن تحديث الحالة",
      );
    }

    await stationsRef
        .child(cleanStationId)
        .update({

      "workingStatus":
      status,


      "updatedAt":
      DateTime.now()
          .toIso8601String(),

    });


  }





//================================================
// المحطات المعتمدة
//================================================

  Future<List<Station>>
  getApprovedStations() async {


    final stations =
    await getStations();



    return stations.where((station){


      return station.approved &&
          station.active;


    }).toList();


  }





//================================================
// عدد المحطات
//================================================

  Future<int> getStationsCount() async {

    // عداد فقط:
    // لا نحتاج تحويل كل محطة إلى Station model ولا تشغيل
    // منطق getStations() والـ debugPrint لكل سجل.
    //
    // ملاحظة: Realtime Database لا يوفر aggregate count
    // حقيقياً من العميل، لذلك snapshot ما زال يمثل عقدة stations،
    // لكن هذا المسار أخف CPU وذاكرة من بناء List<Station> كاملة.
    final snapshot =
    await stationsRef.get();

    if (!snapshot.exists ||
        snapshot.value == null) {
      return 0;
    }

    return snapshot.children.length;
  }





//================================================
// جلب المحطات الفعالة للمواطن فقط - تحسين قابلية التحمل
//================================================
//
// مهم:
// getStations() و stationsStream() الأصليات بقيت كما هي
// لأن شاشات الإدارة قد تحتاج جميع المحطات.
// هاتان الدالتان مخصصتان لشاشة المواطن فقط.
//================================================

  Future<List<Station>> getCitizenStations() async {

    final snapshot =
    await stationsRef
        .orderByChild("active")
        .equalTo(true)
        .get();

    if(!snapshot.exists ||
        snapshot.value == null){

      return [];

    }

    final data =
    Map<dynamic,dynamic>.from(
        snapshot.value as Map
    );

    return data.entries.map((e){

      return Station.fromMap(

        e.key.toString(),

        Map<String,dynamic>.from(
            e.value as Map
        ),

      );

    }).toList();

  }


  Stream<List<Station>>
  citizenStationsStream(){

    return stationsRef
        .orderByChild("active")
        .equalTo(true)
        .onValue
        .map((event){

      if(event.snapshot.value == null){

        return <Station>[];

      }

      final data =
      Map<dynamic,dynamic>.from(

        event.snapshot.value as Map,

      );

      return data.entries.map((e){

        return Station.fromMap(

          e.key.toString(),

          Map<String,dynamic>.from(

            e.value as Map,

          ),

        );

      }).toList();

    });

  }



//================================================
// بث مباشر للمحطات
//================================================

  Stream<List<Station>>
  stationsStream(){


    return stationsRef
        .onValue
        .map((event){



      if(event.snapshot.value == null){

        return <Station>[];

      }



      final data =
      Map<dynamic,dynamic>.from(

        event.snapshot.value as Map,

      );



      return data.entries.map((e){


        return Station.fromMap(

          e.key.toString(),


          Map<String,dynamic>.from(

            e.value as Map,

          ),


        );


      }).toList();



    });


  }






//================================================
// محطات فرع معين
//================================================

  Future<List<Station>>
  getBranchStations(
      String branchId
      ) async {



    final stations =
    await getStations();



    return stations.where((station){


      return station.branchId ==
          branchId;


    }).toList();


  }






//================================================
// محطات محافظة معينة
//================================================

  Future<List<Station>>
  getGovernorateStations(
      String governorateId
      ) async {



    final stations =
    await getStations();



    return stations.where((station){


      return station.governorate ==
          governorateId;


    }).toList();


  }





//==================================
// موافقة مدير الفرع على طلب محطة
//==================================


//==================================
// رفض طلب تسجيل محطة
//==================================

  Future<void> rejectPendingStation({
    required String id,
    required String reason,
  }) async {

    final requestId = id.trim();

    if (requestId.isEmpty) {
      throw Exception("معرف طلب الرفض غير موجود");
    }

    final snapshot =
    await pendingRef.child(requestId).get();

    if (!snapshot.exists || snapshot.value == null) {
      throw Exception("طلب المحطة غير موجود أو تمت معالجته مسبقاً");
    }

    await pendingRef
        .child(requestId)
        .update({
      "approved": false,
      "active": false,
      "status": "rejected",
      "rejectReason": reason.trim(),
      "updatedAt": DateTime.now().toIso8601String(),
    });
  }

//================================================
// التحقق من وجود محطة بنفس الاسم
//================================================

  Future<bool> stationExistsByName(
      String name
      ) async {


    final stations =
    await getStations();



    return stations.any((station){


      return station.name
          .trim()
          .toLowerCase() ==
          name
              .trim()
              .toLowerCase();


    });


  }
// ============================================================
// نتيجة فحص تكرار طلب تسجيل المحطة
// ============================================================

  Future<List<String>> checkRegistrationDuplicates({
    required String stationName,
    required String managerName,
    required String phone,
    String? stationLicense,
  }) async {
    final duplicates = <String>[];

    // ============================================
    // توحيد النصوص
    // ============================================

    String normalizeText(String value) {
      return value
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), ' ')
          .replaceAll('أ', 'ا')
          .replaceAll('إ', 'ا')
          .replaceAll('آ', 'ا')
          .replaceAll('ة', 'ه')
          .replaceAll('ى', 'ي');
    }

    String normalizePhone(String value) {
      var result = value.trim();

      result = result.replaceAll(
        RegExp(r'[\s\-\(\)]'),
        '',
      );

      if (result.startsWith('00964')) {
        result = '0${result.substring(5)}';
      }

      if (result.startsWith('+964')) {
        result = '0${result.substring(4)}';
      }

      return result;
    }

    final normalizedStationName =
    normalizeText(stationName);

    final normalizedManagerName =
    normalizeText(managerName);

    final normalizedPhone =
    normalizePhone(phone);

    final normalizedLicense =
    normalizeText(stationLicense ?? '');

    // ============================================
    // فحص المحطات المعتمدة/الموجودة فقط
    //
    // لا نقرأ pendingStations هنا لأن شاشة
    // التسجيل قد تكون لمستخدم غير مسجل الدخول.
    // ============================================

    final stationsSnapshot =
    await stationsRef.get();

    if (stationsSnapshot.exists &&
        stationsSnapshot.value != null) {

      final data =
      Map<dynamic, dynamic>.from(
        stationsSnapshot.value as Map,
      );

      for (final entry in data.entries) {

        final station =
        Map<String, dynamic>.from(
          entry.value as Map,
        );

        final existingName =
        normalizeText(
          station["name"]?.toString() ?? '',
        );

        final existingManagerName =
        normalizeText(
          station["managerName"]?.toString() ?? '',
        );

        final existingPhone =
        normalizePhone(
          station["phone"]?.toString() ??
              station["managerPhone"]?.toString() ??
              '',
        );

        final existingLicense =
        normalizeText(
          station["stationLicense"]?.toString() ??
              station["licenseNumber"]?.toString() ??
              '',
        );

        if (normalizedStationName.isNotEmpty &&
            existingName.isNotEmpty &&
            normalizedStationName == existingName) {

          if (!duplicates.contains("اسم المحطة")) {
            duplicates.add("اسم المحطة");
          }
        }

        if (normalizedManagerName.isNotEmpty &&
            existingManagerName.isNotEmpty &&
            normalizedManagerName ==
                existingManagerName) {

          if (!duplicates.contains("اسم صاحب المحطة")) {
            duplicates.add("اسم صاحب المحطة");
          }
        }

        if (normalizedPhone.isNotEmpty &&
            existingPhone.isNotEmpty &&
            normalizedPhone == existingPhone) {

          if (!duplicates.contains("رقم الموبايل")) {
            duplicates.add("رقم الموبايل");
          }
        }

        if (normalizedLicense.isNotEmpty &&
            existingLicense.isNotEmpty &&
            normalizedLicense == existingLicense) {

          if (!duplicates.contains("رقم ترخيص المحطة")) {
            duplicates.add("رقم ترخيص المحطة");
          }
        }
      }
    }

    return duplicates;
  }
// =====================================================
// فتح WhatsApp يدوياً مع رسالة بيانات حساب المحطة
// =====================================================
//
// لا توجد Cloud Function ولا WhatsApp API هنا.
// يتم فقط فتح تطبيق WhatsApp على رقم صاحب المحطة
// مع رسالة جاهزة، ومدير الفرع يضغط "إرسال" بنفسه.
// =====================================================

  Future<void> sendStationCredentialsWhatsApp({
    required String stationId,
    required String stationName,
    required String phone,
    required String username,
    required String password,
    required String branchId,
  }) async {
    String normalizeWhatsAppPhone(String value) {
      var digits =
      value.replaceAll(RegExp(r'[^0-9]'), '');

      if (digits.startsWith('00964')) {
        digits = digits.substring(2);
      } else if (digits.startsWith('07')) {
        digits = '964${digits.substring(1)}';
      } else if (digits.startsWith('7')) {
        digits = '964$digits';
      }

      return digits;
    }

    final cleanPhone =
    normalizeWhatsAppPhone(phone.trim());

    if (cleanPhone.isEmpty) {
      throw Exception(
        "رقم هاتف صاحب المحطة غير موجود",
      );
    }

    final whatsappMessage = """
السلام عليكم ورحمة الله وبركاته

نظام نافذة المنتوج النفطي

تمت الموافقة على تسجيل محطة:
$stationName

بيانات الدخول الخاصة بالمحطة:

اسم المستخدم:
$username

كلمة المرور:
$password

يرجى المحافظة على بيانات الدخول وعدم مشاركتها مع أي شخص.

مع التقدير
إدارة نافذة المنتوج النفطي
""";

    final uri = Uri.https(
      'wa.me',
      '/$cleanPhone',
      <String, String>{
        'text': whatsappMessage,
      },
    );

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      throw Exception(
        "تعذر فتح WhatsApp على هذا الجهاز",
      );
    }
  }

}