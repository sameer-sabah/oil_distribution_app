import 'package:flutter/material.dart';

import '../models/station.dart';
import '../services/station_service.dart';
import '../widgets/station_card.dart';

import 'station_details_screen.dart';
import 'edit_station_screen.dart';
import 'send_notification_screen.dart';



class GovernmentStationsScreen extends StatefulWidget {
  final String branchId;

  const GovernmentStationsScreen({
    super.key,
    required this.branchId,
  });


  @override
  State<GovernmentStationsScreen> createState() =>
      _GovernmentStationsScreenState();


}







class _GovernmentStationsScreenState
    extends State<GovernmentStationsScreen> {



  final StationService stationService =
      StationService.instance;




  List<Station> stations = [];

  List<Station> filteredStations = [];



  bool loading = true;




  final TextEditingController searchController =
  TextEditingController();




  String search = "";







  @override
  void initState(){

    super.initState();

    loadStations();

  }









  Future<void> loadStations() async {



    if(mounted){

      setState(() {

        loading = true;

      });

    }






    final data =
    await stationService.getBranchStations(
      widget.branchId,
    );







    final governmentStations =

    data.where((station){


      return station.stationType.trim() ==

          "government" ||

          station.stationType.trim() ==

              "حكومية";



    }).toList();








    final Map<String,Station> unique = {};





    for(final station in governmentStations){



      final key =

          "${station.name}_${station.governorate}_${station.district}";



      unique[key] = station;



    }







    stations =
        unique.values.toList();




    filterStations();






    if(!mounted) {
      return;
    }




    setState(() {

      loading = false;

    });



  }









  void filterStations(){



    filteredStations =

        stations.where((station){



          if(search.trim().isEmpty){

            return true;

          }





          return station.name

              .toLowerCase()

              .contains(

            search.toLowerCase(),

          );



        }).toList();



  }









  @override
  Widget build(BuildContext context){



    return Scaffold(



      appBar:

      AppBar(


        backgroundColor:
        Colors.blue.shade800,



        title:

        Text(

          "المحطات الحكومية (${filteredStations.length})",

        ),



        centerTitle:
        true,


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

                "بحث عن محطة...",



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



                setState(() {



                  search = value;



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



                      final result =

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






                      if(result == true){



                        loadStations();



                      }



                    },







                    onDelete: () async {
                      await deleteStation(station);
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



        icon:

        const Icon(

            Icons.notifications

        ),




        label:

        const Text(

            "تبليغ"

        ),





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



                  ),



            ),



          );




        },



      ),




    );



  }











  Future<void> deleteStation(Station station) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("حذف المحطة نهائياً"),
        content: Text(
          "هل أنت متأكد من حذف محطة:\n\n"
              "${station.name}\n\n"
              "سيتم حذف بيانات المحطة المرتبطة بها.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text("حذف نهائياً"),
          ),
        ],
      ),
    );

    if (result != true) {
      return;
    }

    try {
      await stationService.deleteStation(
        station.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "تم حذف محطة ${station.name} نهائياً",
          ),
          backgroundColor: Colors.green,
        ),
      );

      await loadStations();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "فشل حذف المحطة: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }









  @override
  void dispose(){



    searchController.dispose();



    super.dispose();



  }




}
