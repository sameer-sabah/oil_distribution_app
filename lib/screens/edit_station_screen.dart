import 'package:flutter/material.dart';

import '../models/station.dart';
import '../services/station_service.dart';



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



  final formKey =
  GlobalKey<FormState>();



  late TextEditingController name;

  late TextEditingController managerName;

  late TextEditingController phone;

  late TextEditingController address;

  late TextEditingController district;





  bool saving = false;








  @override
  void initState(){

    super.initState();



    name =
        TextEditingController(
          text: widget.station.name,
        );



    managerName =
        TextEditingController(
          text: widget.station.managerName,
        );



    phone =
        TextEditingController(
          text: widget.station.phone,
        );



    address =
        TextEditingController(
          text: widget.station.address,
        );



    district =
        TextEditingController(
          text: widget.station.district,
        );



  }









  Future<void> save() async {



    if(!formKey.currentState!.validate()){

      return;

    }





    setState(() {

      saving = true;

    });







    final updatedStation =

    widget.station.copyWith(



      name:

      name.text.trim(),





      managerName:

      managerName.text.trim(),





      phone:

      phone.text.trim(),





      address:

      address.text.trim(),





      district:

      district.text.trim(),





      updatedAt:
      DateTime.now().toIso8601String(),



    );








    await stationService.updateStation(

      updatedStation,

    );








    if(!mounted) {
      return;
    }






    setState(() {

      saving = false;

    });







    ScaffoldMessenger.of(context)
        .showSnackBar(



      const SnackBar(


        content:

        Text(

          "تم تحديث بيانات المحطة",

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












  @override
  Widget build(BuildContext context){



    return Scaffold(





      appBar:

      AppBar(



        title:

        const Text(

          "تعديل المحطة",

        ),



        centerTitle:

        true,



      ),







      body:



      Form(



        key:

        formKey,





        child:

        ListView(



          padding:

          const EdgeInsets.all(16),





          children: [








            field(

              name,

              "اسم المحطة",

              Icons.local_gas_station,

              required:true,

            ),






            field(

              managerName,

              "مدير المحطة",

              Icons.person,

            ),






            field(

              phone,

              "رقم الهاتف",

              Icons.phone,

            ),






            field(

              district,

              "القضاء",

              Icons.map,

            ),






            field(

              address,

              "العنوان",

              Icons.location_on,

              maxLines:3,

            ),








            const SizedBox(height:30),







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

                  Icons.save,

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












  Widget field(



      TextEditingController controller,



      String label,



      IconData icon,



      {

        int maxLines = 1,

        bool required = false,

      }



      ){



    return Padding(



      padding:

      const EdgeInsets.only(

        bottom:15,

      ),




      child:

      TextFormField(



        controller:

        controller,




        maxLines:

        maxLines,





        validator:(value){



          if(required &&

              (value == null ||

                  value.trim().isEmpty)){



            return

              "الحقل مطلوب";


          }



          return null;



        },






        decoration:

        InputDecoration(



          labelText:

          label,



          prefixIcon:

          Icon(icon),




          border:

          const OutlineInputBorder(),



        ),



      ),



    );



  }









  @override
  void dispose(){



    name.dispose();

    managerName.dispose();

    phone.dispose();

    address.dispose();

    district.dispose();



    super.dispose();


  }



}
