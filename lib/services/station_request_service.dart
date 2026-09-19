import 'package:firebase_database/firebase_database.dart';

import '../models/station_request_model.dart';



class StationRequestService {

  StationRequestService._();

  static final StationRequestService instance =
  StationRequestService._();


  final FirebaseDatabase _database =
      FirebaseDatabase.instance;


  DatabaseReference get requestsRef =>
      _database.ref("stationRequests");


//=========================================
// إنشاء رقم طلب
//=========================================

  String generateRequestId() {
    return requestsRef
        .push()
        .key!;
  }


//=========================================
// إرسال طلب إنشاء محطة
//=========================================

  Future<void> sendRequest(StationRequestModel request,) async {
    await requestsRef
        .child(request.id)
        .set(
      request.toMap(),
    );
  }


//=========================================
// جلب جميع الطلبات
//=========================================

  Future<List<StationRequestModel>>
  getRequests() async {
    final snapshot =
    await requestsRef.get();


    if (!snapshot.exists ||
        snapshot.value == null) {
      return [];
    }


    final data =
    Map<dynamic, dynamic>.from(
        snapshot.value as Map
    );


    return data.entries.map((e) {
      return StationRequestModel.fromMap(

        e.key.toString(),

        Map<String, dynamic>.from(
          e.value as Map,
        ),

      );
    }).toList();
  }


//=========================================
// جلب طلب واحد
//=========================================

  Future<StationRequestModel?> getRequest(String requestId,) async {
    final snapshot =
    await requestsRef
        .child(requestId)
        .get();


    if (!snapshot.exists ||
        snapshot.value == null) {
      return null;
    }


    return StationRequestModel.fromMap(

        requestId,

        Map<String, dynamic>.from(
          snapshot.value as Map,
        )

    );
  }


//=========================================
// الطلبات المعلقة
//=========================================

  Future<List<StationRequestModel>>
  getPendingRequests() async {
    final list =
    await getRequests();


    return list
        .where(
            (e) => e.status == "pending"
    )
        .toList();
  }


//=========================================
// الطلبات الموافق عليها
//=========================================

  Future<List<StationRequestModel>>
  getApprovedRequests() async {
    final list =
    await getRequests();


    return list
        .where(
            (e) => e.status == "approved"
    )
        .toList();
  }


//=========================================
// الطلبات المرفوضة
//=========================================

  Future<List<StationRequestModel>>
  getRejectedRequests() async {
    final list =
    await getRequests();


    return list
        .where(
            (e) => e.status == "rejected"
    )
        .toList();
  }
}