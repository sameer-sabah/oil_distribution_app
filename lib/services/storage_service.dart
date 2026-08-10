import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';



class StorageService {


  StorageService._();


  static final StorageService instance =
  StorageService._();



  final FirebaseStorage storage =
      FirebaseStorage.instance;



  //=========================================
  // رفع صورة
  //=========================================

  Future<String> uploadImage({

    required File file,

    required String folder,

  }) async {



    final fileName =
    DateTime.now()
        .millisecondsSinceEpoch
        .toString();



    final ref =
    storage
        .ref()
        .child(folder)
        .child("$fileName.jpg");




    await ref.putFile(file);



    final url =
    await ref.getDownloadURL();



    return url;


  }






  //=========================================
  // رفع صورة مدير محطة
  //=========================================

  Future<String> uploadManagerPhoto(
      File file
      ) async {


    return await uploadImage(

      file: file,

      folder:
      "station_managers",

    );


  }






  //=========================================
  // رفع صورة المحطة
  //=========================================

  Future<String> uploadStationPhoto(
      File file
      ) async {


    return await uploadImage(

      file: file,

      folder:
      "stations",

    );


  }





  //=========================================
  // حذف صورة
  //=========================================

  Future<void> deleteImage(
      String url
      ) async {


    try{


      await storage
          .refFromURL(url)
          .delete();


    }

    catch(e){


      print(
          "Delete image error: $e"
      );


    }


  }



}