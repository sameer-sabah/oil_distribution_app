import 'package:flutter/material.dart';
import '../../models/vehicle_coupon.dart';
import '../../services/oil_coupon_service.dart';
import 'nfc_scanner_screen.dart';

class RegisterVehicleScreen extends StatefulWidget {
  final bool isGovernment;
  const RegisterVehicleScreen({super.key, this.isGovernment = false});

  @override
  State<RegisterVehicleScreen> createState() => _RegisterVehicleScreenState();
}

class _RegisterVehicleScreenState extends State<RegisterVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _plateCodeController = TextEditingController();
  final _governmentEntityController = TextEditingController();
  final _nfcChipIdController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedGovernorate = 'بغداد';
  String _selectedVehicleType = 'خصوصي';
  late String _selectedCategory; // 'private' or 'government'

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.isGovernment ? 'government' : 'private';
    _selectedVehicleType = widget.isGovernment ? 'حكومي' : 'خصوصي';
  }

  static final List<String> _governorates = VehicleCoupon.iraqiGovernorateCodes.keys.toList();

  List<String> get _vehicleTypes => widget.isGovernment
      ? const ['حكومي']
      : const ['خصوصي', 'تاكسي', 'حمل', 'أجرة'];

  @override
  void dispose() {
    _nameController.dispose();
    _plateCodeController.dispose();
    _governmentEntityController.dispose();
    _nfcChipIdController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await OilCouponService.instance.registerVehicle(
        ownerName: _nameController.text.trim(),
        plateGovernorate: _selectedCategory == 'private' ? _selectedGovernorate : '',
        plateNumberCode: _plateCodeController.text.trim(),
        plateLetter: '',
        governmentEntity: _selectedCategory == 'government' ? _governmentEntityController.text.trim() : '',
        nfcChipId: _selectedCategory == 'government' ? _nfcChipIdController.text.trim() : '',
        vehicleType: _selectedVehicleType,
        vehicleModelName: _modelController.text.trim(),
        vehicleColor: _colorController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        category: _selectedCategory,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تسجيل المركبة والكوبون بنجاح وفق توجيهات مدير الفرع')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر تسجيل المركبة: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(context) {
    final isGov = widget.isGovernment;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isGov ? 'تسجيل مركبة حكومية جديدة' : 'تسجيل مركبة خصوصية جديدة'),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [
              Text(
                isGov
                    ? 'تسجيل سيارة حكومية (حصة شهرية + ربط شريحة NFC)'
                    : 'تسجيل سيارة خصوصية (للمواطن - استحقاق الكوبون)',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'اسم صاحب السيارة / المستفيد / الجهة الحكومية',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_rounded),
                ),
                validator: (v) => v?.trim().isEmpty == true ? 'الحقل مطلوب' : null,
              ),
              const SizedBox(height: 16),

              // If government: show Government Entity & NFC Chip ID fields with NFC scan button
              if (isGov) ...[
                TextFormField(
                  controller: _governmentEntityController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'الجهة التابعة لها المركبة (مثل: وزارة النفط / المديرية...)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_balance_rounded),
                  ),
                  validator: (v) => v?.trim().isEmpty == true ? 'الحقل مطلوب' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _plateCodeController,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'رقم المركبة الحكومية',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v?.trim().isEmpty == true ? 'مطلوب' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nfcChipIdController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'معرف شريحة NFC الذكية',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.nfc_rounded),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Colors.teal),
                    ),
                    onPressed: () async {
                      final scannedNfc = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(builder: (_) => const NfcScannerScreen()),
                      );
                      if (scannedNfc != null && scannedNfc.isNotEmpty) {
                        _nfcChipIdController.text = scannedNfc;
                      }
                    },
                    icon: const Icon(Icons.nfc_rounded, color: Colors.teal),
                    label: const Text('قراءة شريحة NFC بالهاتف لتعبئة المعرف', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedGovernorate,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'المحافظة والرمز',
                          border: OutlineInputBorder(),
                        ),
                        items: _governorates.map((g) {
                          final code = VehicleCoupon.iraqiGovernorateCodes[g] ?? '';
                          final label = code.isNotEmpty ? '$g -$code' : g;
                          return DropdownMenuItem(value: g, child: Text(label, overflow: TextOverflow.ellipsis));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedGovernorate = val ?? 'بغداد'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _plateCodeController,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'رقم اللوحة',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v?.trim().isEmpty == true ? 'مطلوب' : null,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedVehicleType,
                decoration: const InputDecoration(
                  labelText: 'نوع المركبة',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_car_rounded),
                ),
                items: _vehicleTypes.map((t) {
                  return DropdownMenuItem(value: t, child: Text(t));
                }).toList(),
                onChanged: (val) => setState(() => _selectedVehicleType = val ?? 'خصوصي'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'اسم المركبة (الموديل/النوع، مثل: كيا سيراتو)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.card_travel_rounded),
                ),
                validator: (v) => v?.trim().isEmpty == true ? 'الحقل مطلوب' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'لون المركبة',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.palette_rounded),
                ),
                validator: (v) => v?.trim().isEmpty == true ? 'الحقل مطلوب' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_rounded),
                ),
                validator: (v) => v?.trim().isEmpty == true ? 'الحقل مطلوب' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                textAlign: TextAlign.right,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور / الرقم السري الخاص بالمركبة',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_rounded),
                ),
                validator: (v) => v?.trim().isEmpty == true ? 'كلمة المرور مطلوبة' : null,
              ),
              const SizedBox(height: 30),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.check_circle_rounded),
                label: const Text('حفظ وتسجيل المركبة', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
