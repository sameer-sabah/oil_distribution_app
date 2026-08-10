import 'package:flutter/material.dart';

import '../../../models/station.dart';
import '../../../services/database_service.dart';

import '../station_management/add_station_screen.dart';
import 'edit_station_screen.dart';
import 'station_details_screen.dart';


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



  final DatabaseService database =
      DatabaseService.instance;



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



    final allStations =
    await database.getStations();



    stations =
        allStations.where((e){


          return e.stationType.trim() == "أهلية" &&

              e.branchId ==
                  widget.branchId;


        }).toList();





    if(!mounted)
      return;



    setState(() {

      loading = false;

    });


  }







  Future<void> deleteStation(
      String id
      ) async {


    await database.deleteStation(id);


    loadStations();


  }









  @override
  Widget build(BuildContext context){


    return Scaffold(



      appBar:

      AppBar(

        title:

        const Text(
          "المحطات الأهلية",
        ),

        centerTitle:true,

      ),





      floatingActionButton:


      FloatingActionButton(


        child:

        const Icon(
          Icons.add,
        ),



        onPressed:() async {



          await Navigator.push(


            context,


            MaterialPageRoute(


              builder: (_)=>

                  AddStationScreen(


                    stationType:
                    "أهلية",


                  ),


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

          "لا توجد محطات أهلية لهذا الفرع",

          style:

          TextStyle(

            fontSize:18,

          ),

        ),

      )



          :



      ListView.builder(


        itemCount:

        stations.length,




        itemBuilder:

            (context,index){



          final station =
          stations[index];




          return Card(


            margin:

            const EdgeInsets.symmetric(

              horizontal:12,

              vertical:6,

            ),




            child:


            ListTile(



              leading:

              const CircleAvatar(


                backgroundColor:
                Colors.orange,


                child:

                Icon(

                  Icons.local_gas_station,

                  color:
                  Colors.white,

                ),


              ),





              title:

              Text(

                station.name,

              ),





              subtitle:

              Column(


                crossAxisAlignment:
                CrossAxisAlignment.start,


                children:[


                  Text(

                    "${station.governorate} - ${station.district}",

                  ),



                  Text(

                    "الفرع: ${station.branchName}",

                  ),



                ],


              ),





              trailing:


              PopupMenuButton<int>(



                onSelected:(value) async {



                  if(value == 1){



                    Navigator.push(


                      context,


                      MaterialPageRoute(


                        builder: (_)=>

                            StationDetailsScreen(

                              station:
                              station,

                            ),


                      ),


                    );


                  }





                  if(value == 2){



                    await Navigator.push(


                      context,


                      MaterialPageRoute(


                        builder: (_)=>

                            EditStationScreen(

                              station:
                              station,

                            ),


                      ),


                    );



                    loadStations();


                  }







                  if(value == 3){


                    await deleteStation(

                      station.id,

                    );


                  }



                },



                itemBuilder: (_)=>

                const [


                  PopupMenuItem(

                    value:1,

                    child:

                    Text(
                      "التفاصيل",
                    ),

                  ),



                  PopupMenuItem(

                    value:2,

                    child:

                    Text(
                      "تعديل",
                    ),

                  ),



                  PopupMenuItem(

                    value:3,

                    child:

                    Text(
                      "حذف",
                    ),

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