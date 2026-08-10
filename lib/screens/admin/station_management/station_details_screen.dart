import 'package:flutter/material.dart';

import '../../../models/station.dart';
import 'send_notification_screen.dart';

class StationDetailsScreen extends StatelessWidget {
  final Station station;

  const StationDetailsScreen({
    super.key,
    required this.station,
  });

  Widget info(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(title),
        subtitle: Text(value.isEmpty ? "-" : value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(station.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          info("اسم المحطة", station.name),
          info("نوع المحطة", station.stationType),
          info("المحافظة", station.governorate),
          info("القضاء", station.district),
          info("اسم المدير", station.managerName),
          info("الحالة", station.workingStatus),

          const SizedBox(height: 25),

          // زر إرسال التبليغ
          ElevatedButton.icon(
            icon: const Icon(Icons.notifications),
            label: const Text("إرسال تبليغ"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 55),
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SendNotificationScreen(
                    station: station,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 15),

          // زر التعديل
          ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text("تعديل بيانات المحطة"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 55),
            ),
            onPressed: () {
              // سنربط شاشة التعديل لاحقاً
            },
          ),

          const SizedBox(height: 15),

          // زر الحذف
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text("حذف المحطة"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 55),
            ),
            onPressed: () {
              // سنربط الحذف لاحقاً
            },
          ),
        ],
      ),
    );
  }
}