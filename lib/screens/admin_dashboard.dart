import 'package:flutter/material.dart';

import 'users_screen.dart';
import 'products_screen.dart';
import 'reports_screen.dart';
import 'internal_messages_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int index = 0;

  final pages = const [
    UsersScreen(),
    ProductsScreen(),
    ReportsScreen(),
    InternalMessagesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة الإدارة"),
        backgroundColor: Colors.blue.shade900,
      ),

      body: pages[index],

      bottomNavigationBar: NavigationBar(
        selectedIndex: index,

        onDestinationSelected: (i) {
          setState(() {
            index = i;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people),
            label: "المستخدمون",
          ),

          NavigationDestination(
            icon: Icon(Icons.oil_barrel),
            label: "المنتجات",
          ),

          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: "التقارير",
          ),

          NavigationDestination(
            icon: Icon(Icons.mail),
            selectedIcon: Icon(Icons.mark_email_unread),
            label: "المراسلات",
          ),
        ],
      ),
    );
  }
}