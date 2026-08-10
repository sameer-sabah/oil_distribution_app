import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkMode = false;
  bool notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "الإعدادات",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          const SizedBox(height: 10),

          Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white,
              child: Image.asset(
                "assets/images/logo.png",
                width: 60,
              ),
            ),
          ),

          const SizedBox(height: 15),

          const Center(
            child: Text(
              "نافذة المنتوج النفطي",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 30),

          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: SwitchListTile(
              secondary: const Icon(
                Icons.dark_mode,
                color: Colors.indigo,
              ),
              title: const Text("الوضع الليلي"),
              subtitle: const Text("تشغيل أو إيقاف الوضع الداكن"),
              value: darkMode,
              onChanged: (value) {
                setState(() {
                  darkMode = value;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? "تم تشغيل الوضع الليلي"
                          : "تم تشغيل الوضع النهاري",
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 15),

          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: SwitchListTile(
              secondary: const Icon(
                Icons.notifications_active,
                color: Colors.orange,
              ),
              title: const Text("الإشعارات"),
              subtitle: const Text("استقبال إشعارات توفر المنتجات"),
              value: notifications,
              onChanged: (value) {
                setState(() {
                  notifications = value;
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              children: [

                ListTile(
                  leading: Icon(
                    Icons.verified,
                    color: Colors.green,
                  ),
                  title: Text("الإصدار"),
                  subtitle: Text("1.0.0"),
                ),

                Divider(height: 1),

                ListTile(
                  leading: Icon(
                    Icons.engineering,
                    color: Colors.blue,
                  ),
                  title: Text("المطور"),
                  subtitle: Text("المهندس سمير صباح عبيد"),
                ),

                Divider(height: 1),

                ListTile(
                  leading: Icon(
                    Icons.business,
                    color: Colors.teal,
                  ),
                  title: Text("الجهة"),
                  subtitle: Text("شركة توزيع المنتجات النفطية"),
                ),

              ],
            ),
          ),

          const SizedBox(height: 35),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text(
              "العودة",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}