import 'package:flutter/material.dart';

import '../../models/station.dart';


class StationDetailsScreen extends StatelessWidget {

  final Station station;


  const StationDetailsScreen({

    super.key,

    required this.station,

  });



  @override
  Widget build(BuildContext context){


    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "تفاصيل المحطة",
        ),

        centerTitle: true,

      ),



      body: ListView(

        padding:
        const EdgeInsets.all(16),


        children: [


          const Icon(

            Icons.local_gas_station,

            size:90,

            color:Colors.blue,

          ),



          const SizedBox(
            height:20,
          ),



          infoCard(
            "اسم المحطة",
            station.name,
            Icons.business,
          ),



          infoCard(
            "النوع",
            station.stationType,
            Icons.category,
          ),



          infoCard(
            "المحافظة",
            station.governorate,
            Icons.location_city,
          ),



          infoCard(
            "القضاء",
            station.district,
            Icons.location_on,
          ),



          infoCard(
            "الحالة",
            station.workingStatus,
            Icons.power,
          ),



          infoCard(
            "بنزين عادي",
            "${station.regular95} لتر",
            Icons.local_gas_station,
          ),



          infoCard(
            "بنزين محسن",
            "${station.improved95} لتر",
            Icons.local_gas_station,
          ),



          infoCard(
            "زيت الغاز",
            "${station.diesel} لتر",
            Icons.local_gas_station,
          ),



          const SizedBox(
            height:20,
          ),



          ElevatedButton.icon(

            icon:
            const Icon(Icons.edit),


            label:
            const Text(
              "تعديل بيانات المحطة",
            ),


            onPressed: (){

              // نربط صفحة التعديل لاحقاً

            },

          ),



          const SizedBox(
            height:10,
          ),



          ElevatedButton.icon(

            icon:
            const Icon(Icons.notifications),


            label:
            const Text(
              "إرسال إشعار للمحطة",
            ),


            onPressed: (){


            },

          ),


        ],


      ),


    );


  }





  Widget infoCard(
      String title,
      String value,
      IconData icon,
      ){


    return Card(

      child: ListTile(

        leading:
        Icon(icon),


        title:
        Text(title),


        trailing:
        Text(
          value,
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