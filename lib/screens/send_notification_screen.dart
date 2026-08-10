import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/station.dart';


class SendNotificationScreen extends StatefulWidget {

  final Station? station;

  final List<Station>? stations;


  const SendNotificationScreen({
    super.key,
    this.station,
    this.stations,
  });


  @override
  State<SendNotificationScreen> createState() =>
      _SendNotificationScreenState();

}



class _SendNotificationScreenState
    extends State<SendNotificationScreen> {


  final titleController =
  TextEditingController();


  final bodyController =
  TextEditingController();


  final DatabaseReference ref =
  FirebaseDatabase.instance.ref("notifications");


  bool loading = false;



  List<Station> get selectedStations {

    if(widget.station != null){

      return [
        widget.station!
      ];

    }

    return widget.stations ?? [];

  }






  Future send() async {
    if (titleController.text.trim().isEmpty ||
        bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("يرجى إدخال العنوان والنص"),
        ),
      );

      return;
    }

    if (selectedStations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("لا توجد محطة للإرسال"),
        ),
      );

      return;
    }

    setState(() {
      loading = true;
    });

    try {
      for (final station in selectedStations) {
        final id = DateTime.now()
            .millisecondsSinceEpoch
            .toString();

        final notificationData = {
          "title": titleController.text.trim(),
          "body": bodyController.text.trim(),

          "stationId": station.id,
          "stationName": station.name,

          "read": false,

          "createdAt":
          DateTime.now().toIso8601String(),
        };

        // ==========================================
        // 1. إشعار خاص بالمحطة
        // ==========================================

        await ref
            .child(station.id)
            .child(id)
            .set(notificationData);

        // ==========================================
        // 2. إشعار عام لكل المواطنين
        // ==========================================

        await ref
            .child("public")
            .child(id)
            .set(notificationData);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "تم إرسال الإشعار بنجاح",
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "فشل إرسال الإشعار: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }





  @override
  Widget build(BuildContext context){

    return Scaffold(


      appBar:

      AppBar(

        title:
        const Text(
            "إرسال تبليغ"
        ),

        centerTitle:
        true,

      ),



      body:

      Padding(

        padding:
        const EdgeInsets.all(16),


        child:

        Column(

          children: [


            Text(

              "عدد المحطات: ${selectedStations.length}",

              style:
              const TextStyle(

                fontSize:18,

                fontWeight:
                FontWeight.bold,

              ),

            ),



            const SizedBox(height:20),



            TextField(

              controller:
              titleController,

              decoration:
              const InputDecoration(

                labelText:
                "عنوان الإشعار",

                border:
                OutlineInputBorder(),

                prefixIcon:
                Icon(Icons.title),

              ),

            ),



            const SizedBox(height:15),



            TextField(

              controller:
              bodyController,

              maxLines:5,

              decoration:
              const InputDecoration(

                labelText:
                "نص الإشعار",

                border:
                OutlineInputBorder(),

                prefixIcon:
                Icon(Icons.message),

              ),

            ),



            const SizedBox(height:25),



            SizedBox(

              width:
              double.infinity,

              height:
              55,


              child:

              ElevatedButton.icon(


                icon:

                loading

                    ?

                const SizedBox(

                  width:20,

                  height:20,

                  child:
                  CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth:2,
                  ),

                )

                    :

                const Icon(
                    Icons.send
                ),



                label:

                Text(

                  loading

                      ?

                  "جاري الإرسال..."

                      :

                  "إرسال",

                ),



                onPressed:

                loading
                    ?

                null

                    :

                send,


              ),

            ),


          ],


        ),


      ),


    );

  }






  @override
  void dispose(){

    titleController.dispose();

    bodyController.dispose();

    super.dispose();

  }


}