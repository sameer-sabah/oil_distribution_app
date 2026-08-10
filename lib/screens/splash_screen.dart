import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  late Animation<double> scale;

  late Animation<Offset> slide;
  Future<void> requestNotificationPermission() async {
    final messaging = FirebaseMessaging.instance;

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
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 2.2, end: 2.2),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 2.2, end: 1),
        weight: 85,
      ),
    ]).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

    slide = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(
          begin: Offset.zero,
          end: const Offset(.20, 0),
        ),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(.20, 0),
          end: const Offset(-.20, 0),
        ),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(-.20, 0),
          end: Offset.zero,
        ),
        weight: 40,
      ),
    ]).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

    controller.forward();

    Timer(const Duration(seconds: 2), () {

      if (!mounted) return;

      print("تم الانتقال الى HomeScreen");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );

    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff062A18),
      body: Center(
        child: SlideTransition(
          position: slide,
          child: ScaleTransition(
            scale: scale,
            child: Image.asset(
              "assets/images/logo.png",
              width: 180,
            ),
          ),
        ),
      ),
    );
  }
}