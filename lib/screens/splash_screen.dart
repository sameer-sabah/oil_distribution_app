import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../services/auth_service.dart';
import '../core/constants/user_roles.dart';

import 'home_screen.dart';
import 'admin_screen.dart';
import 'branch_dashboard.dart';
import 'station_dashboard.dart';
import 'employee/employee_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  Future<void> requestNotificationPermission() async {
    final messaging =
        FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  @override
  void initState() {
    super.initState();

    requestNotificationPermission();

    _start();
  }

  Future<void> _start() async {

    // شاشة البداية تبقى ثانتين
    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    // محاولة استرجاع المستخدم المسجل سابقًا
    final user =
    await AuthService.instance
        .restoreCurrentUser();

    if (!mounted) return;

    // =====================================================
    // لا يوجد مستخدم مسجل
    // =====================================================

    if (user == null) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const HomeScreen(),
        ),
      );

      return;
    }

    // =====================================================
    // يوجد مستخدم - فتح شاشته حسب الصلاحية
    // =====================================================

    Widget screen;

    switch (UserRoles.normalize(user.role)) {

      case UserRoles.admin:

        screen =
        const AdminScreen();

        break;

      case UserRoles.branchManager:

        screen =
        const BranchDashboard();

        break;

      case UserRoles.stationManager:

        screen =
        const StationDashboard();

        break;

      case UserRoles.distributionManager:

        screen =
            EmployeeDashboard();

        break;

      default:

        screen =
        const HomeScreen();

        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SizedBox.expand(

        child: Image.asset(
          'assets/images/start_screen.png',
          fit: BoxFit.cover,
        ),

      ),

    );
  }
}