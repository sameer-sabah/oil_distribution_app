import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'services/governorate_service.dart';
import 'services/branch_service.dart';
import 'theme/app_theme.dart';

import 'services/auth_service.dart';
import 'screens/branch_dashboard.dart';

// Screens

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/citizen_screen.dart';

import 'screens/station_dashboard.dart';
import 'screens/register_station_screen.dart';

import 'screens/pending_stations_screen.dart';
import 'screens/notifications_screen.dart';

import 'screens/distribution/approve_requests_screen.dart';

import 'screens/employee/employee_dashboard.dart';

import 'screens/change_password_request_screen.dart';
import 'services/push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await PushNotificationService.instance.initialize(
    isCitizen: true,
  );
  FirebaseMessaging.onBackgroundMessage(
    PushNotificationService
        .firebaseMessagingBackgroundHandler,
  );
  runApp(const MyApp());

  Future.microtask(() async {
    await GovernorateService.instance.createDefaultGovernorates();
    await BranchService.instance.createDefaultBranches();
  });



}








class MyApp extends StatelessWidget {


  const MyApp({

    super.key,

  });





  @override
  Widget build(BuildContext context) {


    return MaterialApp(



      debugShowCheckedModeBanner:false,



      title:
      "نافذة المنتوج النفطي",



      theme:
      AppTheme.lightTheme,



      home:
      const SplashScreen(),





      routes:{

        "/branch":
            (context)=>
        const BranchDashboard(),

        "/login":
            (context)=>
        const LoginScreen(),





        "/settings":
            (context)=>
        const SettingsScreen(),





        "/admin":
            (context)=>
        const AdminScreen(),





        "/station":
            (context)=>
        const StationDashboard(),






        "/employee":
            (context)=>
            EmployeeDashboard(),






        "/approveRequests":
            (context)=>
        const ApproveRequestsScreen(),





        "/changePasswordRequest":
            (context)=>
        const ChangePasswordRequestScreen(),






        "/citizen":
            (context)=>
        const CitizenScreen(),






        "/registerStation":
            (context)=>
        const RegisterStationScreen(),






        "/pendingStations":
            (context)=>
        const PendingStationsScreen(),






        "/notifications":
            (context)=>
            NotificationsScreen(

              userId:

              AuthService
                  .instance
                  .currentUser
                  ?.id
                  ??
                  "",

            ),





      },





      onUnknownRoute:(settings){


        return MaterialPageRoute(


          builder:(_)=>

          const LoginScreen(),


        );


      },



    );


  }


}