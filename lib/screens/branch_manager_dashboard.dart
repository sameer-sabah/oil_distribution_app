import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../services/station_service.dart';
import '../models/station.dart';
import 'admin/station_management/station_folders_screen.dart';
import 'pending_stations_screen.dart';
import 'reports_screen.dart';
import 'notifications_screen.dart';
import 'password_reset_requests_screen.dart';
import 'internal_messages_screen.dart';
import 'oil_coupon/branch_coupon_management_screen.dart';
import 'oil_coupon/vehicle_login_screen.dart';
import '../services/internal_message_service.dart';
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
  final InternalMessageService internalMessageService =
      InternalMessageService.instance;
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



    if(user == null) {
      return;
    }



    stations =
    await stationService
        .getBranchStations(
      user.branchId,
    );




    if(!mounted) {
      return;
    }



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
            "إدارة الكوبون النفطي والحصص",

            subtitle:
            "تحديد الكمية المسموحة وفترة الاستحقاق وتعميمها على كافة المنافذ",

            icon:
            Icons.confirmation_number_rounded,

            onTap:(){

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder:(_)=>
                  const BranchCouponManagementScreen(),

                ),

              );

            },

          ),

          _menuCard(
            title: "تسجيل ودخول السيارات الحكومية (الكوبون النفطي)",
            subtitle: "استمارة وصفحة دخول تسجيل السيارات الحكومية وربط شرائح NFC",
            icon: Icons.admin_panel_settings_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VehicleLoginScreen(isGovernment: true),
                ),
              );
            },
          ),

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
            title: "طلبات تغيير كلمة المرور",
            subtitle: "مراجعة طلبات استعادة الحساب ومطابقة الصور",
            icon: Icons.lock_reset,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const PasswordResetRequestsScreen(),
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

          StreamBuilder<int>(
            stream:
            internalMessageService.unreadCountStream(),
            builder: (context, snapshot) {
              final int count =
                  snapshot.data ?? 0;

              return _notificationMenuCard(
                title: "المراسلات الداخلية",

                subtitle:
                "مراسلات مدير الفرع مع مدير النظام ومديري المحطات",

                icon: Icons.mail,

                count: count,

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const InternalMessagesScreen(),
                    ),
                  );
                },
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
  Widget _notificationMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required int count,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              size: 30,
            ),

            if (count > 0)
              Positioned(
                right: -10,
                top: -10,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: Text(
                    count > 99
                        ? '99+'
                        : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),

        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),

            if (count > 0)
              Text(
                '$count جديد',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
          ],
        ),

        subtitle: Text(
          subtitle,
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
        ),

        onTap: onTap,
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
