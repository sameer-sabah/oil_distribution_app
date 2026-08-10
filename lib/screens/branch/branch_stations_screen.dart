import 'package:flutter/material.dart';

import '../station_management/government_stations_screen.dart';
import '../station_management/private_stations_screen.dart';
import '../register_station_screen.dart';
import '../../services/auth_service.dart';

class BranchStationsScreen extends StatelessWidget {


  final String branchId;


  const BranchStationsScreen({

    super.key,

    required this.branchId,

  });



  @override
  Widget build(BuildContext context){


    return Scaffold(

      appBar: AppBar(

        title:

        const Text(
          "إدارة محطات الفرع",
        ),

        centerTitle:true,

      ),


      body:

      Padding(

        padding:
        const EdgeInsets.all(16),


        child: Column(

          children: [


            Card(

              child: ListTile(

                leading:

                const Icon(
                  Icons.account_balance,
                  color: Colors.blue,
                ),


                title:

                const Text(
                  "المحطات الحكومية",
                ),


                trailing:

                const Icon(
                  Icons.arrow_forward_ios,
                ),


                onTap: (){


                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>

                          GovernmentStationsScreen(

                            branchId:
                            branchId,

                          ),

                    ),

                  );


                },

              ),

            ),



            const SizedBox(height:15),



            Card(

              child: ListTile(

                leading:

                const Icon(
                  Icons.store,
                  color: Colors.green,
                ),


                title:

                const Text(
                  "المحطات الأهلية",
                ),


                trailing:

                const Icon(
                  Icons.arrow_forward_ios,
                ),


                onTap: (){


                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>

                          PrivateStationsScreen(

                            branchId:
                            branchId,

                          ),

                    ),

                  );


                },

              ),

            ),


          ],

        ),

      ),

    );


  }


}