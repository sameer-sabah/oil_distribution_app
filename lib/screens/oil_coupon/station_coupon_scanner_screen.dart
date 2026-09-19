import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/vehicle_coupon.dart';
import '../../services/oil_coupon_service.dart';
import 'qr_scanner_screen.dart';
import 'nfc_scanner_screen.dart';

class StationCouponScannerScreen extends StatefulWidget {
  final String stationId;
  final String stationName;

  const StationCouponScannerScreen({
    super.key,
    required this.stationId,
    required this.stationName,
  });

  @override
  State<StationCouponScannerScreen> createState() => _StationCouponScannerScreenState();
}

class _StationCouponScannerScreenState extends State<StationCouponScannerScreen> {
  final _vehicleIdController = TextEditingController();
  final _refillQtyController = TextEditingController();
  bool _searching = false;
  bool _confirming = false;
  VehicleCoupon? _scannedVehicle;
  String _errorMessage = '';

  @override
  void dispose() {
    _vehicleIdController.dispose();
    _refillQtyController.dispose();
    super.dispose();
  }

  Future<void> _searchVehicle() async {
    final id = _vehicleIdController.text.trim();
    if (id.isEmpty) return;

    setState(() {
      _searching = true;
      _scannedVehicle = null;
      _errorMessage = '';
    });

    try {
      final vehicle = await OilCouponService.instance.searchVehicle(id);
      if (!mounted) return;
      if (vehicle == null) {
        setState(() {
          _errorMessage = '⚠️ هذه الشريحة أو اللوحة غير مسجلة في النظام (تأكد من عدم مسح بطاقة وطنية أو بنكية)';
        });
      } else {
        if (vehicle.isGovernment) {
          // Automatic full remaining quota fill
          _refillQtyController.text = vehicle.remainingGovernmentQuota.toStringAsFixed(0);
        } else {
          _refillQtyController.text = vehicle.allowedQuantity.toStringAsFixed(0);
        }
        setState(() {
          _scannedVehicle = vehicle;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'خطأ في البحث: $e';
      });
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _confirmFueling() async {
    if (_scannedVehicle == null) return;
    if (!_scannedVehicle!.isEligible) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('المركبة غير مستحقة للتزويد حالياً (نفذت الحصة)')),
      );
      return;
    }

    final qty = double.tryParse(_refillQtyController.text.trim()) ?? (_scannedVehicle!.isGovernment ? _scannedVehicle!.remainingGovernmentQuota : _scannedVehicle!.allowedQuantity);

    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال كمية تزويد صحيحة')),
      );
      return;
    }

    setState(() => _confirming = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      await OilCouponService.instance.confirmFueling(
        vehicleId: _scannedVehicle!.id,
        stationId: widget.stationId,
        stationName: widget.stationName,
        outletNumber: 'المنفذ رقم 1',
        employeeUid: user?.uid ?? 'unknown_employee',
        employeeName: user?.email ?? 'موظف المحطة',
        customQuantity: qty,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم تأكيد عملية التزويد وخصم الكمية تلقائياً من الحصة بنجاح')),
      );

      // Refresh vehicle data
      final updated = await OilCouponService.instance.getVehicle(_scannedVehicle!.id);
      setState(() {
        _scannedVehicle = updated;
        if (updated != null) {
          _refillQtyController.text = updated.isGovernment ? updated.remainingGovernmentQuota.toStringAsFixed(0) : updated.allowedQuantity.toStringAsFixed(0);
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر تأكيد التزويد: $e')),
      );
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مسح وتأكيد الكوبون النفطي'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المحطة الحالية: ${widget.stationName}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.blue.shade800,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            final scannedCode = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                            );
                            if (scannedCode != null && scannedCode.isNotEmpty) {
                              _vehicleIdController.text = scannedCode;
                              _searchVehicle();
                            }
                          },
                          icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                          label: const Text('مسح QR (خصوصي)'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.teal.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            final nfcId = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(builder: (_) => const NfcScannerScreen()),
                            );
                            if (nfcId != null && nfcId.isNotEmpty) {
                              _vehicleIdController.text = nfcId;
                              _searchVehicle();
                            }
                          },
                          icon: const Icon(Icons.nfc_rounded, size: 20),
                          label: const Text('قراءة NFC (حكومي)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'أو أدخل رقم اللوحة أو المعرف يدويًا:',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _vehicleIdController,
                          decoration: const InputDecoration(
                            labelText: 'رقم اللوحة أو المعرف أو شريحة NFC',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.qr_code_scanner_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _searching ? null : _searchVehicle,
                        child: _searching
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('بحث'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (_errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(_errorMessage, style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold)),
            ),

          if (_scannedVehicle != null) ...[
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _scannedVehicle!.plateFull,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _scannedVehicle!.isEligible ? Colors.green.withValues(alpha: .15) : Colors.red.withValues(alpha: .15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _scannedVehicle!.isEligible ? '🟢 مستحق' : '🔴 غير مستحق',
                            style: TextStyle(
                              color: _scannedVehicle!.isEligible ? Colors.green.shade800 : Colors.red.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text('المستفيد / الجهة: ${_scannedVehicle!.ownerName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('نوع المركبة: ${_scannedVehicle!.vehicleType} - ${_scannedVehicle!.vehicleModelName}', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('لون السيارة: ${_scannedVehicle!.vehicleColor}', style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 6),
                    Text('التصنيف: ${_scannedVehicle!.isGovernment ? "حكومي (شريحة NFC سحابية)" : "خصوصي (QR Code)"}', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    if (_scannedVehicle!.isGovernment)
                      Text('الحصة الشهرية الكلية: ${_scannedQuantityText(_scannedVehicle!)}\nالمتبقي لهذا الشهر: ${_scannedVehicle!.remainingGovernmentQuota.toStringAsFixed(0)} لتر', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.teal))
                    else
                      Text('الكمية المقررة: ${_scannedVehicle!.allowedQuantity.toStringAsFixed(0)} لتر (كل ${_scannedVehicle!.intervalDays} أيام)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 16),

                    // Security Warning Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.security_rounded, color: Colors.amber.shade800, size: 24),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              '⚠️ تنبيه أمني إلزامي: تأكد بصرياً من تطابق (نوع ولون ورقم اللوحة) للسيارة الواقفة أمام المضخة مع البيانات الظاهرة أعلاه قبل التأكيد!',
                              style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _refillQtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'الكمية التلقائية المراد تزويدها الآن (لتر)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_gas_station_rounded),
                        helperText: '⚡ يتم تعبئة الرصيد المتبقي أو الحصة تلقائياً ويمكن تعديلها عند الحاجة',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Quick Preset Buttons
                    Row(
                      children: [
                        _presetChip('20 لتر', 20),
                        const SizedBox(width: 6),
                        _presetChip('50 لتر', 50),
                        const SizedBox(width: 6),
                        _presetChip('100 لتر', 100),
                        const SizedBox(width: 6),
                        _presetChip('الرصيد الكامل', _scannedVehicle!.isGovernment ? _scannedVehicle!.remainingGovernmentQuota : _scannedVehicle!.allowedQuantity),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              setState(() {
                                _scannedVehicle = null;
                                _vehicleIdController.clear();
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('❌ تم رفض الكوبون لعدم مطابقة بيانات المركبة')),
                              );
                            },
                            icon: const Icon(Icons.cancel_rounded),
                            label: const Text('رفض (عدم المطابقة)'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: _scannedVehicle!.isEligible ? Colors.green : Colors.grey,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: (_confirming || !_scannedVehicle!.isEligible) ? null : _confirmFueling,
                            icon: _confirming
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.check_circle_rounded, size: 20),
                            label: Text(
                              _confirming ? 'جارٍ التأكيد...' : 'تأكيد التزويد الآلي',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _scannedQuantityText(VehicleCoupon v) {
    return '${v.allowedQuantity.toStringAsFixed(0)} لتر';
  }

  Widget _presetChip(String label, double liters) {
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          setState(() {
            _refillQtyController.text = liters.toStringAsFixed(0);
          });
        },
        child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
