import 'package:flutter/material.dart';

import 'station_management/station_folders_screen.dart';class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() =>
      _AdminHomeScreenState();
}

class _AdminHomeScreenState
    extends State<AdminHomeScreen> {

  int selectedIndex = 0;

  final List<Widget> pages = const [

    Center(
      child: Text(
        "الرئيسية",
        style: TextStyle(fontSize: 22),
      ),
    ),

    StationFoldersScreen(),

    Center(
      child: Text(
        "إدارة المستخدمين",
        style: TextStyle(fontSize: 22),
      ),
    ),

    Center(
      child: Text(
        "التقارير",
        style: TextStyle(fontSize: 22),
      ),
    ),

    Center(
      child: Text(
        "الإعدادات",
        style: TextStyle(fontSize: 22),
      ),
    ),

  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "لوحة مدير النظام",
        ),
        centerTitle: true,
      ),

      drawer: Drawer(

        child: ListView(

          children: [

            DrawerHeader(

              decoration: const BoxDecoration(
                color: Colors.blue,
              ),

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                mainAxisAlignment:
                MainAxisAlignment.end,

                children: const [

                  CircleAvatar(
                    radius: 35,
                    child: Icon(
                      Icons.person,
                      size: 35,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    "مدير النظام",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),

                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("الرئيسية"),
              onTap: () {
                setState(() {
                  selectedIndex = 0;
                });

                Navigator.pop(context);
              },
            ),

            ListTile(
              leading:
              const Icon(Icons.local_gas_station),
              title:
              const Text("إدارة المحطات"),
              onTap: () {
                setState(() {
                  selectedIndex = 1;
                });

                Navigator.pop(context);
              },
            ),

            ListTile(
              leading:
              const Icon(Icons.people),
              title:
              const Text("إدارة المستخدمين"),
              onTap: () {
                setState(() {
                  selectedIndex = 2;
                });

                Navigator.pop(context);
              },
            ),

            ListTile(
              leading:
              const Icon(Icons.bar_chart),
              title:
              const Text("التقارير"),
              onTap: () {
                setState(() {
                  selectedIndex = 3;
                });

                Navigator.pop(context);
              },
            ),

            ListTile(
              leading:
              const Icon(Icons.settings),
              title:
              const Text("الإعدادات"),
              onTap: () {
                setState(() {
                  selectedIndex = 4;
                });

                Navigator.pop(context);
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text(
                "تسجيل الخروج",
              ),
              onTap: () {

                Navigator.pushReplacementNamed(
                  context,
                  "/login",
                );

              },
            ),

          ],
        ),
      ),

      body: pages[selectedIndex],

    );
  }
}