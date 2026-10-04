import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NfcScannerScreen extends StatefulWidget {
  const NfcScannerScreen({super.key});

  @override
  State<NfcScannerScreen> createState() => _NfcScannerScreenState();
}

class _NfcScannerScreenState extends State<NfcScannerScreen> {
  bool _scanning = true;
  String _statusMessage = 'قرب الهاتف من شريحة NFC الملاصقة على زجاجة السيارة الحكومية...';

  @override
  void initState() {
    super.initState();
    _startNfcSession();
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }

  Future<void> _startNfcSession() async {
    try {
      final availability = await NfcManager.instance.checkAvailability();
      bool isAvailable = availability == NfcAvailability.enabled;
      if (!isAvailable) {
        if (!mounted) return;
        setState(() {
          _scanning = false;
          _statusMessage = 'خاصية NFC غير متوفرة في هذا الجهاز أو غير مفعلة في الإعدادات.';
        });
        return;
      }

      NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
        onDiscovered: (NfcTag tag) async {
          try {
            final dynamic rawData = (tag as dynamic).data;
            String vehicleId = '';

            if (rawData is Map) {
              final map = Map<String, dynamic>.from(rawData);

              // 1. Look for hardware identifier across tech maps (NfcA, NfcB, IsoDep, etc.)
              for (final entry in map.entries) {
                if (entry.value is Map) {
                  final subMap = entry.value as Map;
                  if (subMap.containsKey('identifier')) {
                    final identifier = subMap['identifier'];
                    if (identifier is List) {
                      vehicleId = identifier.map((e) => (e as int).toRadixString(16).padLeft(2, '0')).join('').toUpperCase();
                      break;
                    }
                  }
                }
              }

              // 2. Look for top-level identifier
              if (vehicleId.isEmpty && map.containsKey('identifier')) {
                final identifier = map['identifier'];
                if (identifier is List) {
                  vehicleId = identifier.map((e) => (e as int).toRadixString(16).padLeft(2, '0')).join('').toUpperCase();
                }
              }

              // 3. Fallback to NDEF payload
              if (vehicleId.isEmpty && map.containsKey('ndef')) {
                final ndef = map['ndef'];
                if (ndef != null && ndef is Map && ndef['cachedMessage'] != null) {
                  final records = ndef['cachedMessage']['records'];
                  if (records is List && records.isNotEmpty) {
                    final payload = records[0]['payload'];
                    if (payload is List) {
                      vehicleId = String.fromCharCodes(payload.cast<int>()).trim();
                    }
                  }
                }
              }

              // 4. Absolute fallback
              if (vehicleId.isEmpty && map.isNotEmpty) {
                vehicleId = map.keys.first.toString();
              }
            }

            if (vehicleId.isNotEmpty && mounted) {
              await NfcManager.instance.stopSession();
              if (!mounted) return;
              Navigator.pop(context, vehicleId);
            } else {
              setState(() {
                _statusMessage = 'تم استشعار الشريحة، يرجى المحاولة مرة أخرى';
              });
            }
          } catch (e) {
            setState(() {
              _statusMessage = 'خطأ في قراءة الشريحة: $e';
            });
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _scanning = false;
        _statusMessage = 'خاصية NFC غير متوفرة أو تتطلب جهاز حقيقي مفعل فيه الـ NFC: $e';
      });
    }
  }

  void _showManualEntryDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إدخال معرف الشريحة يدوياً'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'معرف الكوبون أو رقم المركبة الحكومية'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
          FilledButton(
            onPressed: () {
              final val = controller.text.trim();
              if (val.isNotEmpty) {
                Navigator.pop(ctx);
                Navigator.pop(context, val);
              }
            },
            child: const Text('تم'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قراءة شريحة NFC (للسيارات الحكومية)'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.nfc_rounded, size: 100, color: Colors.blueAccent),
              const SizedBox(height: 30),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              if (_scanning) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
              ],
              OutlinedButton.icon(
                onPressed: () => _showManualEntryDialog(context),
                icon: const Icon(Icons.edit_rounded),
                label: const Text('إدخال المعرف يدوياً (للتجربة أو كبديل)'),
              ),
              if (!_scanning)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        _scanning = true;
                        _statusMessage = 'جاري إعادة المحاولة... قرب الهاتف من الشريحة';
                      });
                      _startNfcSession();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('إعادة محاولة NFC'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
