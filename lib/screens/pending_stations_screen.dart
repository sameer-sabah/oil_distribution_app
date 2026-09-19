import 'package:flutter/material.dart';
import '../services/station_service.dart';
import '../services/auth_service.dart';
import '../core/constants/user_roles.dart';
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
    if (mounted) {
      setState(() {
        loading = true;
      });
    }

    try {
      final all =
      await stationService.getPendingStationRequests();

      debugPrint("عدد كل الطلبات = ${all.length}");

      final user = auth.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          requests = [];
          loading = false;
        });

        return;
      }

      debugPrint(
        "مدير الفرع: ${user.branchId}",
      );

      // مدير النظام يرى جميع الطلبات
      if (user.role == UserRoles.admin) {
        requests = all;
      }

      // مدير الفرع يرى طلبات فرعه فقط
      else if (user.role == UserRoles.branchManager) {
        requests = all.where((request) {
          return request["branchId"]?.toString() ==
              user.branchId.toString();
        }).toList();
      }

      // أي دور آخر لا يرى الطلبات
      else {
        requests = [];
      }

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    } catch (e) {
      debugPrint(
        "خطأ في جلب طلبات تسجيل المحطات: $e",
      );

      if (!mounted) return;

      setState(() {
        requests = [];
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "تعذر تحميل طلبات تسجيل المحطات: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }








  Future<void> approve(
      Map<String, dynamic> request,
      ) async {

    try {

      // ==========================================
      // 1. اعتماد المحطة وإنشاء الحساب
      // ==========================================

      final account =
      await stationService
          .approveRegistration(
        request: request,
      );

      if (!mounted) return;

      // ==========================================
      // 2. عرض بيانات الحساب + سؤال WhatsApp
      // ==========================================

      final sendWhatsApp =
      await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {

          return AlertDialog(

            title: const Text(
              "تم اعتماد المحطة",
              textAlign: TextAlign.center,
            ),

            content: Column(
              mainAxisSize:
              MainAxisSize.min,

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  "اسم المحطة:\n"
                      "${account["stationName"] ?? ""}",
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                Text(
                  "اسم المستخدم:\n"
                      "${account["username"] ?? ""}",
                  style:
                  const TextStyle(
                    fontSize: 16,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  "كلمة المرور:\n"
                      "${account["password"] ?? ""}",
                  style:
                  const TextStyle(
                    fontSize: 16,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                const Text(
                  "هل تريد إرسال بيانات الدخول إلى صاحب المحطة عبر WhatsApp؟",
                  style:
                  TextStyle(
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),

            actions: [

              TextButton(
                onPressed: () {

                  Navigator.pop(
                    dialogContext,
                    false,
                  );

                },
                child: const Text(
                  "عدم الإرسال",
                ),
              ),

              ElevatedButton.icon(

                onPressed: () {

                  Navigator.pop(
                    dialogContext,
                    true,
                  );

                },

                icon: const Icon(
                  Icons.send,
                ),

                label: const Text(
                  "إرسال WhatsApp",
                ),
              ),
            ],
          );
        },
      );

      // ==========================================
      // 3. إذا اختار إرسال WhatsApp
      // ==========================================

      if (sendWhatsApp == true) {

        try {

          await stationService
              .sendStationCredentialsWhatsApp(

            stationId:
            account["stationId"]
                ?.toString() ??
                "",

            stationName:
            account["stationName"]
                ?.toString() ??
                "",

            phone:
            account["phone"]
                ?.toString() ??
                request["phone"]
                    ?.toString() ??
                "",

            username:
            account["username"]
                ?.toString() ??
                "",

            password:
            account["password"]
                ?.toString() ??
                "",

            branchId:
            account["branchId"]
                ?.toString() ??
                request["branchId"]
                    ?.toString() ??
                "",
          );

          if (!mounted) return;

          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                "تم اعتماد المحطة وفتح WhatsApp برسالة جاهزة للإرسال",
              ),
              backgroundColor:
              Colors.green,
            ),
          );

        } catch (e) {

          if (!mounted) return;

          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                "تم اعتماد المحطة، لكن تعذر فتح WhatsApp: $e",
              ),
              backgroundColor:
              Colors.orange,
            ),
          );
        }

      } else {

        // ==========================================
        // 4. اختار عدم الإرسال
        // ==========================================

        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "تم اعتماد المحطة بدون إرسال WhatsApp",
            ),
            backgroundColor:
            Colors.green,
          ),
        );
      }

      // ==========================================
      // 5. تحديث قائمة الطلبات
      // ==========================================

      await loadRequests();

    } catch (e) {

      if (!mounted) return;

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