import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.blue,
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.local_gas_station,
                      size: 40,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "نافذة المنتوج النفطي",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "شركة توزيع المنتجات النفطية",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("الرئيسية"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("تسجيل الدخول"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/login");
              },
            ),

            ListTile(
              leading: const Icon(Icons.public),
              title: const Text("دخول المواطن"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/citizen");
              },
            ),

            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("الإشعارات"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/notifications");
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("الإعدادات"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/settings");
              },
            ),

            const Spacer(),

            const Divider(),

            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text(
                "تسجيل الخروج",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                await AuthService.instance.logout();

                if (!context.mounted) return;

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/login",
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}