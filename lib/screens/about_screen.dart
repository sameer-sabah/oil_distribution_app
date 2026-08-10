import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("حول التطبيق"),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.white,
              child: Image.asset(
                "assets/images/logo.png",
                width: 70,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "نافذة المنتوج النفطي",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "شركة توزيع المنتجات النفطية\nفرع الأنبار",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 25),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "يهدف هذا التطبيق إلى تمكين المواطنين من معرفة توفر المنتجات النفطية في المحطات، ومعرفة مواقعها، وأقرب محطة، مع تحديث الكميات بشكل مباشر.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const ListTile(
              leading: Icon(Icons.engineering, color: Colors.blue),
              title: Text("المطور"),
              subtitle: Text("المهندس سمير صباح عبيد"),
            ),

            const ListTile(
              leading: Icon(Icons.business, color: Colors.green),
              title: Text("القسم"),
              subtitle: Text("شعبة تقنية المعلومات"),
            ),

            const ListTile(
              leading: Icon(Icons.verified, color: Colors.orange),
              title: Text("الإصدار"),
              subtitle: Text("1.0.0"),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text("رجوع"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}