import 'package:flutter/material.dart';

import '../models/station.dart';
import '../services/station_service.dart';

import '../widgets/station_card.dart';

import 'station_details_screen.dart';
import 'edit_station_screen.dart';
import 'send_notification_screen.dart';



class PrivateStationsScreen extends StatefulWidget {


  final String branchId;

  const PrivateStationsScreen({
    super.key,
    required this.branchId,
  });



  @override
  State<PrivateStationsScreen> createState() =>
      _PrivateStationsScreenState();


}








class _PrivateStationsScreenState
    extends State<PrivateStationsScreen> {



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








    final privateStations =

    data.where((station){



      return station.stationType.trim() ==

          "private" ||

          station.stationType.trim() ==

              "أهلية";



    }).toList();








    final Map<String,Station> unique = {};







    for(final station in privateStations){



      final key =

          "${station.name.trim()}_"
          "${station.governorate.trim()}_"
          "${station.district.trim()}";





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



        title:


        Text(

          "المحطات الأهلية (${filteredStations.length})",

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












  Future<void> deleteStation(

      Station station,

      ) async {






    final result =

    await showDialog<bool>(



      context:

      context,



      builder:(_)=>AlertDialog(





        title:

        const Text(

            "حذف المحطة"

        ),





        content:

        Text(



          "هل تريد حذف المحطة\n\n${station.name}\n\nنهائياً؟",



        ),






        actions: [





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




      ),



    );








    if(result != true) {
      return;
    }








    try{



      await stationService.deleteStation(

          station.id

      );







      if(!mounted) {
        return;
      }







      ScaffoldMessenger.of(context)

          .showSnackBar(




        const SnackBar(



          content:

          Text(

              "تم حذف المحطة بنجاح"

          ),



          backgroundColor:

          Colors.green,



        ),



      );







      loadStations();




    }

    catch(e){





      if(!mounted) {
        return;
      }







      ScaffoldMessenger.of(context)

          .showSnackBar(



        SnackBar(



          content:

          Text(

              e.toString()

          ),



          backgroundColor:

          Colors.red,



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
