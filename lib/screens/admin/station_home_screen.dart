import 'package:flutter/material.dart';

class StationHomeScreen extends StatelessWidget {
  const StationHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("مدير المحطة"),
      ),
      body: const Center(
        child: Text(
          "مرحباً بمدير المحطة",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}