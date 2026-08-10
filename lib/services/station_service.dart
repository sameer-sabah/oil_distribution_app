import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';

import '../models/station.dart';


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
Map<String, dynamic> data
) async {

final id =
pendingRef.push().key!;


data["id"] = id;


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


return data.entries.map((e){


final item =
Map<String,dynamic>.from(
e.value as Map
);


item["id"] =
e.key.toString();


return item;


}).toList();


}



//================================================
// الموافقة على طلب محطة
//================================================

Future<Map<String,dynamic>>
approveRegistration({

required Map<String,dynamic> request,

}) async {


final stationId =
request["id"].toString();



request.remove("id");



// بيانات المحطة

request["approved"] = true;

request["active"] = true;

request["status"] = "approved";



request["branchId"] =
request["branchId"] ?? "";


request["branchName"] =
request["branchName"] ?? "";



request["governorateId"] =
request["governorateId"] ?? "";



request["governorateName"] =
request["governorateName"] ?? "";



  request["stationType"] =
      request["stationType"] ?? "حكومية";

  request["workingStatus"] =
      request["workingStatus"] ?? "مفتوحة";


  request["updatedAt"] =
      DateTime.now().toIso8601String();


// حفظ المحطة

  await stationsRef
      .child(stationId)
      .set(request);



// تحديث عدد المحطات حسب نوع المحطة

  final branchId =
  request["branchId"];



  if(branchId != null &&
      branchId.toString().isNotEmpty){



    if(request["stationType"] == "حكومية"){


      await database
          .ref("branches")
          .child(branchId)
          .update({

        "governmentStations":
        ServerValue.increment(1),

      });


    }else{


      await database
          .ref("branches")
          .child(branchId)
          .update({

        "privateStations":
        ServerValue.increment(1),

      });


    }


  }




//=====================================
// إنشاء حساب مدير المحطة
//=====================================


final uid =
const Uuid().v4();


  final String stationPrefix =
  request["stationType"] == "حكومية"
      ? "G"
      : "P";

  final password =
      "$stationPrefix${DateTime.now()
      .millisecondsSinceEpoch
      .remainder(10000)
      .toString()
      .padLeft(4, '0')}";

  final username =
      "OPDC${DateTime.now()
      .millisecondsSinceEpoch
      .remainder(100000)
      .toString()
      .padLeft(4, '0')}";



await usersRef
.child(uid)
.set({


"uid":
uid,


"fullName":
request["managerName"] ?? "",


"username":
username,


"password":
password,


"phone":
request["phone"] ?? "",


"role":
"stationManager",



"stationId":
stationId,


"stationName":
request["name"] ?? "",



"branchId":
request["branchId"] ?? "",



"branchName":
request["branchName"] ?? "",



"governorateId":
request["governorateId"] ?? "",



"governorateName":
request["governorateName"] ?? "",



"active":
true,


"approved":
true,


"createdAt":
DateTime.now()
.toIso8601String(),



});

// ربط مدير المحطة بالمحطة
  await stationsRef
      .child(stationId)
      .update({
    "managerUid": uid,
    "managerName": request["managerName"] ?? "",
    "managerPhone": request["phone"] ?? "",
    "updatedAt": DateTime.now().toIso8601String(),
  });



// حذف الطلب بعد الموافقة

await pendingRef
.child(stationId)
.remove();





// إرجاع بيانات الحساب للشاشة

return {


"username":
username,


"password":
password,


"stationName":
request["name"] ?? "",


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

  print("اسم المحطة: ${e.key}");
  print("وقت التحديث: ${(e.value as Map)["updatedAt"]}");
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
Station station
) async {


await stationsRef
.child(station.id)
.update(
station.toMap(),
);


}





//================================================
// حذف محطة
//================================================
  Future<void> deleteStation(
      String id,
      ) async {
    // =========================================
    // 1. جلب بيانات المحطة قبل الحذف
    // =========================================

    final stationSnapshot =
    await stationsRef.child(id).get();

    String? managerUid;
    String? branchId;
    String? stationType;

    if (stationSnapshot.exists &&
        stationSnapshot.value != null) {
      final station =
      Map<String, dynamic>.from(
        stationSnapshot.value as Map,
      );

      managerUid =
          station["managerUid"]?.toString();

      branchId =
          station["branchId"]?.toString();

      stationType =
          station["stationType"]?.toString();
    }

    // =========================================
    // 2. حذف المحطة نهائياً
    // =========================================

    await stationsRef
        .child(id)
        .remove();

    // =========================================
    // 3. حذف طلب المحطة إن وجد
    // =========================================

    await pendingRef
        .child(id)
        .remove();

    // =========================================
    // 4. حذف إشعارات المحطة
    // =========================================

    final notificationsSnapshot =
    await database.ref("notifications").get();

    if (notificationsSnapshot.exists &&
        notificationsSnapshot.value != null) {
      final notifications =
      Map<dynamic, dynamic>.from(
        notificationsSnapshot.value as Map,
      );

      for (final entry in notifications.entries) {
        final notification =
        Map<String, dynamic>.from(
          entry.value as Map,
        );

        final notificationUserId =
        notification["userId"]?.toString();

        // حذف إشعارات مدير المحطة
        if (managerUid != null &&
            managerUid!.isNotEmpty &&
            notificationUserId == managerUid) {
          await database
              .ref("notifications")
              .child(entry.key.toString())
              .remove();
        }
      }
    }

    // =========================================
    // 5. حذف حساب مدير المحطة
    // =========================================

    if (managerUid != null &&
        managerUid!.isNotEmpty) {
      await usersRef
          .child(managerUid!)
          .remove();
    } else {
      // إذا managerUid غير موجود داخل المحطة
      // نبحث عن المستخدم المرتبط بـ stationId
      final usersSnapshot =
      await usersRef.get();

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

          if (user["stationId"]?.toString() == id) {
            await usersRef
                .child(entry.key.toString())
                .remove();
          }
        }
      }
    }

    // =========================================
    // 6. تحديث عداد المحطات في الفرع
    // =========================================

    if (branchId != null &&
        branchId!.isNotEmpty) {
      if (stationType == "حكومية") {
        await database
            .ref("branches")
            .child(branchId!)
            .update({
          "governmentStations":
          ServerValue.increment(-1),
        });
      } else if (stationType == "أهلية" ||
          stationType == "خاصة") {
        await database
            .ref("branches")
            .child(branchId!)
            .update({
          "privateStations":
          ServerValue.increment(-1),
        });
      }
    }
  }
//================================================
// إضافة محطة مباشرة
//================================================

Future<void> addStation(
Station station
) async {


await stationsRef
.child(station.id)
.set(
station.toMap(),
);


}





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


await stationsRef
.child(stationId)
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


    await stationsRef
        .child(stationId)
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


    final stations =
    await getStations();


    return stations.length;


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



    await pendingRef
        .child(id)
        .update({


      "approved":
      false,


      "active":
      false,


      "status":
      "rejected",


      "rejectReason":
      reason,


      "updatedAt":
      DateTime.now()
          .toIso8601String(),


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

}