import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../services/station_service.dart';
import '../models/station.dart';
import 'admin/station_management/station_folders_screen.dart';
import 'pending_stations_screen.dart';
import 'reports_screen.dart';
import 'notifications_screen.dart';

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

  final NotificationService notificationService =
      NotificationService.instance;

  List<Station> stations = [];


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
    await stationService
        .getBranchStations(
      user.branchId,
    );




    if(!mounted)
      return;



    setState((){

      loading=false;

    });



  }








  @override
  Widget build(BuildContext context){

    final user =
        auth.currentUser;


    return Scaffold(

      appBar:

      AppBar(

        title:

        Text(
          "لوحة مدير الفرع - ${user?.branchName ?? ""}",
        ),

        centerTitle:true,

      ),


      body:

      ListView(

        padding:
        const EdgeInsets.all(16),


        children:[


          _menuCard(

            title:
            "إدارة المحطات",

            subtitle:
            "عرض وإدارة محطات الفرع",

            icon:
            Icons.local_gas_station,

            onTap:(){

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder:(_)=>
                  const StationFoldersScreen(),

                ),

              );

            },

          ),




          _menuCard(

            title:
            "طلبات تسجيل المحطات",

            subtitle:
            "مراجعة طلبات المحطات الجديدة",

            icon:
            Icons.approval,

            onTap:(){

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder:(_)=>
                      PendingStationsScreen(),

                ),

              );

            },

          ),




          _menuCard(

            title:
            "التقارير",

            subtitle:
            "تقارير وإحصائيات الفرع",

            icon:
            Icons.bar_chart,

            onTap:(){

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder:(_)=>
                  const ReportsScreen(),

                ),

              );

            },

          ),




          _menuCard(

            title:
            "الإشعارات",

            subtitle:
            "إرسال ومتابعة الإشعارات",

            icon:
            Icons.notifications,

            onTap:(){

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder:(_)=>
                      NotificationsScreen(

                        userId:
                        auth.currentUser!.id,

                      ),
                    ),

              );

            },

          ),



        ],

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

      child: ListTile(

        leading: Icon(icon),

        title: Text(title),
        subtitle: Text(subtitle),
        trailing:
        const Icon(Icons.arrow_forward_ios),

        onTap:onTap,

      ),

    );

  }


}
