import 'package:flutter/material.dart';

import '../models/station.dart';
import '../services/station_service.dart';

import 'add_station_screen.dart';
import 'edit_station_screen.dart';



class StationsScreen extends StatefulWidget {


  const StationsScreen({

    super.key,

  });



  @override
  State<StationsScreen> createState() =>
      _StationsScreenState();


}








class _StationsScreenState
    extends State<StationsScreen> {



  final StationService stationService =
      StationService.instance;



  List<Station> stations = [];



  bool loading = true;






  @override
  void initState(){

    super.initState();

    loadStations();

  }









  Future<void> loadStations() async {


    setState(() {

      loading = true;

    });





    stations =
    await stationService.getStations();





    if(!mounted)
      return;




    setState(() {

      loading = false;

    });



  }









  Future<void> deleteStation(
      String id
      ) async {



    await stationService.deleteStation(
        id
    );



    loadStations();



  }









  @override
  Widget build(BuildContext context){



    return Scaffold(



      appBar:

      AppBar(


        title:

        const Text(
          "إدارة المحطات",
        ),



        centerTitle:
        true,



        actions: [



          IconButton(


            icon:

            const Icon(
              Icons.refresh,
            ),



            onPressed:

            loadStations,


          ),


        ],



      ),







      floatingActionButton:


      FloatingActionButton.extended(



        icon:

        const Icon(
          Icons.add,
        ),




        label:

        const Text(
          "إضافة محطة",
        ),





        onPressed: () async {



          await Navigator.push(


            context,


            MaterialPageRoute(


              builder: (_) =>

              const AddStationScreen(),


            ),



          );




          loadStations();



        },


      ),







      body:

      loading



          ?



      const Center(


        child:

        CircularProgressIndicator(),


      )




          :



      stations.isEmpty




          ?



      const Center(


        child:

        Text(

          "لا توجد محطات",

          style:

          TextStyle(

            fontSize:18,

          ),

        ),



      )





          :



      RefreshIndicator(



        onRefresh:

        loadStations,



        child:



        ListView.builder(



          itemCount:

          stations.length,




          itemBuilder:

              (context,index){



            final station =
            stations[index];






            return Card(



              margin:

              const EdgeInsets.all(10),





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



                  station.name,



                  style:

                  const TextStyle(



                    fontWeight:

                    FontWeight.bold,



                  ),



                ),









                subtitle:


                Column(



                  crossAxisAlignment:

                  CrossAxisAlignment.start,



                  children: [






                    Text(

                      "المحافظة: ${station.governorate}",

                    ),






                    Text(

                      "الفرع: ${station.branchName}",

                    ),






                    Text(

                      "الحالة: ${station.workingStatus}",

                    ),






                    Text(

                      "النوع: ${station.stationType}",

                    ),





                  ],


                ),










                trailing:


                PopupMenuButton(




                  itemBuilder:

                      (_) => const [





                    PopupMenuItem(



                      value:

                      "edit",



                      child:

                      Text(
                        "تعديل",
                      ),


                    ),







                    PopupMenuItem(



                      value:

                      "delete",



                      child:

                      Text(
                        "حذف",
                      ),



                    ),






                  ],






                  onSelected:

                      (value) async {






                    if(value == "edit"){





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

                        loadStations();

                      }





                    }









                    if(value == "delete"){



                      await deleteStation(

                        station.id,

                      );



                    }







                  },





                ),






              ),



            );




          },




        ),




      ),



    );



  }




}