import 'package:flutter/material.dart';
import '../../models/fueling_log.dart';
import '../../services/oil_coupon_service.dart';

class VehicleLogsScreen extends StatelessWidget {
  final String vehicleId;
  final String plateNumber;

  const VehicleLogsScreen({
    super.key,
    required this.vehicleId,
    required this.plateNumber,
  });

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('سجل التزويد - $plateNumber'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<FuelingLog>>(
        stream: OilCouponService.instance.vehicleLogsStream(vehicleId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data ?? [];

          if (logs.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد عمليات تزويد سابقة لهذه المركبة',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.local_gas_station_rounded, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                log.stationName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.teal.withValues(alpha: .15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${log.quantity.toStringAsFixed(0)} لتر (${log.fuelType})',
                              style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('المنفذ: ${log.outletNumber}', style: const TextStyle(color: Colors.grey)),
                          Text('الموظف: ${log.employeeName}', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('التاريخ والوقت:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(log.createdAt.length > 16 ? log.createdAt.substring(0, 16).replaceAll('T', ' ') : log.createdAt, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
