import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/governorate_model.dart';
import '../models/branch_model.dart';

import '../services/governorate_service.dart';
import '../services/branch_service.dart';
import '../services/station_service.dart';

import 'map_picker_screen.dart';



class AddStationScreen extends StatefulWidget {

  const AddStationScreen({
    super.key,
  });


  @override
  State<AddStationScreen> createState() =>
      _AddStationScreenState();

}





class _AddStationScreenState
    extends State<AddStationScreen> {



  final formKey =
  GlobalKey<FormState>();


  final StationService stationService =
      StationService.instance;


  final GovernorateService governorateService =
      GovernorateService.instance;


  final BranchService branchService =
      BranchService.instance;



  final name =
  TextEditingController();


  final managerName =
  TextEditingController();


  final phone =
  TextEditingController();


  final district =
  TextEditingController();


  final address =
  TextEditingController();




  List<GovernorateModel> governorates = [];

  List<BranchModel> branches = [];



  GovernorateModel? selectedGovernorate;

  BranchModel? selectedBranch;



  double? latitude;

  double? longitude;



  File? managerImage;

  File? stationImage;



  bool loading = false;




  @override
  void initState(){

    super.initState();

    loadGovernorates();

  }





  Future<void> loadGovernorates() async {


    governorates =
    await governorateService.getGovernorates();


    setState(() {});

  }






  Future<void> loadBranches(
      String governorateId
      ) async {


    branches =
    await branchService
        .getGovernorateBranches(
        governorateId
    );


    selectedBranch = null;


    setState(() {});

  }








  Future<void> pickLocation() async {


    final LatLng? result =
    await Navigator.push(


      context,


      MaterialPageRoute(

        builder: (_) =>
        const MapPickerScreen(),

      ),


    );



    if(result != null){


      setState(() {


        latitude =
            result.latitude;


        longitude =
            result.longitude;


      });


    }


  }








  Future<void> pickImage(
      bool manager
      ) async {


    final picker =
    ImagePicker();


    final image =
    await picker.pickImage(

      source:
      ImageSource.gallery,

    );


    if(image == null) {
      return;
    }



    setState(() {


      if(manager){

        managerImage =
            File(image.path);

      }
      else{

        stationImage =
            File(image.path);

      }


    });


  }









  Future<void> save() async {



    if(!formKey.currentState!.validate()) {
      return;
    }



    if(selectedGovernorate == null ||
        selectedBranch == null){


      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
            "اختر المحافظة والفرع",
          ),

        ),

      );


      return;

    }



    if(latitude == null ||
        longitude == null){


      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
            "حدد موقع المحطة من الخريطة",
          ),

        ),

      );


      return;

    }



    setState(() {

      loading = true;

    });





    await stationService.addPendingStation({

      "name":
      name.text.trim(),


      "managerName":
      managerName.text.trim(),


      "phone":
      phone.text.trim(),


      "governorateId":
      selectedGovernorate!.id,


      "governorate":
      selectedGovernorate!.name,


      "branchId":
      selectedBranch!.id,


      "branchName":
      selectedBranch!.name,



      "district":
      district.text.trim(),



      "address":
      address.text.trim(),



      "latitude":
      latitude,



      "longitude":
      longitude,



      "approved":
      false,



      "active":
      false,



      "status":
      "pending",



      "managerImage":
      "",



      "stationImage":
      "",



      "createdAt":
      DateTime.now()
          .toIso8601String(),


    });





    if(!mounted) {
      return;
    }



    setState(() {

      loading = false;

    });



    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(

        content:
        Text(
          "تم إرسال طلب تسجيل المحطة",
        ),

        backgroundColor:
        Colors.green,

      ),

    );


    Navigator.pop(context);



  }








  Widget field(
      String title,
      TextEditingController controller,
      IconData icon,
      ){

    return Padding(

      padding:
      const EdgeInsets.only(
          bottom:15
      ),


      child:

      TextFormField(

        controller:
        controller,


        validator:(v){

          if(v == null ||
              v.trim().isEmpty){

            return "الحقل مطلوب";

          }

          return null;

        },


        decoration:

        InputDecoration(

          labelText:
          title,

          prefixIcon:
          Icon(icon),

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
          "تسجيل محطة جديدة",
        ),

        centerTitle:true,

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
              name,
              Icons.local_gas_station,
            ),


            field(
              "اسم مدير المحطة",
              managerName,
              Icons.person,
            ),


            field(
              "رقم الهاتف",
              phone,
              Icons.phone,
            ),



            DropdownButtonFormField<GovernorateModel>(

              initialValue:
              selectedGovernorate,


              decoration:
              const InputDecoration(

                labelText:
                "المحافظة",

                border:
                OutlineInputBorder(),

              ),



              items:

              governorates.map((g){

                return DropdownMenuItem(

                  value:g,

                  child:
                  Text(g.name),

                );


              }).toList(),



              onChanged:(value){

                selectedGovernorate=value;

                loadBranches(
                    value!.id
                );

              },


            ),



            const SizedBox(height:15),



            DropdownButtonFormField<BranchModel>(

              initialValue:
              selectedBranch,


              decoration:
              const InputDecoration(

                labelText:
                "الفرع",

                border:
                OutlineInputBorder(),

              ),


              items:

              branches.map((b){

                return DropdownMenuItem(

                  value:b,

                  child:
                  Text(b.name),

                );

              }).toList(),



              onChanged:(value){

                setState(() {

                  selectedBranch=value;

                });

              },


            ),



            const SizedBox(height:15),


            field(
              "القضاء",
              district,
              Icons.map,
            ),



            field(
              "العنوان",
              address,
              Icons.location_on,
            ),



            ElevatedButton.icon(

              onPressed:
              pickLocation,


              icon:
              const Icon(Icons.map),


              label:
              Text(

                latitude == null

                    ?

                "تحديد موقع المحطة"

                    :

                "تم تحديد الموقع",

              ),

            ),



            ElevatedButton.icon(

              onPressed:
                  () => pickImage(true),


              icon:
              const Icon(Icons.person),


              label:
              const Text(
                  "صورة مدير المحطة"
              ),

            ),



            ElevatedButton.icon(

              onPressed:
                  () => pickImage(false),


              icon:
              const Icon(Icons.image),


              label:
              const Text(
                  "صورة المحطة"
              ),

            ),



            const SizedBox(height:30),



            ElevatedButton(

              onPressed:
              loading ? null : save,


              child:

              Text(

                loading
                    ?

                "جاري الإرسال..."

                    :

                "إرسال الطلب",

              ),

            ),



          ],


        ),


      ),


    );


  }


}