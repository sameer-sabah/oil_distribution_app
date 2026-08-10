import 'package:firebase_database/firebase_database.dart';

import '../models/user_model.dart';



class UserService {


  UserService._();


  static final UserService instance =
  UserService._();



  final FirebaseDatabase database =
      FirebaseDatabase.instance;



  DatabaseReference get usersRef =>
      database.ref("users");



  DatabaseReference get notificationsRef =>
      database.ref("notifications");





//====================================
// إضافة مستخدم
//====================================

  Future<void> addUser(
      AppUser user
      ) async {



    await usersRef
        .child(user.id)
        .set({



      "uid":
      user.id,



      "fullName":
      user.fullName,



      "username":
      user.username,



      "password":
      user.password,



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



      "active":
      user.active,



      "createdAt":
      user.createdAt.toIso8601String(),



      "updatedAt":
      user.updatedAt.toIso8601String(),



      "lastLogin":
      user.lastLogin.toIso8601String(),



    });


  }








//====================================
// إنشاء مستخدم بالطريقة الثانية
//====================================

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



      final uid =
      usersRef.push().key!;



      await usersRef
          .child(uid)
          .set({



        "uid":
        uid,



        "fullName":
        fullName,



        "username":
        username,



        "password":
        password,



        "email":
        email,



        "phone":
        phone,



        "role":
        role,



        "governorateId":
        governorateId,



        "governorateName":
        governorateName,



        "branchId":
        branchId,



        "branchName":
        branchName,



        "stationId":
        stationId,



        "stationName":
        stationName,



        "position":
        position,



        "active":
        true,



        "createdAt":
        DateTime.now()
            .toIso8601String(),



        "updatedAt":
        DateTime.now()
            .toIso8601String(),



      });



      return null;


    }

    catch(e){


      return e.toString();


    }


  }









//====================================
// جلب المستخدمين
//====================================

  Future<List<Map<String,dynamic>>>
  getUsers() async {



    final snapshot =
    await usersRef.get();



    if(!snapshot.exists ||
        snapshot.value == null){


      return [];


    }





    final data =
    Map<dynamic,dynamic>.from(

      snapshot.value as Map,

    );





    return data.entries.map((e){



      final user =
      Map<String,dynamic>.from(

        e.value as Map,

      );



      user["uid"] =
          e.key.toString();



      return user;



    }).toList();



  }









//====================================
// عدد المستخدمين
//====================================

  Future<int> getUsersCount() async {



    final users =
    await getUsers();



    return users.length;


  }









//====================================
// حذف مستخدم
//====================================

  Future<void> deleteUser(
      String uid
      ) async {



    await usersRef
        .child(uid)
        .remove();



  }









//====================================
// تحديث مستخدم
//====================================

  Future<void> updateUser(

      String uid,

      Map<String,dynamic> data,

      ) async {



    await usersRef
        .child(uid)
        .update(data);



  }









//====================================
// جلب مستخدم واحد
//====================================

  Future<Map<String,dynamic>?> getUser(

      String uid

      ) async {



    final snapshot =
    await usersRef
        .child(uid)
        .get();




    if(!snapshot.exists ||
        snapshot.value == null){

      return null;

    }




    return Map<String,dynamic>.from(

      snapshot.value as Map,

    );


  }









//====================================
// إرسال إشعار
//====================================

  Future<void> sendNotification({


    required String userId,


    required String title,


    required String body,


  }) async {



    final id =
    notificationsRef.push().key!;




    await notificationsRef
        .child(id)
        .set({



      "id":
      id,



      "userId":
      userId,



      "title":
      title,



      "body":
      body,



      "read":
      false,



      "createdAt":
      DateTime.now()
          .toIso8601String(),



    });



  }



}