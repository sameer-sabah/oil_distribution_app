import 'package:firebase_database/firebase_database.dart';

import '../models/station.dart';


class DatabaseService {


  DatabaseService._();


  static final DatabaseService instance =
  DatabaseService._();



  final FirebaseDatabase _database =
      FirebaseDatabase.instance;



  DatabaseReference get stationsRef =>
      _database.ref("stations");



  DatabaseReference get usersRef =>
      _database.ref("users");



  DatabaseReference get notificationsRef =>
      _database.ref("notifications");



  String get now =>
      DateTime.now().toIso8601String();





//====================================
// جلب جميع المحطات
//====================================

  Future<List<Station>> getStations() async {
    final snapshot = await stationsRef.get();

    if (!snapshot.exists || snapshot.value == null) {
      return [];
    }

    final data = Map<dynamic, dynamic>.from(
      snapshot.value as Map,
    );

    return data.entries
        .map((e) {
      return Station.fromMap(
        e.key.toString(),
        Map<String, dynamic>.from(
          e.value as Map,
        ),
      );
    })
        .where((station) {
      // لا تعرض المحطات المحذوفة
      if (station.status == "deleted") {
        return false;
      }

      // لا تعرض المحطات المعطلة
      if (!station.active) {
        return false;
      }

      return true;
    })
        .toList();
  }







//====================================
// إضافة محطة
//====================================

  Future<void> addStation(
      Station station,
      ) async {



    final id =
    station.id.isEmpty
        ?
    stationsRef.push().key!
        :
    station.id;



    final data =
    station.toMap();



    data["id"] = id;

    data["createdAt"] = now;

    data["updatedAt"] = now;



    await stationsRef
        .child(id)
        .set(data);


  }








//====================================
// جلب محطة واحدة
//====================================

  Future<Station?> getStation(
      String id,
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

        snapshot.value as Map,

      ),


    );


  }








//====================================
// تعديل محطة
//====================================

  Future<void> updateStation(
      Station station,
      ) async {



    await stationsRef
        .child(station.id)
        .update(

      station.copyWith(

        updatedAt:
        DateTime.now().toIso8601String(),

      ).toMap(),

    );


  }








//====================================
// حذف محطة
//====================================

  Future<void> deleteStation(
      String id,
      ) async {


    await stationsRef
        .child(id)
        .remove();


  }








//====================================
// بث مباشر للمحطات
//====================================

  Stream<List<Station>> stationsStream(){


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








//====================================
// تحديث الوقود
//====================================

  Future<void> updateFuel({


    required String stationId,


    required int regular95,


    required int improved95,


    required int super95,


    required int diesel,


    required int whiteOil,


    required int lpg,


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



      "updatedAt":
      now,



    });


  }



}