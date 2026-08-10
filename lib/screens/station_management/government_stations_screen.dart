import 'package:flutter/material.dart';

import '../../services/station_service.dart';
import '../../models/station.dart';
import '../../widgets/station_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'station_details_screen.dart';
import '../admin/stations/edit_station_screen.dart';

class GovernmentStationsScreen extends StatefulWidget {
  final String branchId;

  const GovernmentStationsScreen({
    super.key,
    required this.branchId,
  });

  @override
  State<GovernmentStationsScreen> createState() =>
      _GovernmentStationsScreenState();
}

class _GovernmentStationsScreenState
    extends State<GovernmentStationsScreen> {

  final StationService stationService =
      StationService.instance;

  List<Station> stations = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadStations();
  }

  // =========================================
  // جلب محطات الفرع الحكومية
  // =========================================

  Future<void> loadStations() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }

    try {
      final data =
      await stationService.getBranchStations(
        widget.branchId,
      );

      final governmentStations = data.where((station) {
        return station.stationType.trim() == "حكومية" ||
            station.stationType.trim() == "government";
      }).toList();

      if (!mounted) return;

      setState(() {
        stations = governmentStations;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "تعذر تحميل المحطات: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================
  // حذف المحطة
  // =========================================

  Future<void> deleteStation(Station station) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "حذف المحطة",
          ),
          content: Text(
            "هل أنت متأكد من حذف محطة:\n\n"
                "${station.name}\n\n"
                "سيتم حذفها نهائياً.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                "إلغاء",
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                "حذف نهائياً",
              ),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return;
    }

    try {
      await stationService.deleteStation(
        station.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "تم حذف محطة ${station.name} بنجاح",
          ),
          backgroundColor: Colors.green,
        ),
      );

      await loadStations();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "فشل حذف المحطة: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================
  // الشاشة
  // =========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "المحطات الحكومية",
        ),
        centerTitle: true,

        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
            ),
            tooltip: "تحديث",
            onPressed: loadStations,
          ),
        ],
      ),

      body: loading
          ? const Center(
        child: CircularProgressIndicator(),
      )

          : stations.isEmpty
          ? RefreshIndicator(
        onRefresh: loadStations,
        child: ListView(
          children: const [
            SizedBox(
              height: 200,
            ),
            Icon(
              Icons.local_gas_station,
              size: 70,
              color: Colors.grey,
            ),
            SizedBox(
              height: 15,
            ),
            Center(
              child: Text(
                "لا توجد محطات حكومية",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      )

          : RefreshIndicator(
        onRefresh: loadStations,

        child: ListView.builder(
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 20,
          ),

          itemCount: stations.length,

          itemBuilder: (
              context,
              index,
              ) {
            final station =
            stations[index];

            return StationCard(
              station: station,

              distance: 0,

              // =========================
              // تفاصيل
              // =========================

              onDetails: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        StationDetailsScreen(
                          station: station,
                        ),
                  ),
                );
              },

              // =========================
              // تعديل
              // =========================

              onEdit: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditStationScreen(
                      station: station,
                    ),
                  ),
                );

                if (result == true) {
                  await loadStations();
                }
              },

              // =========================
              // حذف
              // =========================

              onDelete: () async {
                await deleteStation(
                  station,
                );
              },

              // =========================
              // الخريطة
              // =========================

              onMap: () async {
                final latitude = station.latitude;
                final longitude = station.longitude;

                final url = Uri.parse(
                  'https://www.google.com/maps/dir/?api=1'
                      '&destination=$latitude,$longitude'
                      '&travelmode=driving',
                );

                if (await canLaunchUrl(url)) {
                  await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}