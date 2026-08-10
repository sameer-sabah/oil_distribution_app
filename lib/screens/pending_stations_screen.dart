import 'package:flutter/material.dart';

import '../services/station_service.dart';
import '../services/auth_service.dart';
import '../core/constants/user_roles.dart';
import 'pending_stations_screen.dart';
class PendingStationsScreen extends StatefulWidget {

  const PendingStationsScreen({
    super.key,
  });


  @override
  State<PendingStationsScreen> createState() =>
      _PendingStationsScreenState();

}




class _PendingStationsScreenState
    extends State<PendingStationsScreen> {



  final StationService stationService =
      StationService.instance;


  final AuthService auth =
      AuthService.instance;



  List<Map<String,dynamic>> requests = [];


  bool loading = true;





  @override
  void initState(){

    super.initState();

    loadRequests();

  }







  Future<void> loadRequests() async {


    final all =
    await stationService
        .getPendingStationRequests();
    print("عدد كل الطلبات = ${all.length}");
    print("فرع المدير الحالي = ${auth.currentUser?.branchId}");
    print("PENDING COUNT = ${all.length}");
    print("CURRENT USER = ${auth.currentUser?.username}");
    print("ROLE = ${auth.currentUser?.role}");
    print("BRANCH ID = ${auth.currentUser?.branchId}");

    final user =
        auth.currentUser;



    if(user == null){

      return;

    }





    // مدير النظام يرى الجميع

    if(user.role ==  UserRoles.admin){


      requests = all;


    }


    // مدير الفرع يرى فرعه فقط

    else if(user.role == UserRoles.branchManager){

      requests =
          all.where((request){

            return request["branchId"].toString() ==
                user.branchId.toString();

          }).toList();

    }


    else{


      requests = [];


    }





    if(!mounted)
      return;



    setState(() {


      loading = false;


    });



  }









  Future<void> approve(
      Map<String,dynamic> request
      ) async {

    try {

      final account =
      await stationService
          .approveRegistration(
        request: request,
      );


      await loadRequests();


      if(!mounted)
        return;


      showDialog(

        context: context,

        builder:(context){

          return AlertDialog(

            title:
            const Text(
              "تم إنشاء حساب المحطة",
              textAlign: TextAlign.center,
            ),

            content:

            Column(

              mainAxisSize:
              MainAxisSize.min,

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children:[

                Text(
                  "اسم المحطة:\n${account["stationName"]}",
                ),

                const SizedBox(height:15),

                Text(
                  "اسم المستخدم:\n${account["username"]}",
                ),

                const SizedBox(height:10),

                Text(
                  "كلمة المرور:\n${account["password"]}",
                ),

              ],

            ),

            actions:[

              TextButton(

                onPressed:(){

                  Navigator.pop(context);

                },

                child:
                const Text("تم"),

              ),

            ],

          );

        },

      );


    } catch(e){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content:
          Text(e.toString()),

          backgroundColor:
          Colors.red,

        ),

      );

    }

  }







  Future<void> reject(
      String id
      ) async {



    final controller =
    TextEditingController();





    final reason =
    await showDialog<String>(



      context: context,



      builder:(context){


        return AlertDialog(


          title:

          const Text(
              "سبب الرفض"
          ),



          content:

          TextField(

            controller:
            controller,


            decoration:
            const InputDecoration(

              hintText:
              "اكتب السبب",

            ),


          ),



          actions:[


            TextButton(

              onPressed:(){

                Navigator.pop(context);

              },

              child:

              const Text(
                  "إلغاء"
              ),

            ),




            ElevatedButton(

              onPressed:(){

                Navigator.pop(

                  context,

                  controller.text,

                );

              },


              child:

              const Text(
                  "رفض"
              ),

            ),


          ],


        );


      },


    );





    if(reason == null ||
        reason.trim().isEmpty){

      return;

    }







    await stationService
        .rejectPendingStation(

      id: id,

      reason: reason,

    );





    await loadRequests();



  }









  @override
  Widget build(BuildContext context){


    return Scaffold(


      appBar:

      AppBar(


        title:

        const Text(
          "طلبات تسجيل المحطات",
        ),


        centerTitle:true,


      ),





      body:


      loading


          ?


      const Center(

        child:

        CircularProgressIndicator(),

      )



          :


      requests.isEmpty


          ?


      const Center(

        child:

        Text(
          "لا توجد طلبات",
          style:
          TextStyle(
            fontSize:18,
          ),
        ),

      )



          :



      ListView.builder(



        itemCount:
        requests.length,



        itemBuilder:(context,index){



          final request =
          requests[index];



          return Card(



            margin:
            const EdgeInsets.all(10),



            elevation:
            4,



            child:

            Padding(



              padding:
              const EdgeInsets.all(12),



              child:

              Column(



                crossAxisAlignment:
                CrossAxisAlignment.start,



                children:[



                  Text(


                    request["name"] ??
                        "",



                    style:

                    const TextStyle(

                      fontSize:20,

                      fontWeight:
                      FontWeight.bold,

                    ),


                  ),





                  const SizedBox(
                      height:10
                  ),





                  Text(

                    "المدير: ${request["managerName"] ?? ""}",

                  ),





                  Text(

                    "المحافظة: ${request["governorate"] ?? ""}",

                  ),





                  Text(

                    "الفرع: ${request["branchName"] ?? ""}",

                  ),





                  Text(

                    "القضاء: ${request["district"] ?? ""}",

                  ),





                  const SizedBox(
                      height:15
                  ),





                  Row(


                    children:[



                      Expanded(


                        child:

                        ElevatedButton.icon(


                          onPressed:() async {

                            await approve(request);

                          },


                          icon:

                          const Icon(
                            Icons.check,
                          ),



                          label:

                          const Text(
                              "موافقة"
                          ),



                          style:

                          ElevatedButton.styleFrom(

                            backgroundColor:
                            Colors.green,

                            foregroundColor:
                            Colors.white,

                          ),



                        ),


                      ),





                      const SizedBox(
                          width:10
                      ),





                      Expanded(


                        child:

                        ElevatedButton.icon(



                          onPressed:(){

                            reject(

                              request["id"].toString(),

                            );


                          },


                          icon:

                          const Icon(
                            Icons.close,
                          ),



                          label:

                          const Text(
                              "رفض"
                          ),



                          style:

                          ElevatedButton.styleFrom(

                            backgroundColor:
                            Colors.red,

                            foregroundColor:
                            Colors.white,

                          ),



                        ),


                      ),



                    ],


                  ),



                ],


              ),


            ),


          );



        },



      ),



    );


  }



}