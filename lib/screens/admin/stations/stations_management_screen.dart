import 'package:flutter/material.dart';

class StationsManagementScreen extends StatelessWidget {
  const StationsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة المحطات"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "شاشة إدارة المحطات",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}