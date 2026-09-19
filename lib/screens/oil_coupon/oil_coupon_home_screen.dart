import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'dart:io';
import '../../models/vehicle_coupon.dart';
import 'vehicle_logs_screen.dart';

class OilCouponHomeScreen extends StatelessWidget {
  final VehicleCoupon vehicle;

  const OilCouponHomeScreen({
    super.key,
    required this.vehicle,
  });

  @override
  Widget build(context) {
    final eligible = vehicle.isEligible;
    final nextDate = vehicle.nextEligibleDate;

    return Scaffold(
      appBar: AppBar(
        title: Text('الكوبون النفطي - ${vehicle.plateFull}'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.blue.shade50,
                              child: Icon(Icons.directions_car_rounded, color: Colors.blue.shade800, size: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vehicle.plateFull,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${vehicle.vehicleType} • ${vehicle.vehicleModelName} (${vehicle.vehicleColor})',
                                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: eligible ? Colors.green.withValues(alpha: .15) : Colors.red.withValues(alpha: .15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          eligible ? '🟢 مستحق' : '🔴 غير مستحق',
                          style: TextStyle(
                            color: eligible ? Colors.green.shade800 : Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  _row('اسم المستفيد', vehicle.ownerName),
                  _row('رقم الهاتف', vehicle.phone),
                  _row('نوع المنتوج', 'بنزين (حسب توجيه مدير الفرع)'),
                  _row('الكمية المسموحة', '${vehicle.allowedQuantity.toStringAsFixed(0)} لتر'),
                  _row('نظام الاستحقاق', vehicle.isGovernment ? 'حصة شهرية' : 'كل ${vehicle.intervalDays} أيام'),
                  if (vehicle.isGovernment)
                    _row('المتبقي هذا الشهر', '${vehicle.remainingGovernmentQuota.toStringAsFixed(0)} لتر', valueColor: Colors.teal)
                  else
                    _row(
                      'الاستحقاق القادم',
                      nextDate != null ? nextDate.toIso8601String().substring(0, 10) : 'مستحق الآن',
                      valueColor: Colors.blue,
                    ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showQrCodeDialog(context, vehicle);
                          },
                          icon: const Icon(Icons.qr_code_rounded),
                          label: const Text('عرض QR Code'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => VehicleLogsScreen(vehicleId: vehicle.id, plateNumber: vehicle.plateFull)),
                            );
                          },
                          icon: const Icon(Icons.history_rounded),
                          label: const Text('سجل التزويد'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: valueColor ?? Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadQrImage(BuildContext context, GlobalKey qrKey) async {
    try {
      RenderRepaintBoundary boundary = qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/coupon_qr_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      // Save directly to phone gallery using Gal
      await Gal.putImage(file.path, album: 'Oil Distribution App');

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم حفظ صورة الباركود في معرض الصور (الاستديو) بنجاح')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر حفظ صورة الباركود في الاستديو: $e')),
      );
    }
  }

  void _showQrCodeDialog(BuildContext context, VehicleCoupon vehicle) {
    final GlobalKey qrKey = GlobalKey();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('الكوبون الرقمي - ${vehicle.plateFull}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RepaintBoundary(
                key: qrKey,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.white,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: QrImageView(
                          data: vehicle.id,
                          version: QrVersions.auto,
                          size: 180.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('معرف الكوبون: ${vehicle.id}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 6),
                      Text('المستفيد: ${vehicle.ownerName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('المركبة: ${vehicle.vehicleType} - ${vehicle.vehicleModelName} (${vehicle.vehicleColor})'),
                      const Text('المنتوج: بنزين (حسب توجيه مدير الفرع)'),
                      Text('الكمية: ${vehicle.allowedQuantity.toStringAsFixed(0)} لتر'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    _downloadQrImage(context, qrKey);
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('تنزيل الكوبون كصورة إلى الاستديو'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
        ],
      ),
    );
  }
}
