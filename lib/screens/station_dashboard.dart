import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/station_service.dart';
import '../models/station.dart';
import 'notifications_screen.dart';


class StationDashboard extends StatefulWidget {


  const StationDashboard({
    super.key,
  });



  @override
  State<StationDashboard> createState() =>
      _StationDashboardState();


}







class _StationDashboardState
    extends State<StationDashboard> {



  final AuthService auth =
      AuthService.instance;



  final StationService service =
      StationService.instance;



  Station? station;

  bool loading = true;

  bool stationOpen = true;


  @override
  void initState(){

    super.initState();

    loadStation();

  }







  Future<void> loadStation() async {



    final user =
        auth.currentUser;



    if(user == null){

      return;

    }






    final data =
    await service.getStation(

      user.stationId,

    );







    if(!mounted)
      return;





    setState((){

      station = data;

      stationOpen =
          data!.workingStatus == "مفتوحة";

      loading = false;

    });



  }









  Future<void> updateFuel() async {



    if(station == null)
      return;






    final regular =
    TextEditingController(

      text:
      station!.regular95.toString(),

    );



    final improved =
    TextEditingController(

      text:
      station!.improved95.toString(),

    );

    final super95 =
    TextEditingController(

      text:
      station!.super95.toString(),

    );


    final whiteOil =
    TextEditingController(

      text:
      station!.whiteOil.toString(),

    );


    final lpg =
    TextEditingController(

      text:
      station!.lpg.toString(),

    );

    final diesel =
    TextEditingController(

      text:
      station!.diesel.toString(),

    );





    await showDialog(


      context: context,


      builder:(context){


        return AlertDialog(



          title:

          const Text(
              "تحديث الوقود"
          ),




          content:

          Column(


            mainAxisSize:
            MainAxisSize.min,



            children:[



              field(

                "بنزين عادي",

                regular,

              ),



              field(

                "بنزين محسن",

                improved,

              ),



              field(

                "ديزل",

                diesel,

              ),

              field(
                "بنزين سوبر",
                super95,
              ),

              field(
                "نفط أبيض",
                whiteOil,
              ),

              field(
                "غاز",
                lpg,
              ),

            ],


          ),


          actionsPadding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            0,
          ),






        );


      },


    );



  }









  Widget field(

      String title,

      TextEditingController controller,

      ){


    return Padding(


      padding:

      const EdgeInsets.only(

        bottom:10,

      ),



      child:


      TextField(


        controller:
        controller,



        keyboardType:
        TextInputType.number,



        decoration:

        InputDecoration(



          labelText:
          title,



          border:
          const OutlineInputBorder(),



        ),



      ),


    );


  }










  @override
  Widget build(BuildContext context){



    return Scaffold(




      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: "رجوع",
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "لوحة مدير المحطة",
        ),

        centerTitle: true,

        actions: [
          // 🔔 الإشعارات
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: "الإشعارات",
            onPressed: () {
              final user = auth.currentUser;

              if (user == null) {
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationsScreen(
                    userId: user.id,
                  ),
                ),
              );
            },
          ),

          // 🚪 تسجيل الخروج
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "تسجيل الخروج",
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("تسجيل الخروج"),
                    content: const Text(
                      "هل تريد تسجيل الخروج من الحساب؟",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text("إلغاء"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: const Text("تسجيل الخروج"),
                      ),
                    ],
                  );
                },
              );

              if (confirm != true) {
                return;
              }

              await auth.logout();

              if (!mounted) {
                return;
              }

              Navigator.pushNamedAndRemoveUntil(
                context,
                "/login",
                    (route) => false,
              );
            },
          ),
        ],
      ),






      body:



      loading



          ?



      const Center(

        child:

        CircularProgressIndicator(),

      )



          :



      station == null



          ?



      const Center(

        child:

        Text(

          "لا توجد محطة مرتبطة بالحساب",

        ),


      )



          :



      RefreshIndicator(



        onRefresh:

        loadStation,



        child:

        ListView(



          padding:

          const EdgeInsets.all(16),



          children:[







            Card(


              elevation:4,


              child:

              ListTile(


                leading:

                const CircleAvatar(


                  child:

                  Icon(
                    Icons.local_gas_station,
                  ),


                ),



                title:

                Text(

                  station!.name,

                  style:

                  const TextStyle(

                    fontWeight:
                    FontWeight.bold,

                    fontSize:18,

                  ),

                ),




                subtitle:

                Text(

                  "${station!.governorate} - ${station!.district}",

                ),



              ),



            ),

            const SizedBox(
              height: 10,
            ),

            Card(
              child: ListTile(

                leading: const Icon(
                  Icons.update,
                  color: Colors.blue,
                ),

                title: const Text(
                  "آخر تحديث",
                ),

                subtitle: Text(
                  station!.updatedAt.isEmpty
                      ? "لا يوجد تحديث"
                      : station!.updatedAt,
                ),

              ),
            ),





            const SizedBox(
              height:15,
            ),








            Card(



              child:

              ListTile(


                leading:

                Icon(

                  Icons.info,

                  color:

                  station!.workingStatus ==
                      "مفتوحة"

                      ?

                  Colors.green

                      :

                  Colors.red,

                ),



                title:

                const Text(
                    "حالة المحطة"
                ),



                trailing:

                Text(

                  station!.workingStatus,

                ),



              ),



            ),







            const SizedBox(
              height:20,
            ),






            const Text(

              "المنتجات المتوفرة",

              style:

              TextStyle(

                fontSize:20,

                fontWeight:
                FontWeight.bold,

              ),

            ),






            fuelCard(

              "بنزين عادي",

              station!.regular95,

            ),



            fuelCard(

              "بنزين محسن",

              station!.improved95,

            ),



            fuelCard(

              "بنزين سوبر",

              station!.super95,

            ),



            fuelCard(

              "ديزل",

              station!.diesel,

            ),



            fuelCard(

              "نفط أبيض",

              station!.whiteOil,

            ),



            fuelCard(

              "غاز",

              station!.lpg,

            ),








            const SizedBox(
              height:20,
            ),




            SwitchListTile(
              title: Text(
                stationOpen
                    ? "المحطة مفتوحة 🟢"
                    : "المحطة مغلقة 🔴",
              ),
              value: stationOpen,
              onChanged: (value){
                setState(() {
                  stationOpen = value;
                });
              },
            ),

            const SizedBox(
              height:20,
            ),


            ElevatedButton.icon(



              onPressed:

              updateFuel,



              icon:

              const Icon(
                Icons.edit,
              ),



              label:

              const Text(

                "تحديث الكميات",

              ),



              style:

              ElevatedButton.styleFrom(

                minimumSize:

                const Size(

                  double.infinity,

                  55,

                ),

              ),



            )







          ],



        ),



      ),





    );



  }









  Widget fuelCard(

      String name,

      int value,

      ){


    return Card(



      child:

      ListTile(



        leading:

        const Icon(

          Icons.local_gas_station,

          color:Colors.blue,

        ),




        title:

        Text(name),




        trailing:

        Text(

          value.toString(),

          style:

          const TextStyle(

            fontSize:20,

            fontWeight:
            FontWeight.bold,

          ),

        ),



      ),


    );


  }



}