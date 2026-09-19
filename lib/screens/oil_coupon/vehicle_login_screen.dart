import 'package:flutter/material.dart';
import '../../models/vehicle_coupon.dart';
import '../../services/oil_coupon_service.dart';
import 'oil_coupon_home_screen.dart';
import 'register_vehicle_screen.dart';

class VehicleLoginScreen extends StatefulWidget {
  final bool isGovernment;
  const VehicleLoginScreen({super.key, this.isGovernment = false});

  @override
  State<VehicleLoginScreen> createState() => _VehicleLoginScreenState();
}

class _VehicleLoginScreenState extends State<VehicleLoginScreen> {
  // Private login controllers
  final _privateFormKey = GlobalKey<FormState>();
  final _privateNumberController = TextEditingController();
  final _privatePasswordController = TextEditingController();
  String _selectedGovernorate = 'بغداد';

  // Government login controllers
  final _govFormKey = GlobalKey<FormState>();
  final _govEntityController = TextEditingController();
  final _govNumberController = TextEditingController();
  final _govPasswordController = TextEditingController();

  bool _loading = false;
  String _errorMessage = '';

  static const List<String> _governorates = [
    'بغداد',
    'البصرة',
    'نينوى',
    'أربيل',
    'النجف',
    'كربلاء',
    'السليمانية',
    'الأنبار',
    'ديالى',
    'بابل',
    'كركوك',
    'ميسان',
    'ذي قار',
    'المثنى',
    'القادسية',
    'صلاح الدين',
    'واسط',
    'دهوك',
    'حلبجة',
  ];

  @override
  void dispose() {
    _privateNumberController.dispose();
    _privatePasswordController.dispose();
    _govEntityController.dispose();
    _govNumberController.dispose();
    _govPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loginPrivate() async {
    if (!_privateFormKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    try {
      final vehicle = await OilCouponService.instance.loginWithPlateAndPin(
        governorate: _selectedGovernorate,
        numberCode: _privateNumberController.text.trim(),
        password: _privatePasswordController.text.trim(),
      );

      if (!mounted) return;

      if (vehicle == null) {
        setState(() {
          _errorMessage = 'بيانات دخول السيارات الخصوصية غير صحيحة';
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => OilCouponHomeScreen(vehicle: vehicle)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'خطأ في تسجيل الدخول: $e';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginGovernment() async {
    if (!_govFormKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    try {
      final vehicle = await OilCouponService.instance.loginGovernmentVehicle(
        governmentEntity: _govEntityController.text.trim(),
        numberCode: _govNumberController.text.trim(),
        password: _govPasswordController.text.trim(),
      );

      if (!mounted) return;

      if (vehicle == null) {
        setState(() {
          _errorMessage = 'بيانات دخول السيارات الحكومية غير صحيحة';
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => OilCouponHomeScreen(vehicle: vehicle)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'خطأ في تسجيل الدخول: $e';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(context) {
    final isGov = widget.isGovernment;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isGov ? 'تسجيل دخول السيارات الحكومية (الكوبون)' : 'تسجيل دخول السيارات الخصوصية (الكوبون)'),
          centerTitle: true,
        ),
        body: isGov ? _buildGovernmentForm() : _buildPrivateForm(),
      ),
    );
  }

  Widget _buildPrivateForm() {
    return Form(
      key: _privateFormKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        children: [
          const SizedBox(height: 10),
          const Text(
            'تسجيل دخول السيارات الخصوصية (المواطنين)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: _selectedGovernorate,
            decoration: const InputDecoration(
              labelText: 'المحافظة',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_city_rounded),
            ),
            items: _governorates.map((g) {
              final code = VehicleCoupon.iraqiGovernorateCodes[g] ?? '';
              final label = code.isNotEmpty ? '$g -$code' : g;
              return DropdownMenuItem(value: g, child: Text(label));
            }).toList(),
            onChanged: (val) => setState(() => _selectedGovernorate = val ?? 'بغداد'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _privateNumberController,
            textAlign: TextAlign.right,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'رقم اللوحة',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.pin_rounded),
            ),
            validator: (v) => v?.trim().isEmpty == true ? 'مطلوب' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _privatePasswordController,
            textAlign: TextAlign.right,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'كلمة المرور / الرقم السري',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock_rounded),
            ),
            validator: (v) => v?.trim().isEmpty == true ? 'كلمة المرور مطلوبة' : null,
          ),
          const SizedBox(height: 20),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(_errorMessage, style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
            ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _loading ? null : _loginPrivate,
            icon: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.login_rounded),
            label: const Text('تسجيل الدخول (خصوصي)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterVehicleScreen(isGovernment: false)),
              );
            },
            child: const Text('تسجيل مركبة خصوصية جديدة (كوبون جديد)'),
          ),
        ],
      ),
    );
  }

  Widget _buildGovernmentForm() {
    return Form(
      key: _govFormKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        children: [
          const SizedBox(height: 10),
          const Text(
            'تسجيل دخول السيارات الحكومية',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _govEntityController,
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              labelText: 'الجهة التابعة لها المركبة (مثل: وزارة النفط)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.account_balance_rounded),
            ),
            validator: (v) => v?.trim().isEmpty == true ? 'الحقل مطلوب' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _govNumberController,
            textAlign: TextAlign.right,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'رقم المركبة الحكومية',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.pin_rounded),
            ),
            validator: (v) => v?.trim().isEmpty == true ? 'مطلوب' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _govPasswordController,
            textAlign: TextAlign.right,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'كلمة المرور / الرقم السري',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock_rounded),
            ),
            validator: (v) => v?.trim().isEmpty == true ? 'كلمة المرور مطلوبة' : null,
          ),
          const SizedBox(height: 20),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(_errorMessage, style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
            ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _loading ? null : _loginGovernment,
            icon: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.login_rounded),
            label: const Text('تسجيل الدخول (حكومي)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterVehicleScreen(isGovernment: true)),
              );
            },
            child: const Text('تسجيل مركبة حكومية جديدة'),
          ),
        ],
      ),
    );
  }
}
