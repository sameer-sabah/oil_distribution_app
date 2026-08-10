import 'package:flutter/material.dart';

import '../../widgets/admin/admin_drawer.dart';
import '../../models/station.dart';
import 'stations/stations_management_screen.dart';
import 'users_screen.dart';
import '../pending_stations_screen.dart';



class AdminDashboard extends StatelessWidget {

  const AdminDashboard({
    super.key,
  });



  @override
  Widget build(BuildContext context) {


    return Scaffold(


      drawer:
      const AdminDrawer(),



      appBar:
      AppBar(

        title:
        const Text(
          "لوحة تحكم المدير",
        ),

        centerTitle:
        true,


      ),




      body:


      SafeArea(


        child:


        Padding(


          padding:
          const EdgeInsets.all(16),



          child:


          GridView.count(



            crossAxisCount:
            2,


            crossAxisSpacing:
            15,


            mainAxisSpacing:
            15,



            children: [



              _card(

                context,

                Icons.people,

                "إدارة المستخدمين",

                Colors.blue,


                    (){

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                      const UsersScreen(),

                    ),

                  );


                },


              ),





              _card(

                context,

                Icons.local_gas_station,

                "إدارة المحطات",

                Colors.green,


                    (){


                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                      const StationsManagementScreen(),

                    ),

                  );


                },


              ),






              _card(

                context,

                Icons.pending_actions,

                "طلبات تسجيل المحطات",

                Colors.orange,


                    (){


                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                      const PendingStationsScreen(),

                    ),

                  );


                },


              ),






              _card(

                context,

                Icons.inventory,

                "إدارة المنتجات",

                Colors.deepOrange,


                    (){


                  _message(

                    context,

                    "شاشة المنتجات قيد التطوير",

                  );


                },


              ),







              _card(

                context,

                Icons.notifications,

                "الإشعارات",

                Colors.red,


                    (){


                  _message(

                    context,

                    "شاشة الإشعارات قيد التطوير",

                  );


                },


              ),








              _card(

                context,

                Icons.bar_chart,

                "التقارير",

                Colors.purple,


                    (){


                  _message(

                    context,

                    "شاشة التقارير قيد التطوير",

                  );


                },


              ),








              _card(

                context,

                Icons.settings,

                "الإعدادات",

                Colors.teal,


                    (){


                  _message(

                    context,

                    "شاشة الإعدادات قيد التطوير",

                  );


                },


              ),




            ],


          ),


        ),


      ),


    );


  }







  void _message(

      BuildContext context,

      String text,

      ){


    ScaffoldMessenger.of(context)
        .showSnackBar(


      SnackBar(

        content:
        Text(text),

      ),


    );


  }









  Widget _card(

      BuildContext context,

      IconData icon,

      String title,

      Color color,

      VoidCallback onTap,

      ){



    return InkWell(



      onTap:
      onTap,



      borderRadius:
      BorderRadius.circular(20),



      child:


      Card(


        elevation:
        5,


        shape:


        RoundedRectangleBorder(


          borderRadius:
          BorderRadius.circular(20),


        ),




        child:


        Column(



          mainAxisAlignment:
          MainAxisAlignment.center,



          children: [



            Icon(

              icon,

              size:
              55,

              color:
              color,

            ),




            const SizedBox(

              height:
              15,

            ),




            Text(


              title,


              textAlign:
              TextAlign.center,



              style:

              const TextStyle(

                fontSize:
                16,

                fontWeight:
                FontWeight.bold,

              ),



            ),



          ],



        ),



      ),



    );


  }



}