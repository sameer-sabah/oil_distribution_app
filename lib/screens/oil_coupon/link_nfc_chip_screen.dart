import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../../models/vehicle_coupon.dart';
import '../../services/oil_coupon_service.dart';
import 'nfc_scanner_screen.dart';

class LinkNfcChipScreen extends StatefulWidget {
  const LinkNfcChipScreen({super.key});

  @override
  State<LinkNfcChipScreen> createState() => _LinkNfcChipScreenState();
}

class _LinkNfcChipScreenState extends State<LinkNfcChipScreen> {
  final _searchController = TextEditingController();
  final _nfcIdController = TextEditingController();

  bool _searching = false;
  bool _saving = false;
  VehicleCoupon? _foundVehicle;
  String _errorMessage = '';

  @override
  void dispose() {
    _searchController.dispose();
    _nfcIdController.dispose();
    super.dispose();
  }

  Future<void> _searchVehicle() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _searching = true;
      _foundVehicle = null;
      _errorMessage = '';
    });

    try {
      final vehicle = await OilCouponService.instance.searchVehicle(query);
      if (!mounted) return;
      if (vehicle == null) {
        setState(() {
          _errorMessage = 'لم يتم العثور على مركبة بهذا المعرف أو رقم اللوحة';
        });
      } else if (!vehicle.isGovernment) {
        setState(() {
          _errorMessage = 'هذه المركبة خصوصية وليست حكومية (الربط بـ NFC مخصص للسيارات الحكومية فقط)';
        });
      } else {
        _nfcIdController.text = vehicle.nfcChipId;
        setState(() {
          _foundVehicle = vehicle;
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

  Future<void> _scanAndLinkNfcTag() async {
    if (_foundVehicle == null) return;

    try {
      final availability = await NfcManager.instance.checkAvailability();
      bool isAvailable = availability == NfcAvailability.enabled;
      if (!isAvailable) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خاصية NFC غير متوفرة في هذا الجهاز')),
        );
        return;
      }

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('قراءة وربط شريحة NFC'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text('قرب شريحة NFC الجديدة من خلف الهاتف لربطها بالمركبة:\n${_foundVehicle!.plateFull}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                NfcManager.instance.stopSession();
                Navigator.pop(ctx);
              },
              child: const Text('إغلاق'),
            ),
          ],
        ),
      );

      NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
        onDiscovered: (NfcTag tag) async {
          try {
            final dynamic rawData = (tag as dynamic).data;
            String nfcUid = '';

            if (rawData is Map) {
              final map = Map<String, dynamic>.from(rawData);
              for (final entry in map.entries) {
                if (entry.value is Map && (entry.value as Map).containsKey('identifier')) {
                  final identifier = (entry.value as Map)['identifier'];
                  if (identifier is List) {
                    nfcUid = identifier.map((e) => (e as int).toRadixString(16).padLeft(2, '0')).join('').toUpperCase();
                    break;
                  }
                }
              }
              if (nfcUid.isEmpty && map.containsKey('identifier')) {
                final identifier = map['identifier'];
                if (identifier is List) {
                  nfcUid = identifier.map((e) => (e as int).toRadixString(16).padLeft(2, '0')).join('').toUpperCase();
                }
              }
              if (nfcUid.isEmpty && map.isNotEmpty) {
                nfcUid = map.keys.first.toString();
              }
            }

            if (nfcUid.isEmpty) {
              nfcUid = 'NFC_${DateTime.now().millisecondsSinceEpoch}';
            }

            await NfcManager.instance.stopSession();

            await OilCouponService.instance.vehiclesRef.child(_foundVehicle!.id).update({
              'nfcChipId': nfcUid,
              'updatedAt': DateTime.now().toIso8601String(),
            });

            if (!mounted) return;
            Navigator.pop(context); // close dialog
            setState(() {
              _nfcIdController.text = nfcUid;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ تم ربط وتفعيل شريحة NFC بالمركبة الحكومية بنجاح')),
            );
          } catch (e) {
            if (!mounted) return;
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('تعذر قراءة الشريحة: $e')),
            );
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر تشغيل جلسة NFC: $e')),
      );
    }
  }

  Future<void> _linkChip() async {
    if (_foundVehicle == null) return;
    final nfcId = _nfcIdController.text.trim();
    if (nfcId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى قراءة أو إدخال معرف شريحة NFC')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await OilCouponService.instance.vehiclesRef.child(_foundVehicle!.id).update({
        'nfcChipId': nfcId,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم ربط وتفعيل شريحة NFC للمركبة الحكومية بنجاح')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر ربط الشريحة: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('استمارة ربط وتفعيل شريحة NFC (محطة حكومية)'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'البحث عن المركبة الحكومية لربط الشريحة:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(
                              labelText: 'رقم اللوحة أو معرف الكوبون',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.search_rounded),
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

            if (_foundVehicle != null) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _foundVehicle!.plateFull,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      const Divider(height: 20),
                      Text('الجهة الحكومية: ${_foundVehicle!.governmentEntity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text('المستفيد: ${_foundVehicle!.ownerName}', style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: const BorderSide(color: Colors.teal),
                              ),
                              onPressed: () async {
                                final scannedNfc = await Navigator.push<String>(
                                  context,
                                  MaterialPageRoute(builder: (_) => const NfcScannerScreen()),
                                );
                                if (scannedNfc != null && scannedNfc.isNotEmpty) {
                                  _nfcIdController.text = scannedNfc;
                                }
                              },
                              icon: const Icon(Icons.nfc_rounded, color: Colors.teal),
                              label: const Text('قراءة شريحة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: Colors.indigo,
                              ),
                              onPressed: _scanAndLinkNfcTag,
                              icon: const Icon(Icons.nfc_rounded),
                              label: const Text('📡 مسح وربط شريحة', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _nfcIdController,
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          labelText: 'معرف شريحة NFC (NFC Chip ID)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.memory_rounded),
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _saving ? null : _linkChip,
                          icon: _saving
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.check_circle_rounded),
                          label: const Text('تأكيد ربط وتفعيل شريحة NFC', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
