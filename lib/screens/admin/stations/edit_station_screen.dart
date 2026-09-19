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



  final formKey =
  GlobalKey<FormState>();


  final StationService service =
      StationService.instance;



  late TextEditingController nameController;

  late TextEditingController managerNameController;

  late TextEditingController managerPhoneController;

  late TextEditingController governorateController;

  late TextEditingController districtController;

  late TextEditingController addressController;

  late TextEditingController phoneController;

  late TextEditingController workingHoursController;

  late TextEditingController latitudeController;

  late TextEditingController longitudeController;


  late TextEditingController regular95Controller;

  late TextEditingController improved95Controller;

  late TextEditingController super95Controller;

  late TextEditingController dieselController;

  late TextEditingController whiteOilController;

  late TextEditingController lpgController;


  late TextEditingController notesController;



  late String stationType;

  late String workingStatus;


  late bool active;

  late bool approved;



  bool saving = false;





  @override
  void initState(){

    super.initState();


    final s = widget.station;



    nameController =
        TextEditingController(
            text: s.name
        );


    managerNameController =
        TextEditingController(
            text: s.managerName
        );


    managerPhoneController =
        TextEditingController(
            text: s.managerPhone
        );


    governorateController =
        TextEditingController(
            text: s.governorate
        );


    districtController =
        TextEditingController(
            text: s.district
        );


    addressController =
        TextEditingController(
            text: s.address
        );


    phoneController =
        TextEditingController(
            text: s.phone
        );


    workingHoursController =
        TextEditingController(
            text: s.workingHours
        );


    latitudeController =
        TextEditingController(
            text: s.latitude.toString()
        );


    longitudeController =
        TextEditingController(
            text: s.longitude.toString()
        );



    regular95Controller =
        TextEditingController(
            text: s.regular95.toString()
        );


    improved95Controller =
        TextEditingController(
            text: s.improved95.toString()
        );


    super95Controller =
        TextEditingController(
            text: s.super95.toString()
        );


    dieselController =
        TextEditingController(
            text: s.diesel.toString()
        );


    whiteOilController =
        TextEditingController(
            text: s.whiteOil.toString()
        );


    lpgController =
        TextEditingController(
            text: s.lpg.toString()
        );



    notesController =
        TextEditingController(
            text: s.notes
        );



    stationType =
        s.stationType;


    workingStatus =
        s.workingStatus;


    active =
        s.active;


    approved =
        s.approved;

  }








  Future<void> save() async {


    if(!formKey.currentState!.validate()) {
      return;
    }



    setState(() {

      saving = true;

    });





    final updated =
    widget.station.copyWith(


      name:
      nameController.text.trim(),



      managerName:
      managerNameController.text.trim(),



      managerPhone:
      managerPhoneController.text.trim(),



      governorate:
      governorateController.text.trim(),



      district:
      districtController.text.trim(),



      address:
      addressController.text.trim(),



      phone:
      phoneController.text.trim(),



      latitude:
      double.tryParse(
          latitudeController.text
      ) ?? 0,



      longitude:
      double.tryParse(
          longitudeController.text
      ) ?? 0,



      regular95:
      int.tryParse(
          regular95Controller.text
      ) ?? 0,



      improved95:
      int.tryParse(
          improved95Controller.text
      ) ?? 0,



      super95:
      int.tryParse(
          super95Controller.text
      ) ?? 0,



      diesel:
      int.tryParse(
          dieselController.text
      ) ?? 0,



      whiteOil:
      int.tryParse(
          whiteOilController.text
      ) ?? 0,



      lpg:
      int.tryParse(
          lpgController.text
      ) ?? 0,



      workingHours:
      workingHoursController.text.trim(),



      notes:
      notesController.text.trim(),



      stationType:
      stationType,



      workingStatus:
      workingStatus,



      active:
      active,



      approved:
      approved,



      updatedAt:
      DateTime.now()
          .toIso8601String(),

    );





    await service.updateStation(
        updated
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
            "تم تحديث المحطة بنجاح"
        ),

        backgroundColor:
        Colors.green,

      ),

    );



    Navigator.pop(
        context,
        true
    );

  }









  Widget field(
      String label,
      TextEditingController controller,
      ){

    return Padding(

      padding:
      const EdgeInsets.only(bottom:12),

      child:

      TextFormField(

        controller:
        controller,


        decoration:
        InputDecoration(

          labelText:
          label,


          border:
          const OutlineInputBorder(),

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


      Form(

        key:
        formKey,


        child:


        ListView(

          padding:
          const EdgeInsets.all(16),



          children: [



            field(
                "اسم المحطة",
                nameController
            ),


            field(
                "اسم المدير",
                managerNameController
            ),


            field(
                "هاتف المدير",
                managerPhoneController
            ),


            field(
                "المحافظة",
                governorateController
            ),


            field(
                "القضاء",
                districtController
            ),


            field(
                "العنوان",
                addressController
            ),


            field(
                "هاتف المحطة",
                phoneController
            ),


            field(
                "ساعات العمل",
                workingHoursController
            ),



            Row(

              children: [


                Expanded(

                  child:
                  field(
                      "Latitude",
                      latitudeController
                  ),

                ),



                const SizedBox(
                    width:10
                ),



                Expanded(

                  child:
                  field(
                      "Longitude",
                      longitudeController
                  ),

                ),



              ],

            ),




            const Text(

              "كميات المنتجات",

              style:
              TextStyle(
                fontSize:18,
                fontWeight:
                FontWeight.bold,
              ),

            ),



            const SizedBox(
                height:10
            ),



            field(
                "بنزين عادي",
                regular95Controller
            ),


            field(
                "بنزين محسن",
                improved95Controller
            ),


            field(
                "بنزين سوبر",
                super95Controller
            ),


            field(
                "زيت الغاز",
                dieselController
            ),


            field(
                "النفط الأبيض",
                whiteOilController
            ),


            field(
                "الغاز السائل",
                lpgController
            ),



            field(
                "ملاحظات",
                notesController
            ),




            SwitchListTile(

              title:
              const Text(
                  "المحطة مفعلة"
              ),

              value:
              active,


              onChanged:(v){

                setState(() {

                  active=v;

                });

              },

            ),




            SwitchListTile(

              title:
              const Text(
                  "معتمدة"
              ),


              value:
              approved,


              onChanged:(v){

                setState(() {

                  approved=v;

                });

              },

            ),




            const SizedBox(
                height:20
            ),





            SizedBox(

              height:
              55,


              width:
              double.infinity,


              child:

              ElevatedButton.icon(

                onPressed:
                saving
                    ? null
                    : save,


                icon:
                const Icon(
                    Icons.save
                ),


                label:

                Text(
                    saving
                        ? "جاري الحفظ..."
                        : "حفظ التعديلات"
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


    nameController.dispose();

    managerNameController.dispose();

    managerPhoneController.dispose();

    governorateController.dispose();

    districtController.dispose();

    addressController.dispose();

    phoneController.dispose();

    workingHoursController.dispose();

    latitudeController.dispose();

    longitudeController.dispose();

    regular95Controller.dispose();

    improved95Controller.dispose();

    super95Controller.dispose();

    dieselController.dispose();

    whiteOilController.dispose();

    lpgController.dispose();

    notesController.dispose();


    super.dispose();

  }


}