import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/commercial_service.dart';
import 'map_picker_screen.dart';

class CommercialServiceFormScreen extends StatefulWidget {
  const CommercialServiceFormScreen({super.key});
  @override
  State<CommercialServiceFormScreen> createState() => _CommercialServiceFormScreenState();
}

class _CommercialServiceFormScreenState extends State<CommercialServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _business = TextEditingController();
  final _description = TextEditingController();
  final _category = TextEditingController();
  final _phone = TextEditingController();
  final _whatsapp = TextEditingController();
  final _website = TextEditingController();
  final _governorate = TextEditingController();
  final _district = TextEditingController();
  final _address = TextEditingController();
  final _hours = TextEditingController();
  final _duration = TextEditingController(text: '30');
  final _price = TextEditingController();
  final _start = TextEditingController();
  final _end = TextEditingController();
  List<File> _images = [];
  double _lat = 0;
  double _lng = 0;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _business, _description, _category, _phone, _whatsapp, _website, _governorate, _district, _address, _hours, _duration, _price, _start, _end]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages() async { final items = await ImagePicker().pickMultiImage(imageQuality: 82); if (items.isNotEmpty) setState(() => _images = items.map((e) => File(e.path)).toList()); }
  Future<void> _pickDate(TextEditingController controller) async { final date = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 730)), initialDate: DateTime.now()); if (date != null) controller.text = date.toIso8601String(); }
  Future<void> _pickLocation() async { final result = await Navigator.push<LatLng>(context, MaterialPageRoute(builder: (_) => const MapPickerScreen())); if (result != null) setState(() { _lat = result.latitude; _lng = result.longitude; }); }
  Widget _field(TextEditingController c, String label, {int maxLines = 1, TextInputType? type, bool required = false}) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TextFormField(controller: c, maxLines: maxLines, keyboardType: type, validator: required ? (v) => v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null : null, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), filled: true)));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أضف صورة واحدة على الأقل للخدمة'))); return; }
    setState(() => _saving = true);
    try {
      await CommercialService.instance.createService(data: {
        'name': _name.text.trim(), 'businessName': _business.text.trim(), 'description': _description.text.trim(), 'category': _category.text.trim(), 'phone': _phone.text.trim(), 'whatsapp': _whatsapp.text.trim(), 'website': _website.text.trim(), 'governorate': _governorate.text.trim(), 'district': _district.text.trim(), 'address': _address.text.trim(), 'latitude': _lat, 'longitude': _lng, 'workingHours': _hours.text.trim(), 'startAt': _start.text.trim(), 'endAt': _end.text.trim(), 'durationDays': int.tryParse(_duration.text) ?? 30, 'requestedPrice': double.tryParse(_price.text) ?? 0,
      }, imageFiles: _images);
      if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الخدمة للمراجعة'))); Navigator.pop(context);
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر إرسال الخدمة: $e'))); }
    finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('إضافة خدمة مدفوعة'), centerTitle: true),
    body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
      _field(_name, 'اسم الخدمة', required: true), _field(_business, 'اسم النشاط / الشركة', required: true), _field(_description, 'وصف الخدمة', maxLines: 4, required: true), _field(_category, 'نوع الخدمة'), _field(_phone, 'رقم الهاتف', type: TextInputType.phone), _field(_whatsapp, 'WhatsApp', type: TextInputType.phone), _field(_website, 'الرابط'),
      Row(children: [Expanded(child: _field(_governorate, 'المحافظة')), const SizedBox(width: 10), Expanded(child: _field(_district, 'القضاء'))]), _field(_address, 'العنوان'), _field(_hours, 'ساعات العمل'),
      OutlinedButton.icon(onPressed: _pickLocation, icon: const Icon(Icons.location_on), label: Text(_lat == 0 && _lng == 0 ? 'تحديد الموقع على الخريطة' : 'تم تحديد الموقع')),
      const SizedBox(height: 10), OutlinedButton.icon(onPressed: _pickImages, icon: const Icon(Icons.photo_library), label: Text(_images.isEmpty ? 'إضافة صور الخدمة' : 'تم اختيار ${_images.length} صورة')),
      if (_images.isNotEmpty) SizedBox(height: 90, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: _images.length, separatorBuilder: (_, _) => const SizedBox(width: 8), itemBuilder: (_, i) => ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(_images[i], width: 100, fit: BoxFit.cover)))),
      const SizedBox(height: 12), _field(_duration, 'مدة الظهور بالأيام', type: TextInputType.number, required: true), _field(_price, 'الميزانية المطلوبة (دينار)', type: TextInputType.number),
      Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () => _pickDate(_start), icon: const Icon(Icons.date_range), label: Text(_start.text.isEmpty ? 'بداية' : 'تم'))), const SizedBox(width: 10), Expanded(child: OutlinedButton.icon(onPressed: () => _pickDate(_end), icon: const Icon(Icons.event), label: Text(_end.text.isEmpty ? 'نهاية' : 'تم')))]),
      const SizedBox(height: 20), ElevatedButton.icon(onPressed: _saving ? null : _save, icon: const Icon(Icons.send), label: Text(_saving ? 'جارٍ الإرسال...' : 'إرسال الخدمة للمراجعة')),
    ])),
  );
}
