import 'package:flutter/material.dart';

import '../../../models/station.dart';
import '../../../services/station_service.dart';



class EditStationScreen extends StatefulWidget {


  final Station station;



  const EditStationScreen({

    super.key,

    required this.station,

  });





  @override
  State<EditStationScreen> createState() =>
      _EditStationScreenState();


}








class _EditStationScreenState
    extends State<EditStationScreen> {



  final StationService stationService =
      StationService.instance;





  late TextEditingController name;

  late TextEditingController phone;

  late TextEditingController address;

  late TextEditingController manager;

  late TextEditingController managerPhone;

  late TextEditingController workingHours;

  late TextEditingController notes;





  bool saving = false;









  @override
  void initState(){


    super.initState();




    name = TextEditingController(

      text: widget.station.name,

    );




    phone = TextEditingController(

      text: widget.station.phone,

    );




    address = TextEditingController(

      text: widget.station.address,

    );




    manager = TextEditingController(

      text: widget.station.managerName,

    );




    managerPhone = TextEditingController(

      text: widget.station.managerPhone,

    );





    workingHours = TextEditingController(

      text: widget.station.workingHours,

    );





    notes = TextEditingController(

      text: widget.station.notes,

    );



  }









  Future<void> save() async {



    setState(() {


      saving = true;


    });







    final updated =

    widget.station.copyWith(



      name:

      name.text.trim(),





      phone:

      phone.text.trim(),





      address:

      address.text.trim(),





      managerName:

      manager.text.trim(),





      managerPhone:

      managerPhone.text.trim(),





      workingHours:

      workingHours.text.trim(),





      notes:

      notes.text.trim(),





      updatedAt:

      DateTime.now()
          .toIso8601String(),



    );







    await stationService.updateStation(

      updated,

    );








    if(!mounted)

      return;







    setState(() {


      saving = false;


    });








    ScaffoldMessenger.of(context)

        .showSnackBar(



      const SnackBar(



        content:

        Text(

            "تم حفظ التعديلات بنجاح"

        ),



        backgroundColor:

        Colors.green,



      ),



    );







    Navigator.pop(

      context,

      true,

    );



  }












  Widget field(



      String title,

      TextEditingController controller,

      {


        int maxLines = 1,


      }



      ){





    return Padding(



      padding:

      const EdgeInsets.only(

        bottom:15,

      ),






      child:



      TextField(



        controller:

        controller,





        maxLines:

        maxLines,






        decoration:



        InputDecoration(



          labelText:

          title,





          border:

          OutlineInputBorder(



            borderRadius:

            BorderRadius.circular(12),



          ),



        ),



      ),



    );



  }









  @override
  Widget build(BuildContext context){



    return Scaffold(




      appBar:

      AppBar(



        title:

        const Text(

            "تعديل المحطة"

        ),




        centerTitle:

        true,



      ),







      body:




      SingleChildScrollView(





        padding:

        const EdgeInsets.all(16),






        child:

        Column(





          children: [






            field(

              "اسم المحطة",

              name,

            ),





            field(

              "مدير المحطة",

              manager,

            ),






            field(

              "هاتف المدير",

              managerPhone,

            ),





            field(

              "هاتف المحطة",

              phone,

            ),





            field(

              "العنوان",

              address,

            ),





            field(

              "ساعات الدوام",

              workingHours,

            ),






            field(

              "ملاحظات",

              notes,

              maxLines:4,

            ),







            const SizedBox(

              height:25,

            ),








            SizedBox(



              width:

              double.infinity,




              height:

              55,







              child:



              ElevatedButton.icon(



                onPressed:

                saving

                    ? null

                    : save,







                icon:



                saving



                    ?



                const SizedBox(



                  width:22,

                  height:22,



                  child:



                  CircularProgressIndicator(



                    strokeWidth:2,



                    color:

                    Colors.white,



                  ),



                )



                    :



                const Icon(

                    Icons.save

                ),







                label:



                Text(



                  saving

                      ?

                  "جاري الحفظ..."

                      :

                  "حفظ التعديلات",



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



    name.dispose();

    phone.dispose();

    address.dispose();

    manager.dispose();

    managerPhone.dispose();

    workingHours.dispose();

    notes.dispose();



    super.dispose();


  }




}