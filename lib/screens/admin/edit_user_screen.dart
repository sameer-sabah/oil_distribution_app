import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../models/station.dart';

import '../../services/auth_service.dart';
import '../../services/station_service.dart';



class EditUserScreen extends StatefulWidget {

  final AppUser user;


  const EditUserScreen({
    super.key,
    required this.user,
  });



  @override
  State<EditUserScreen> createState() =>
      _EditUserScreenState();

}






class _EditUserScreenState
    extends State<EditUserScreen> {


  final AuthService auth =
      AuthService.instance;


  final StationService stationService =
      StationService.instance;



  final formKey =
  GlobalKey<FormState>();



  final fullNameController =
  TextEditingController();


  final usernameController =
  TextEditingController();


  final emailController =
  TextEditingController();


  final phoneController =
  TextEditingController();





  List<Station> stations = [];


  Station? selectedStation;



  String role =
      "employee";



  bool loading = true;





  @override
  void initState() {

    super.initState();


    fullNameController.text =
        widget.user.fullName;


    usernameController.text =
        widget.user.username;


    emailController.text =
        widget.user.email;


    phoneController.text =
        widget.user.phone;



    role =
        widget.user.role;



    loadStations();

  }








  Future<void> loadStations() async {


    stations =
    await stationService.getStations();



    for(final station in stations){


      if(station.id ==
          widget.user.stationId){


        selectedStation =
            station;

      }

    }




    if(!mounted) return;


    setState(() {

      loading = false;

    });


  }









  Future<void> updateUser() async {


    if(!formKey.currentState!
        .validate()){

      return;

    }





    final updatedUser =
    widget.user.copyWith(


      fullName:
      fullNameController.text.trim(),



      username:
      usernameController.text.trim(),



      email:
      emailController.text.trim(),



      phone:
      phoneController.text.trim(),



      role:
      role,




      stationId:
      selectedStation?.id ??
          "",



      stationName:
      selectedStation?.name ??
          "",




      branchId:
      selectedStation?.branchId ??
          "",



      branchName:
      selectedStation?.branchName ??
          "",




      governorateId:
      selectedStation?.branchId ??
          "",



      governorateName:
      selectedStation?.governorate ??
          "",




      updatedAt:
      DateTime.now(),

    );





    await auth.updateUser(
      updatedUser,
    );




    if(!mounted) return;



    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(

        content:
        Text(
            "تم تحديث المستخدم"
        ),

        backgroundColor:
        Colors.green,

      ),

    );



    Navigator.pop(context);


  }









  @override
  Widget build(BuildContext context) {


    if(loading){

      return const Scaffold(

        body:
        Center(

          child:
          CircularProgressIndicator(),

        ),

      );

    }




    return Scaffold(


      appBar:
      AppBar(

        title:
        const Text(
            "تعديل المستخدم"
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


          children:[



            field(
              fullNameController,
              "الاسم الكامل",
            ),



            const SizedBox(height:15),



            field(
              usernameController,
              "اسم المستخدم",
            ),



            const SizedBox(height:15),



            field(
              emailController,
              "البريد الإلكتروني",
            ),



            const SizedBox(height:15),



            field(
              phoneController,
              "رقم الهاتف",
            ),




            const SizedBox(height:15),




            DropdownButtonFormField<String>(


              initialValue:
              role,



              decoration:
              const InputDecoration(

                labelText:
                "الصلاحية",

                border:
                OutlineInputBorder(),

              ),




              items:
              const [


                DropdownMenuItem(

                  value:
                  "admin",

                  child:
                  Text(
                      "مدير النظام"
                  ),

                ),



                DropdownMenuItem(

                  value:
                  "branchManager",

                  child:
                  Text(
                      "مدير فرع"
                  ),

                ),



                DropdownMenuItem(

                  value:
                  "stationManager",

                  child:
                  Text(
                      "مدير محطة"
                  ),

                ),



                DropdownMenuItem(

                  value:
                  "employee",

                  child:
                  Text(
                      "موظف"
                  ),

                ),


              ],



              onChanged:(v){

                setState(() {

                  role =
                  v!;

                });

              },

            ),




            const SizedBox(height:15),




            DropdownButtonFormField<Station>(


              initialValue:
              selectedStation,



              decoration:
              const InputDecoration(

                labelText:
                "المحطة",

                border:
                OutlineInputBorder(),

              ),




              items:
              stations.map((station){


                return DropdownMenuItem(

                  value:
                  station,


                  child:
                  Text(
                      station.name
                  ),

                );


              }).toList(),




              onChanged:(Station? v){

                setState(() {

                  selectedStation = v;
                });

              },

            ),





            const SizedBox(height:30),





            ElevatedButton.icon(

              onPressed:
              updateUser,


              icon:
              const Icon(
                  Icons.save
              ),


              label:
              const Text(
                  "حفظ التعديلات"
              ),

            )


          ],

        ),

      ),


    );


  }







  Widget field(
      TextEditingController controller,
      String label,
      ){

    return TextFormField(

      controller:
      controller,


      validator:(v){

        if(v==null ||
            v.trim().isEmpty){

          return
            "الحقل مطلوب";

        }

        return null;

      },


      decoration:
      InputDecoration(

        labelText:
        label,


        border:
        const OutlineInputBorder(),

      ),

    );

  }






  @override
  void dispose(){

    fullNameController.dispose();

    usernameController.dispose();

    emailController.dispose();

    phoneController.dispose();


    super.dispose();

  }


}