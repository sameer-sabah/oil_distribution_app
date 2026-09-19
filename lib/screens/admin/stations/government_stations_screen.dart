import 'package:flutter/material.dart';

import '../../../models/station.dart';
import '../../../services/station_service.dart';

import '../../../widgets/station_card.dart';

import 'station_details_screen.dart';
import 'edit_station_screen.dart';
import '../../send_notification_screen.dart';


class GovernmentStationsScreen extends StatefulWidget {

  const GovernmentStationsScreen({
    super.key,
  });


  @override
  State<GovernmentStationsScreen> createState() =>
      _GovernmentStationsScreenState();

}



class _GovernmentStationsScreenState
    extends State<GovernmentStationsScreen> {



  final StationService service =
      StationService.instance;



  List<Station> stations = [];

  List<Station> filteredStations = [];


  bool loading = true;



  final TextEditingController searchController =
  TextEditingController();



  String searchText = "";





  @override
  void initState(){

    super.initState();

    loadStations();

  }







  Future<void> loadStations() async {


    setState(() {

      loading = true;

    });



    final data =
    await service.getStations();



    stations =
        data.where((station){

          return station.stationType.trim()
              ==
              "حكومية";

        }).toList();




    filterStations();



    if(!mounted)return;



    setState(() {

      loading = false;

    });


  }







  void filterStations(){



    if(searchText.trim().isEmpty){


      filteredStations =
          List.from(stations);


      return;

    }





    filteredStations =
        stations.where((station){


          return station.name
              .toLowerCase()
              .contains(
              searchText.toLowerCase()
          );


        }).toList();



  }







  @override
  Widget build(BuildContext context){


    return Scaffold(



      appBar: AppBar(

        title: Text(

          "المحطات الحكومية (${filteredStations.length})",

        ),

        centerTitle: true,

      ),





      body:

      loading

          ?

      const Center(

        child:

        CircularProgressIndicator(),

      )

          :

      Column(

        children: [



          Padding(

            padding:
            const EdgeInsets.all(12),


            child:

            TextField(

              controller:
              searchController,


              decoration:

              InputDecoration(

                hintText:
                "بحث عن محطة",


                prefixIcon:
                const Icon(
                    Icons.search
                ),


                border:

                OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(15),

                ),

              ),



              onChanged:(value){


                searchText =
                    value;


                setState(() {

                  filterStations();

                });


              },

            ),

          ),





          Expanded(


            child:

            RefreshIndicator(


              onRefresh:
              loadStations,


              child:

              ListView.builder(



                itemCount:
                filteredStations.length,



                itemBuilder:
                    (context,index){


                  final station =
                  filteredStations[index];




                  return StationCard(


                    station:
                    station,


                    distance:
                    0,



                    onDetails:(){



                      Navigator.push(


                        context,


                        MaterialPageRoute(


                          builder:(_)=>

                              StationDetailsScreen(

                                station:
                                station,

                              ),


                        ),


                      );


                    },






                    onEdit:() async {



                      await Navigator.push(


                        context,


                        MaterialPageRoute(


                          builder:(_)=>

                              EditStationScreen(

                                station:
                                station,

                              ),


                        ),


                      );



                      loadStations();


                    },






                    onDelete:(){


                      deleteStation(
                          station
                      );


                    },





                    onMap:(){},



                  );


                },



              ),


            ),


          ),



        ],

      ),





      floatingActionButton:


      FloatingActionButton.extended(


        onPressed:(){



          if(filteredStations.isEmpty) {
            return;
          }




          Navigator.push(


            context,


            MaterialPageRoute(


              builder:(_)=>

                  SendNotificationScreen(

                    station:
                    filteredStations.first,

                  )


            ),


          );



        },


        icon:

        const Icon(
            Icons.notifications
        ),



        label:

        const Text(
            "تبليغ"
        ),


      ),



    );


  }








  Future<void> deleteStation(
      Station station
      ) async {



    final result =
    await showDialog<bool>(



      context:
      context,



      builder:(_){


        return AlertDialog(



          title:

          const Text(
              "حذف المحطة"
          ),




          content:

          Text(

              "هل تريد حذف ${station.name} ؟"

          ),




          actions:[



            TextButton(

              onPressed:(){

                Navigator.pop(
                    context,
                    false
                );

              },


              child:

              const Text(
                  "إلغاء"
              ),

            ),




            ElevatedButton(


              style:

              ElevatedButton.styleFrom(

                backgroundColor:
                Colors.red,

              ),


              onPressed:(){

                Navigator.pop(
                    context,
                    true
                );

              },



              child:

              const Text(
                  "حذف"
              ),


            ),



          ],


        );


      },


    );






    if(result != true) {
      return;
    }




    await service.deleteStation(
        station.id
    );



    if(!mounted)return;



    ScaffoldMessenger.of(context)
        .showSnackBar(


      const SnackBar(

        content:

        Text(
            "تم حذف المحطة"
        ),

      ),


    );



    loadStations();


  }






  @override
  void dispose(){

    searchController.dispose();

    super.dispose();

  }


}