import 'package:flutter/material.dart';

import '../../models/station.dart';
import '../../services/auth_service.dart';
import '../../services/station_service.dart';



class EmployeeDashboard extends StatefulWidget {

  const EmployeeDashboard({
    super.key,
  });



  @override
  State<EmployeeDashboard> createState() =>
      _EmployeeDashboardState();


}









class _EmployeeDashboardState
    extends State<EmployeeDashboard> {



  late Future<Station?> stationFuture;



  final StationService stationService =
      StationService.instance;









  @override
  void initState(){


    super.initState();




    final user =
    AuthService.instance.currentUser!;




    stationFuture =

        stationService.getStation(

          user.stationId,

        );



  }













  @override
  Widget build(BuildContext context){



    return Scaffold(





      appBar:

      AppBar(



        title:

        const Text(

            "لوحة الموظف"

        ),



        centerTitle:

        true,



      ),







      body:



      FutureBuilder<Station?>(




        future:

        stationFuture,





        builder:(context,snapshot){





          if(snapshot.connectionState ==
              ConnectionState.waiting){



            return const Center(



              child:

              CircularProgressIndicator(),



            );



          }








          if(snapshot.hasError){



            return Center(



              child:

              Text(



                snapshot.error.toString(),



                style:

                const TextStyle(



                  color:

                  Colors.red,



                ),



              ),



            );



          }









          if(!snapshot.hasData ||
              snapshot.data == null){



            return const Center(



              child:

              Text(



                "لم يتم العثور على بيانات المحطة",



                style:

                TextStyle(



                  fontSize:18,



                ),



              ),



            );



          }









          final station =

          snapshot.data!;









          return ListView(




            padding:

            const EdgeInsets.all(16),






            children: [






              infoCard(

                Icons.local_gas_station,

                station.name,

                "اسم المحطة",

              ),







              infoCard(

                Icons.person,

                station.managerName,

                "مدير المحطة",

              ),








              infoCard(

                Icons.location_city,

                station.governorate,

                station.district,

              ),








              infoCard(

                Icons.phone,

                station.phone,

                "هاتف المحطة",

              ),







              const SizedBox(height:20),






              const Text(



                "الكميات الحالية",



                style:

                TextStyle(



                  fontSize:20,

                  fontWeight:

                  FontWeight.bold,



                ),



              ),








              const SizedBox(height:10),







              fuelCard(

                "بنزين عادي",

                station.regular95,

              ),






              fuelCard(

                "بنزين محسن",

                station.improved95,

              ),






              fuelCard(

                "بنزين سوبر",

                station.super95,

              ),






              fuelCard(

                "زيت الغاز",

                station.diesel,

              ),






              fuelCard(

                "النفط الأبيض",

                station.whiteOil,

              ),






              fuelCard(

                "الغاز السائل",

                station.lpg,

              ),





            ],



          );



        },



      ),



    );



  }














  Widget infoCard(

      IconData icon,

      String title,

      String subtitle,

      ){



    return Card(



      child:

      ListTile(



        leading:

        Icon(icon),





        title:

        Text(

            title

        ),





        subtitle:

        Text(

            subtitle

        ),



      ),



    );



  }












  Widget fuelCard(

      String name,

      int quantity,

      ){



    return Card(



      child:

      ListTile(



        leading:

        const Icon(

            Icons.local_gas_station

        ),





        title:

        Text(

            name

        ),





        trailing:

        Text(



          "$quantity لتر",





          style:

          const TextStyle(



            fontWeight:

            FontWeight.bold,



          ),



        ),




      ),



    );



  }



}