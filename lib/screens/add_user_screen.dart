import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/station.dart';
import '../../models/user_model.dart';

import '../../services/auth_service.dart';
import '../../services/station_service.dart';



class AddUserScreen extends StatefulWidget {

  const AddUserScreen({
    super.key,
  });



  @override
  State<AddUserScreen> createState() =>
      _AddUserScreenState();

}







class _AddUserScreenState
    extends State<AddUserScreen> {



  final formKey =
  GlobalKey<FormState>();



  final AuthService auth =
      AuthService.instance;



  final StationService stationService =
      StationService.instance;





  final nameController =
  TextEditingController();



  final usernameController =
  TextEditingController();



  final passwordController =
  TextEditingController();



  final phoneController =
  TextEditingController();






  List<Station> stations = [];



  Station?
  selectedStation;






  String role =
      "station_writer";




  bool loading = true;









  @override
  void initState(){

    super.initState();

    loadStations();

  }









  Future<void> loadStations() async {



    stations =

    await stationService.getStations();





    if(!mounted)
      return;




    setState(() {

      loading = false;

    });



  }









  Future<void> saveUser() async {



    if(!formKey.currentState!.validate())
      return;






    if(selectedStation == null){


      ScaffoldMessenger.of(context)
          .showSnackBar(


        const SnackBar(

          content:

          Text(
            "يرجى اختيار المحطة",
          ),

        ),


      );


      return;


    }








    final user = AppUser(



      id:

      const Uuid().v4(),




      fullName:

      nameController.text.trim(),





      username:

      usernameController.text.trim(),




      password:

      passwordController.text.trim(),





      email:

      usernameController.text.trim(),





      phone:

      phoneController.text.trim(),





      role:

      role,






      stationId:

      selectedStation!.id,





      stationName:

      selectedStation!.name,






      governorateId:

      selectedStation!.governorate,





      governorateName:

      selectedStation!.governorate,






      branchId:

      selectedStation!.branchId,





      branchName:

      selectedStation!.branchName,






      position:

      role,





      image:

      "",





      active:

      true,






      createdAt:

      DateTime.now(),





      updatedAt:

      DateTime.now(),





      lastLogin:

      DateTime.now(),




    );









    await auth.addUser(user);








    if(!mounted)
      return;






    ScaffoldMessenger.of(context)
        .showSnackBar(



      const SnackBar(

        content:

        Text(
          "تم إنشاء حساب مدير المحطة",
        ),


        backgroundColor:
        Colors.green,

      ),



    );






    Navigator.pop(context);



  }









  @override
  Widget build(BuildContext context){



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

          "إنشاء حساب مدير محطة",

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

              nameController,

              "الاسم الكامل",

              Icons.person,

            ),






            field(

              usernameController,

              "اسم المستخدم",

              Icons.account_circle,

            ),







            field(

              passwordController,

              "كلمة المرور",

              Icons.lock,

              password:true,

            ),







            field(

              phoneController,

              "رقم الهاتف",

              Icons.phone,

            ),









            const SizedBox(height:15),









            DropdownButtonFormField<String>(




              value:

              role,





              decoration:

              const InputDecoration(



                labelText:

                "الصلاحية",



                border:

                OutlineInputBorder(),


                prefixIcon:

                Icon(
                  Icons.admin_panel_settings,
                ),


              ),






              items:

              const [



                DropdownMenuItem(

                  value:

                  "admin",

                  child:

                  Text(
                    "مدير النظام",
                  ),

                ),




                DropdownMenuItem(

                  value:

                  "branch_employee",

                  child:

                  Text(
                    "موظف الفرع",
                  ),

                ),




                DropdownMenuItem(

                  value:

                  "station_writer",

                  child:

                  Text(
                    "كاتب المحطة",
                  ),

                ),



              ],






              onChanged:(value){


                setState(() {


                  role =
                  value!;



                });



              },



            ),








            const SizedBox(height:15),







            DropdownButtonFormField<Station>(



              value:

              selectedStation,






              decoration:

              const InputDecoration(



                labelText:

                "المحطة",



                border:

                OutlineInputBorder(),


                prefixIcon:

                Icon(
                  Icons.local_gas_station,
                ),


              ),







              items:



              stations.map((station){



                return DropdownMenuItem(



                  value:

                  station,



                  child:

                  Text(

                    station.name,

                  ),



                );



              }).toList(),






              onChanged:(value){


                setState(() {



                  selectedStation =

                      value;



                });


              },






              validator:(value){


                if(value == null){


                  return
                    "يرجى اختيار المحطة";


                }


                return null;


              },



            ),







            const SizedBox(height:30),







            SizedBox(



              height:

              55,




              width:

              double.infinity,





              child:

              ElevatedButton.icon(



                onPressed:

                saveUser,





                icon:

                const Icon(
                    Icons.save
                ),





                label:

                const Text(

                  "حفظ المستخدم",

                  style:

                  TextStyle(

                    fontSize:18,

                    fontWeight:

                    FontWeight.bold,

                  ),

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

        bool password = false,

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




        obscureText:

        password,





        validator:(v){



          if(v == null ||
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



    nameController.dispose();

    usernameController.dispose();

    passwordController.dispose();

    phoneController.dispose();



    super.dispose();


  }



}