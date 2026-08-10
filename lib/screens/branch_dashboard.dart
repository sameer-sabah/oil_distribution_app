import 'package:flutter/material.dart';
import 'products_screen.dart';
import '../services/auth_service.dart';
import '../services/station_service.dart';
import '../models/station.dart';
import 'pending_stations_screen.dart';
import 'branch/branch_stations_screen.dart';
import 'notifications_screen.dart';
import 'reports_screen.dart';
import 'admin/users_screen.dart';
import 'branch/quantity_tracking_screen.dart';

class BranchDashboard extends StatefulWidget {

  const BranchDashboard({
    super.key,
  });


  @override
  State<BranchDashboard> createState() =>
      _BranchDashboardState();

}




class _BranchDashboardState
    extends State<BranchDashboard> {


  final AuthService auth =
      AuthService.instance;

  final StationService stationService =
      StationService.instance;

  List stations = [];

  bool loading = true;


  @override
  void initState(){

    super.initState();

    loadStations();

  }



  Future<void> loadStations() async {


    final user =
        auth.currentUser;


    if(user == null)
      return;



    stations =
    await stationService.getBranchStations(
      user.branchId,
    );


    if(!mounted)
      return;


    setState((){

      loading = false;

    });


  }




  @override
  Widget build(BuildContext context){


    final user =
        auth.currentUser;



    return Scaffold(


      appBar: AppBar(
        title: Text(
          "لوحة مدير الفرع - ${user?.branchName ?? ""}",
        ),
        centerTitle: true,

        actions: [
          IconButton(
            tooltip: "تسجيل الخروج",
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("تسجيل الخروج"),
                    content: const Text(
                      "هل أنت متأكد من أنك تريد تسجيل الخروج؟",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text("إلغاء"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: const Text("تسجيل الخروج"),
                      ),
                    ],
                  );
                },
              );

              if (confirm != true) return;

              await auth.signOut();

              if (!mounted) return;

              Navigator.of(context).pushNamedAndRemoveUntil(
                "/login",
                    (route) => false,
              );
            },
          ),
        ],
      ),



      body:

      loading

          ?

      const Center(
        child:CircularProgressIndicator(),
      )


          :

      ListView(

        padding:
        const EdgeInsets.all(12),


        children: [



          // معلومات الفرع

          Card(

            elevation:4,

            child: ListTile(

              leading:

              const CircleAvatar(

                child:
                Icon(
                  Icons.account_balance,
                ),

              ),


              title:

              Text(

                user?.branchName ?? "",

                style:

                const TextStyle(

                  fontSize:20,

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
                    "المدير: ${user?.fullName ?? ""}",
                  ),

                  Text(
                    "الهاتف: ${user?.phone ?? ""}",
                  ),

                ],

              ),

            ),

          ),



          const SizedBox(height:15),





          const SizedBox(height:20),



          menuCard(

            "🏭 إدارة المحطات",

            Icons.local_gas_station,

                (){


              Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_) =>

                      BranchStationsScreen(

                        branchId:
                        user?.branchId ?? "",

                      ),

                ),

              );


            },

          ),




          menuCard(

            "🏭 طلبات تسجيل المحطات",

            Icons.add_business,

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

          menuCard(
            "متابعة الكميات",
            Icons.inventory,
                (){

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_) =>
                  const QuantityTrackingScreen(),

                ),

              );

            },
          ),


          _menuCard(

            title: "الإشعارات",

            subtitle: "إرسال ومتابعة إشعارات الفرع",

            icon: Icons.notifications,

            onTap: (){

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_) => NotificationsScreen(

                    userId: auth.currentUser!.id,

                  ),

                ),

              );

            },

          ),




          _menuCard(

            title: "التقارير",

            subtitle: "تقارير وإحصائيات الفرع",

            icon: Icons.bar_chart,

            onTap: (){

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_) =>
                  const ReportsScreen(),

                ),

              );

            },

          ),




          _menuCard(

            title: "المستخدمون",

            subtitle: "إدارة مستخدمي الفرع",

            icon: Icons.people,

            onTap: (){

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_) =>
                  const UsersScreen(),

                ),

              );

            },

          ),




          const SizedBox(height:20),







        ],

      ),



    );


  }







  Widget statCard(
      String title,
      String value,
      IconData icon,
      ){

    return Card(

      child:

      Padding(

        padding:
        const EdgeInsets.all(15),


        child:

        Column(

          children: [

            Icon(icon),

            const SizedBox(height:8),


            Text(

              value,

              style:

              const TextStyle(

                fontSize:25,

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






  Widget menuCard(
      String title,
      IconData icon,
      VoidCallback onTap,
      ){

    return Card(

      child:

      ListTile(

        leading:
        Icon(icon),


        title:
        Text(title),


        trailing:

        const Icon(
          Icons.arrow_forward_ios,
        ),


        onTap:onTap,

      ),

    );

  }

  Widget _menuCard({

    required String title,

    required String subtitle,

    required IconData icon,

    required VoidCallback onTap,

  }){

    return Card(

      elevation: 4,

      margin: const EdgeInsets.symmetric(
        vertical: 8,
      ),

      child: ListTile(

        leading:

        Icon(
          icon,
          size: 35,
        ),


        title:

        Text(

          title,

          style:

          const TextStyle(

            fontWeight:
            FontWeight.bold,

          ),

        ),


        subtitle:

        Text(subtitle),


        trailing:

        const Icon(
          Icons.arrow_forward_ios,
        ),


        onTap:
        onTap,


      ),

    );

  }

}