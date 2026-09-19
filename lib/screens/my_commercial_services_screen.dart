import 'package:flutter/material.dart';
import '../models/commercial_service_model.dart';
import '../services/commercial_service.dart';
import 'commercial_payment_screen.dart';

class MyCommercialServicesScreen extends StatelessWidget {
  const MyCommercialServicesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('خدماتي'), centerTitle: true),
    body: StreamBuilder<List<CommercialServiceModel>>(
      stream: CommercialService.instance.myServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data ?? [];
        if (items.isEmpty) return const Center(child: Text('لا توجد خدمات خاصة بك'));
        return ListView.builder(padding: const EdgeInsets.all(16), itemCount: items.length, itemBuilder: (_, i) => _card(context, items[i]));
      },
    ),
  );

  Widget _card(BuildContext context, CommercialServiceModel item) {
    final canPay = item.status == 'approved' && item.paymentStatus == 'pending' && item.approvedPrice > 0;
    return Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(
      leading: item.imageUrls.isEmpty ? const CircleAvatar(child: Icon(Icons.miscellaneous_services)) : CircleAvatar(backgroundImage: NetworkImage(item.imageUrls.first)),
      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('الحالة: ${_status(item.status)}\nالسعر المعتمد: ${item.approvedPrice.toStringAsFixed(0)} د.ع'),
      isThreeLine: true,
      trailing: Wrap(children: [if (canPay) IconButton(icon: const Icon(Icons.payment), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CommercialPaymentScreen(entityType: 'service', entityId: item.id, amount: item.approvedPrice)))), IconButton(icon: const Icon(Icons.update), onPressed: () => _extend(context, item))]),
    ));
  }
  String _status(String value) => switch (value) { 'pending' => 'قيد المراجعة', 'approved' => 'مقبول بانتظار الدفع', 'published' => 'منشور', 'rejected' => 'مرفوض', 'stopped' => 'موقوف', _ => value };
  Future<void> _extend(BuildContext context, CommercialServiceModel item) async {
    final initial = DateTime.tryParse(item.endAt) ?? DateTime.now();
    final date = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 730)), initialDate: initial.isBefore(DateTime.now()) ? DateTime.now() : initial);
    if (date == null) return;
    await CommercialService.instance.requestExtension(entityType: 'service', entityId: item.id, requestedEndAt: date.toIso8601String());
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلب التمديد للمراجعة')));
  }

}
