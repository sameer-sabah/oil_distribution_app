import 'package:flutter/material.dart';
import '../models/station.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';

import 'notifications_screen.dart';
class StationManagerDashboard extends StatefulWidget {
  final Station station;

  const StationManagerDashboard({
    super.key,
    required this.station,
  });

  @override
  State<StationManagerDashboard> createState() =>
      _StationManagerDashboardState();
}

class _StationManagerDashboardState
    extends State<StationManagerDashboard> {
  final DatabaseService databaseService =
      DatabaseService.instance;
  final AuthService auth =
      AuthService.instance;
  final TextEditingController regularController = TextEditingController();
  final TextEditingController improvedController = TextEditingController();
  final TextEditingController dieselController = TextEditingController();
  final TextEditingController whiteOilController = TextEditingController();
  final TextEditingController superController = TextEditingController();

  final TextEditingController lpgController = TextEditingController();

  late bool stationOpen;

  @override
  void initState() {
    super.initState();

    regularController.text =
        widget.station.regular95.toString();

    improvedController.text =
        widget.station.improved95.toString();

    dieselController.text =
        widget.station.diesel.toString();

    whiteOilController.text =
        widget.station.whiteOil.toString();

    superController.text =
        widget.station.super95.toString();

    lpgController.text =
        widget.station.lpg.toString();


    stationOpen =
        widget.station.workingStatus == "مفتوحة";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          tooltip: "رجوع",
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "مدير المحطة",
        ),

        centerTitle: true,

        actions: [
          // 🔔 الإشعارات
          IconButton(
            icon: const Icon(
              Icons.notifications,
            ),
            tooltip: "الإشعارات",
            onPressed: () {
              final managerUid = widget.station.managerUid;

              if (managerUid.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "لا يوجد مسؤول مرتبط بهذه المحطة",
                    ),
                  ),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationsScreen(
                    userId: managerUid,
                  ),
                ),
              );
            },
          ),

          // 🚪 تسجيل الخروج
          IconButton(
            icon: const Icon(
              Icons.logout,
            ),
            tooltip: "تسجيل الخروج",
            onPressed: () async {
              final confirm =
              await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text(
                      "تسجيل الخروج",
                    ),
                    content: const Text(
                      "هل تريد تسجيل الخروج من الحساب؟",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            false,
                          );
                        },
                        child: const Text(
                          "إلغاء",
                        ),
                      ),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            true,
                          );
                        },
                        child: const Text(
                          "تسجيل الخروج",
                        ),
                      ),
                    ],
                  );
                },
              );

              if (confirm != true) {
                return;
              }

              await auth.logout();

              if (!mounted) {
                return;
              }

              Navigator.pushNamedAndRemoveUntil(
                context,
                "/login",
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(
            Icons.local_gas_station,
            size: 90,
            color: Colors.blue,
          ),

          const SizedBox(height: 20),
          Text(
            widget.station.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "${widget.station.governorate} - ${widget.station.district}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          const Text(
            "تحديث كميات الوقود",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          Text(
            "آخر تحديث: ${widget.station.updatedAt}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 25),

          TextField(
            controller: regularController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "بنزين عادي (لتر)",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: improvedController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "بنزين محسن (لتر)",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: dieselController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "زيت الغاز (لتر)",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: whiteOilController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "النفط الأبيض (لتر)",
              border: OutlineInputBorder(),
            ),
          ),


          const SizedBox(height: 15),

          TextField(
            controller: superController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "بنزين سوبر (لتر)",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: lpgController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "الغاز السائل (لتر)",
              border: OutlineInputBorder(),
            ),
          ),
          SwitchListTile(
            value: stationOpen,
            title: Text(
              stationOpen
                  ? "المحطة مفتوحة 🟢"
                  : "المحطة مغلقة 🔴",
            ),
            onChanged: (value) {
              setState(() {
                stationOpen = value;
              });
            },
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 55,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("حفظ التحديث"),
              onPressed: () async {

                final updatedStation = widget.station.copyWith(
                  regular95: int.tryParse(regularController.text) ?? 0,
                  improved95: int.tryParse(improvedController.text) ?? 0,
                  diesel: int.tryParse(dieselController.text) ?? 0,
                  whiteOil: int.tryParse(whiteOilController.text) ?? 0,
                  super95: int.tryParse(superController.text) ?? 0,

                  lpg: int.tryParse(lpgController.text) ?? 0,
                  workingStatus: stationOpen ? "مفتوحة" : "مغلقة",
                  updatedAt: DateTime.now().toIso8601String(),
                );

                await databaseService.updateStation(updatedStation);
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text("تم تحديث بيانات المحطة"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  String formatDate(String value){

    try{

      final date = DateTime.parse(value);

      return
        "${date.day.toString().padLeft(2,'0')}/"
            "${date.month.toString().padLeft(2,'0')}/"
            "${date.year} "
            "${date.hour.toString().padLeft(2,'0')}:"
            "${date.minute.toString().padLeft(2,'0')}";

    }catch(e){

      return value;

    }

  }
}