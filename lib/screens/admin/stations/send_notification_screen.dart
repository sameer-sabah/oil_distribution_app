import 'package:flutter/material.dart';

import '../../../models/station.dart';
import '../../../services/user_service.dart';



class SendNotificationScreen extends StatefulWidget {


  final Station station;



  const SendNotificationScreen({

    super.key,

    required this.station,

  });




  @override
  State<SendNotificationScreen> createState() =>
      _SendNotificationScreenState();


}







class _SendNotificationScreenState
    extends State<SendNotificationScreen> {



  final UserService userService =
      UserService.instance;



  final TextEditingController titleController =
  TextEditingController();



  final TextEditingController bodyController =
  TextEditingController();




  bool sending = false;








  Future<void> sendNotification() async {



    if(titleController.text.trim().isEmpty ||
        bodyController.text.trim().isEmpty){


      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:

          Text(
              "يرجى كتابة عنوان ونص التبليغ"
          ),

        ),

      );


      return;

    }






    if(widget.station.managerUid.isEmpty){


      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:

          Text(
              "لا يوجد مستخدم مرتبط بالمحطة"
          ),


          backgroundColor:
          Colors.red,

        ),

      );


      return;


    }







    setState(() {

      sending = true;

    });







    try {



      await userService.sendNotification(



        userId:

        widget.station.managerUid,



        title:

        titleController.text.trim(),



        body:

        bodyController.text.trim(),



      );







      if(!mounted) {
        return;
      }





      ScaffoldMessenger.of(context)
          .showSnackBar(



        const SnackBar(

          content:

          Text(
              "تم إرسال التبليغ بنجاح"
          ),


          backgroundColor:
          Colors.green,


        ),


      );





      Navigator.pop(
          context,
          true
      );





    }catch(e){



      if(!mounted) {
        return;
      }




      ScaffoldMessenger.of(context)
          .showSnackBar(



        SnackBar(

          content:

          Text(
              "خطأ:\n$e"
          ),


          backgroundColor:
          Colors.red,

        ),


      );


    }




    finally{


      if(mounted){

        setState(() {

          sending = false;

        });

      }


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






            Card(


              child:

              ListTile(


                leading:

                const Icon(
                    Icons.local_gas_station
                ),



                title:

                Text(
                    widget.station.name
                ),



                subtitle:

                Text(
                    widget.station.governorate
                ),


              ),


            ),







            const SizedBox(
                height:15
            ),







            TextField(


              controller:

              titleController,



              decoration:

              const InputDecoration(



                labelText:

                "عنوان التبليغ",



                border:

                OutlineInputBorder(),


                prefixIcon:

                Icon(
                    Icons.title
                ),



              ),



            ),






            const SizedBox(
                height:15
            ),







            Expanded(


              child:


              TextField(



                controller:

                bodyController,



                expands:

                true,



                maxLines:

                null,



                textAlignVertical:

                TextAlignVertical.top,



                decoration:

                const InputDecoration(



                  labelText:

                  "نص التبليغ",



                  border:

                  OutlineInputBorder(),



                ),


              ),


            ),








            const SizedBox(
                height:20
            ),







            SizedBox(


              width:

              double.infinity,



              height:

              55,



              child:


              ElevatedButton.icon(



                onPressed:

                sending

                    ? null

                    :

                sendNotification,




                icon:


                sending

                    ?

                const SizedBox(

                  width:20,

                  height:20,

                  child:

                  CircularProgressIndicator(

                    strokeWidth:2,

                    color:Colors.white,

                  ),

                )


                    :

                const Icon(
                    Icons.send
                ),






                label:


                Text(

                    sending

                        ?

                    "جاري الإرسال..."

                        :

                    "إرسال التبليغ"

                ),




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