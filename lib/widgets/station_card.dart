import 'package:flutter/material.dart';
import '../models/station.dart';

class StationCard extends StatelessWidget {
  final Station station;

  final double distance;

  final VoidCallback? onDetails;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onMap;

  const StationCard({
    super.key,
    required this.station,
    this.distance = 0,
    this.onDetails,
    this.onEdit,
    this.onDelete,
    this.onMap,
  });

  Color statusColor() {
    if (station.workingStatus == "مفتوحة") {
      return Colors.green;
    }

    if (station.workingStatus.contains("خاف") || station.workingStatus.contains("خفار") || station.workingStatus == "duty") {
      return Colors.purple;
    }

    if (station.workingStatus == "مغلقة") {
      return Colors.red;
    }

    return Colors.orange;
  }

  Widget fuelItem(
      String title,
      int value,
      Color color,
      ) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color,
          child: const Icon(
            Icons.local_gas_station,
            color: Colors.white,
            size: 18,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
          ),
        ),

        Text(
          "$value",
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String formatUpdateTime(String value) {
    if (value.isEmpty) {
      return "لا يوجد تحديث";
    }

    try {
      final date = DateTime.parse(value);

      return "${date.day.toString().padLeft(2, '0')}/"
          "${date.month.toString().padLeft(2, '0')}/"
          "${date.year} "
          "${date.hour.toString().padLeft(2, '0')}:"
          "${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 3,

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // =========================================
            // معلومات المحطة
            // =========================================

            Row(
              children: [

                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(
                    Icons.local_gas_station,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Text(
                        station.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "🕒 آخر تحديث: "
                            "${formatUpdateTime(station.updatedAt)}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),

                      Text(
                        "${station.governorate} - "
                            "${station.district}",
                      ),

                      Text(
                        station.stationType,
                        style: TextStyle(
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),

                  decoration: BoxDecoration(
                    color: statusColor(),
                    borderRadius:
                    BorderRadius.circular(10),
                  ),

                  child: Text(
                    station.workingStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // =========================================
            // الكميات
            // =========================================

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceAround,

              children: [

                fuelItem(
                  "عادي",
                  station.regular95,
                  Colors.green,
                ),

                fuelItem(
                  "محسن",
                  station.improved95,
                  Colors.blue,
                ),

                fuelItem(
                  "سوبر",
                  station.super95,
                  Colors.purple,
                ),

                fuelItem(
                  "كاز",
                  station.diesel,
                  Colors.orange,
                ),

                fuelItem(
                  "نفط",
                  station.whiteOil,
                  Colors.amber.shade800,
                ),

                fuelItem(
                  "غاز",
                  station.lpg,
                  Colors.teal,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // =========================================
            // المسافة
            // =========================================

            if (distance > 0)
              Text(
                "المسافة: "
                    "${distance.toStringAsFixed(1)} كم",
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),

            const Divider(),

            // =========================================
            // أزرار المحطة
            // =========================================

            Row(
              mainAxisAlignment:
              MainAxisAlignment.end,

              children: [

                // تفاصيل
                if (onDetails != null)
                  IconButton(
                    onPressed: onDetails,
                    icon: const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                    ),
                    tooltip: "تفاصيل المحطة",
                  ),

                // ملاحة
                if (onMap != null)
                  IconButton(
                    onPressed: onMap,
                    icon: const Icon(
                      Icons.navigation,
                      color: Colors.green,
                    ),
                    tooltip: "ابدأ الملاحة",
                  ),

                // تعديل
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.orange,
                    ),
                    tooltip: "تعديل المحطة",
                  ),

                // حذف نهائي
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                      size: 30,
                    ),
                    tooltip: "حذف المحطة نهائياً",
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}