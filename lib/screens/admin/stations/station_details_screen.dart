import 'package:flutter/material.dart';

import '../../../models/station.dart';
import '../../../services/database_service.dart';

import 'edit_station_screen.dart';
import '../../send_notification_screen.dart';



class StationDetailsScreen extends StatefulWidget {

  final Station station;


  const StationDetailsScreen({
    super.key,
    required this.station,
  });



  @override
  State<StationDetailsScreen> createState() =>
      _StationDetailsScreenState();

}





class _StationDetailsScreenState
    extends State<StationDetailsScreen> {



  final DatabaseService database =
      DatabaseService.instance;



  late Station station;



  @override
  void initState() {

    super.initState();

    station = widget.station;

  }







  Widget infoTile(
      String title,
      String value,
      IconData icon,
      ){

    return Card(

      margin:
      const EdgeInsets.only(bottom:10),

      child:

      ListTile(

        leading:

        Icon(
          icon,
          color: Colors.blue,
        ),


        title:

        Text(

          title,

          style:

          const TextStyle(

            fontWeight:
            FontWeight.bold,

          ),

        ),


        subtitle:

        Text(

          value.isEmpty
              ? "-"
              : value,

        ),

      ),

    );

  }









  Widget fuelTile(
      String title,
      int value,
      Color color,
      ){

    return Card(

      child:

      ListTile(

        leading:

        CircleAvatar(

          backgroundColor:
          color,

          child:

          const Icon(

            Icons.local_gas_station,

            color:
            Colors.white,

          ),

        ),



        title:

        Text(title),



        trailing:

        Text(

          "$value لتر",

          style:

          TextStyle(

            color:
            color,

            fontWeight:
            FontWeight.bold,

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
          "تفاصيل المحطة",
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



            CircleAvatar(

              radius:45,

              backgroundColor:
              Colors.blue.shade100,


              child:

              const Icon(

                Icons.local_gas_station,

                size:45,

                color:
                Colors.blue,

              ),

            ),





            const SizedBox(
              height:15,
            ),





            Text(

              station.name,

              style:

              const TextStyle(

                fontSize:24,

                fontWeight:
                FontWeight.bold,

              ),

            ),




            const SizedBox(
              height:25,
            ),





            infoTile(
                "مدير المحطة",
                station.managerName,
                Icons.person
            ),



            infoTile(
                "هاتف المدير",
                station.managerPhone,
                Icons.phone
            ),



            infoTile(
                "المحافظة",
                station.governorate,
                Icons.location_city
            ),



            infoTile(
                "القضاء",
                station.district,
                Icons.map
            ),



            infoTile(
                "العنوان",
                station.address,
                Icons.home
            ),



            infoTile(
                "الهاتف",
                station.phone,
                Icons.phone_android
            ),



            infoTile(
                "نوع المحطة",
                station.stationType,
                Icons.category
            ),



            infoTile(
                "حالة المحطة",
                station.workingStatus,
                Icons.access_time
            ),





            const SizedBox(
              height:20,
            ),




            const Align(

              alignment:
              Alignment.centerRight,

              child:

              Text(

                "كميات المنتجات",

                style:

                TextStyle(

                  fontSize:20,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),

            ),





            const SizedBox(
              height:10,
            ),





            fuelTile(
                "بنزين عادي",
                station.regular95,
                Colors.green
            ),



            fuelTile(
                "بنزين محسن",
                station.improved95,
                Colors.blue
            ),



            fuelTile(
                "بنزين سوبر",
                station.super95,
                Colors.purple
            ),



            fuelTile(
                "زيت الغاز",
                station.diesel,
                Colors.orange
            ),



            fuelTile(
                "النفط الأبيض",
                station.whiteOil,
                Colors.brown
            ),



            fuelTile(
                "الغاز السائل",
                station.lpg,
                Colors.teal
            ),





            const SizedBox(
              height:25,
            ),





            ElevatedButton.icon(

              icon:
              const Icon(Icons.edit),


              label:

              const Text(
                  "تعديل المحطة"
              ),



              style:

              ElevatedButton.styleFrom(

                minimumSize:

                const Size(
                    double.infinity,
                    55
                ),

              ),




              onPressed: () async {



                final result =
                await Navigator.push(


                  context,


                  MaterialPageRoute(


                    builder: (_) =>

                        EditStationScreen(

                          station:
                          station,

                        ),


                  ),


                );



                if(result == true){


                  final updated =

                  await database.getStation(
                      station.id
                  );



                  if(updated != null){


                    setState(() {


                      station =
                          updated;


                    });


                  }


                }


              },


            ),






            const SizedBox(
              height:15,
            ),





            ElevatedButton.icon(

              icon:
              const Icon(Icons.notifications),


              label:

              const Text(
                  "إرسال تبليغ"
              ),



              style:

              ElevatedButton.styleFrom(

                backgroundColor:
                Colors.orange,

                foregroundColor:
                Colors.white,


                minimumSize:

                const Size(
                    double.infinity,
                    55
                ),

              ),



              onPressed: () {


                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>

                        SendNotificationScreen(

                          station:station,

                        ),

                  ),

                );


              },


            ),





          ],


        ),


      ),


    );

  }

}