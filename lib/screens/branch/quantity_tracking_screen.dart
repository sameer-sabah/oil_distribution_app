import 'package:flutter/material.dart';

import '../../models/station.dart';
import '../../services/auth_service.dart';
import '../../services/station_service.dart';
import '../../services/notification_service.dart';


class QuantityTrackingScreen extends StatefulWidget {

  const QuantityTrackingScreen({
    super.key,
  });


  @override
  State<QuantityTrackingScreen> createState() =>
      _QuantityTrackingScreenState();

}



class _QuantityTrackingScreenState
    extends State<QuantityTrackingScreen> {

  final AuthService auth =
      AuthService.instance;

  final StationService stationService =
      StationService.instance;

  final NotificationService notificationService =
      NotificationService.instance;
  List<Station> stations = [];

  Station? selectedStation;

  bool loading = true;
  String selectedProduct = "بنزين عادي";

  final List<String> products = [
    "بنزين عادي",
    "بنزين محسن",
    "بنزين سوبر",
    "زيت كاز",
    "نفط أبيض",
    "غاز سائل",
  ];
  @override
  void initState() {
    super.initState();

    loadStations();
  }

  Future<void> loadStations() async {
    final user = auth.currentUser;

    if (user == null) return;

    final loadedStations =
    await stationService.getBranchStations(
      user.branchId,
    );

    // إزالة المحطات المكررة حسب ID
    final uniqueStations = <String, Station>{};

    for (final station in loadedStations) {
      uniqueStations[station.id] = station;
    }

    if (!mounted) return;

    setState(() {
      stations = uniqueStations.values.toList();

      // التأكد أن المحطة المختارة ما زالت موجودة
      if (selectedStation != null &&
          !stations.any(
                (station) => station.id == selectedStation!.id,
          )) {
        selectedStation = null;
      }

      loading = false;
    });
  }
  Future<void> sendQuantityNotification() async {
    if (selectedStation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("يرجى اختيار محطة أولاً"),
        ),
      );
      return;
    }

    final station = selectedStation!;

    try {
      for (final product in products) {
        int productQuantity;

        switch (product) {
          case "بنزين عادي":
            productQuantity = station.regular95;
            break;

          case "بنزين محسن":
            productQuantity = station.improved95;
            break;

          case "بنزين سوبر":
            productQuantity = station.super95;
            break;

          case "زيت كاز":
            productQuantity = station.diesel;
            break;

          case "نفط أبيض":
            productQuantity = station.whiteOil;
            break;

          case "غاز سائل":
            productQuantity = station.lpg;
            break;

          default:
            productQuantity = 0;
        }

        await notificationService.notifyQuantityUpdate(
          stationId: station.id,
          stationName: station.name,
          productName: product,
          quantity: productQuantity,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "تم إرسال إشعارات جميع المنتجات إلى ${station.name}",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "فشل إرسال الإشعارات: $e",
          ),
        ),
      );
    }
  }
  int quantity(Station station){


    switch(selectedProduct){


      case "بنزين عادي":
        return station.regular95;


      case "بنزين محسن":
        return station.improved95;


      case "بنزين سوبر":
        return station.super95;


      case "زيت كاز":
        return station.diesel;


      case "نفط أبيض":
        return station.whiteOil;


      case "غاز سائل":
        return station.lpg;


      default:
        return 0;

    }


  }






  Color statusColor(int value){

    if(value <= 0)
      return Colors.red;


    if(value < 5000)
      return Colors.orange;


    return Colors.green;

  }






  String statusText(int value){

    if(value <= 0)
      return "نفذ";


    if(value < 5000)
      return "قليل";


    return "متوفر";

  }







  int get totalStations =>
      stations.length;



  int get availableStations =>

      stations.where(
              (e)=>
          quantity(e) > 0
      ).length;




  int get lowStations =>

      stations.where(
              (e)=>
          quantity(e) < 5000
      ).length;







  @override
  Widget build(BuildContext context){



    final user =
        auth.currentUser;



    return Scaffold(


      appBar:

      AppBar(

        title:

        Text(

          "متابعة كميات المنتجات النفطية - ${user?.branchName ?? ""}",

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



      Directionality(

        textDirection:
        TextDirection.rtl,


        child:

        ListView(

          padding:
          const EdgeInsets.all(12),


          children:[





            // بطاقة الملخص


            Row(


              children:[


                Expanded(

                  child:
                  summaryCard(

                    "المحطات",

                    totalStations.toString(),

                    Icons.local_gas_station,

                    Colors.blue,

                  ),

                ),



                Expanded(

                  child:
                  summaryCard(

                    "متوفر",

                    availableStations.toString(),

                    Icons.check_circle,

                    Colors.green,

                  ),

                ),




                Expanded(

                  child:
                  summaryCard(

                    "ناقصة",

                    lowStations.toString(),

                    Icons.warning,

                    Colors.orange,

                  ),

                ),



              ],


            ),





            const SizedBox(height:20),






            DropdownButtonFormField<Station>(


              value:selectedStation,


              decoration:

              const InputDecoration(

                labelText:
                "اختيار المحطة",

                border:
                OutlineInputBorder(),

              ),



              items:[



                const DropdownMenuItem(

                  value:null,

                  child:
                  Text(
                    "جميع المحطات",
                  ),

                ),




                ...stations.map((e){


                  return DropdownMenuItem(

                    value:e,

                    child:
                    Text(e.name),

                  );


                })

              ],



              onChanged:(v){


                setState((){

                  selectedStation=v;

                });


              },


            ),





            const SizedBox(height:15),




            DropdownButtonFormField<String>(


              value:selectedProduct,


              decoration:

              const InputDecoration(

                labelText:
                "اختيار المنتج",

                border:
                OutlineInputBorder(),

              ),



              items:

              products.map((e){


                return DropdownMenuItem(

                  value:e,

                  child:
                  Text(e),

                );


              }).toList(),




              onChanged:(v){


                setState((){

                  selectedProduct=v!;

                });


              },

            ),






            const SizedBox(height:20),






            Card(


              elevation:5,


              child:

              Padding(

                padding:
                const EdgeInsets.all(20),


                child:

                Column(


                  children:[



                    Text(

                      "⛽ $selectedProduct",

                      style:

                      const TextStyle(

                        fontSize:22,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),



                    const SizedBox(height:10),



                    Text(

                      "إجمالي الكمية",

                      style:
                      TextStyle(

                        color:
                        Colors.grey,

                      ),

                    ),



                    Text(

                      "${stations.fold<int>(0,(sum,e)=>sum+quantity(e))} لتر",

                      style:

                      const TextStyle(

                        fontSize:28,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),



                  ],

                ),

              ),


            ),






            const SizedBox(height:20),






            const Text(

              "جدول المحطات",

              style:

              TextStyle(

                fontSize:20,

                fontWeight:
                FontWeight.bold,

              ),

            ),






            DataTable(


              columns:[


                const DataColumn(
                    label:Text("المحطة")
                ),


                DataColumn(
                    label:
                    Text(selectedProduct)
                ),


                const DataColumn(
                    label:Text("الحالة")
                ),



              ],



              rows:

              stations

                  .where((s)=>

              selectedStation==null ||

                  selectedStation!.id==s.id

              )


                  .map((station){



                final qty =
                quantity(station);



                return DataRow(

                    cells:[



                      DataCell(
                          Text(
                              station.name
                          )
                      ),



                      DataCell(
                          Text(
                              "$qty"
                          )
                      ),



                      DataCell(

                        Text(

                          statusText(qty),

                          style:

                          TextStyle(

                            color:
                            statusColor(qty),

                            fontWeight:
                            FontWeight.bold,

                          ),

                        ),

                      ),


                    ]

                );


              }).toList(),



            ),






            const SizedBox(height:20),





            ElevatedButton.icon(

              icon:
              const Icon(Icons.refresh),


              label:
              const Text(
                  "تحديث الكميات"
              ),


              onPressed:
              loadStations,


            ),




            ElevatedButton.icon(
              icon: const Icon(
                Icons.notifications_active,
              ),
              label: const Text(
                "إرسال إشعار للمحطة",
              ),
              onPressed: sendQuantityNotification,
            ),




            ElevatedButton.icon(

              icon:
              const Icon(
                  Icons.map
              ),


              label:
              const Text(
                  "فتح الموقع على الخريطة"
              ),


              onPressed:(){


              },

            ),



          ],


        ),


      ),


    );

  }








  Widget summaryCard(

      String title,

      String value,

      IconData icon,

      Color color,

      ){


    return Card(


      child:

      Padding(

        padding:
        const EdgeInsets.all(8),


        child:

        Column(

          children:[


            Icon(
              icon,
              color:color,
            ),


            Text(

              value,

              style:

              const TextStyle(

                fontSize:22,

                fontWeight:
                FontWeight.bold,

              ),

            ),


            Text(title),


          ],


        ),


      ),


    );


  }



}