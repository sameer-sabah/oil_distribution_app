import 'package:flutter/material.dart';

import '../../models/station.dart';
import '../../services/station_service.dart';
import '../../services/branch_service.dart';
import '../../models/branch_model.dart';


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


  final stationService =
      StationService.instance;


  final branchService =
      BranchService.instance;



  bool loading = true;


  List<BranchModel> branches = [];


  List<Station> stations = [];



  @override
  void initState(){

    super.initState();

    loadData();

  }





  Future<void> loadData() async {


    final b =
    await branchService.getBranches();



    final s =
    await stationService.getStations();



    if(!mounted) {
      return;
    }



    setState((){


      branches = b;

      stations = s;

      loading = false;


    });


  }







  List<Station> branchStations(
      String branchId,
      String type
      ){


    return stations.where((s){


      return s.branchId == branchId &&
          s.stationType == type;


    }).toList();


  }







  Widget stationFolder(
      String title,
      IconData icon,
      List<Station> data
      ){


    return ExpansionTile(


      leading:
      Icon(icon),


      title:
      Text(
        title,
        style:
        const TextStyle(
          fontWeight:
          FontWeight.bold,
        ),
      ),


      children:

      data.map((station){


        return ListTile(


          leading:
          const Icon(
            Icons.local_gas_station,
          ),


          title:
          Text(
            station.name,
          ),


          subtitle:
          Text(
            station.governorate,
          ),


        );


      }).toList(),


    );


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

      ),




      body:


      loading

          ?

      const Center(
        child:
        CircularProgressIndicator(),
      )


          :


      ListView.builder(


        itemCount:
        branches.length,


        itemBuilder:
            (context,index){



          final branch =
          branches[index];



          final branchId =
              branch.id;



          return ExpansionTile(



            leading:
            const Icon(
              Icons.account_tree,
            ),



            title:
            Text(
              branch.name,
              style:
              const TextStyle(
                fontWeight:
                FontWeight.bold,
              ),
            ),



            children:[



              stationFolder(

                "محطات حكومية",

                Icons.account_balance,

                branchStations(
                    branchId,
                    "government"
                ),

              ),




              stationFolder(

                "محطات أهلية",

                Icons.business,

                branchStations(
                    branchId,
                    "private"
                ),

              ),



            ],



          );



        },


      ),



      floatingActionButton:

      FloatingActionButton(

        onPressed:(){


        },


        child:
        const Icon(
          Icons.add_location,
        ),

      ),



    );


  }


}