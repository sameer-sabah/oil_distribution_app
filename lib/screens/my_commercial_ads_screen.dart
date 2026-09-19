import 'package:flutter/material.dart';
import '../models/commercial_ad.dart';
import '../services/commercial_service.dart';
import 'commercial_payment_screen.dart';
import 'commercial_ad_details_screen.dart';
import 'commercial_conversation_screen.dart';

class MyCommercialAdsScreen extends StatelessWidget {
  const MyCommercialAdsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('إعلاناتي'), centerTitle: true),
    body: StreamBuilder<List<CommercialAd>>(
      stream: CommercialService.instance.myAds(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final ads = snapshot.data ?? [];
        if (ads.isEmpty) return const Center(child: Text('لا توجد إعلانات خاصة بك'));
        return ListView.builder(padding: const EdgeInsets.all(16), itemCount: ads.length, itemBuilder: (_, i) => _card(context, ads[i]));
      },
    ),
  );

  Widget _card(BuildContext context, CommercialAd ad) {
    final canPay = ad.status == 'approved' && ad.paymentStatus == 'pending' && ad.approvedPrice > 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(children: [
        ListTile(
          leading: ad.imageUrls.isEmpty ? const CircleAvatar(child: Icon(Icons.campaign)) : CircleAvatar(backgroundImage: NetworkImage(ad.imageUrls.first)),
          title: Text(ad.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
            'الحالة: ${_status(ad.status)}\n'
                'الدفع: ${_paymentStatus(ad.paymentStatus)}\n'
                'السعر المعتمد: ${ad.approvedPrice.toStringAsFixed(0)} د.ع'
                '${ad.rejectionReason.isEmpty ? '' : '\nسبب الرفض: ${ad.rejectionReason}'}',
          ),
          isThreeLine: true,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CommercialAdDetailsScreen(ad: ad))),
        ),
        Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 12), child: Wrap(spacing: 8, children: [
          if (canPay) ElevatedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CommercialPaymentScreen(entityType: 'ad', entityId: ad.id, amount: ad.approvedPrice))), icon: const Icon(Icons.payment), label: const Text('إتمام الدفع')),
          FilledButton.tonalIcon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CommercialConversationScreen(
                  entityType: 'ad',
                  entityId: ad.id,
                  ownerUid: ad.ownerUid,
                  title: ad.title,
                  ownerName: ad.ownerName,
                  ownerPhone: ad.ownerPhone,
                  ownerWhatsapp: ad.ownerWhatsapp,
                  isAdmin: false,
                ),
              ),
            ),
            icon: const Icon(Icons.support_agent_rounded),
            label: const Text('محادثة الإدارة'),
          ),
          OutlinedButton.icon(onPressed: () => _analytics(context, ad), icon: const Icon(Icons.analytics), label: const Text('الإحصائيات')),
          OutlinedButton.icon(onPressed: () => _extend(context, ad), icon: const Icon(Icons.update), label: const Text('تمديد')),
        ])),
      ]),
    );
  }

  String _status(String value) => switch (value) { 'pending' => 'قيد المراجعة', 'approved' => 'مقبول بانتظار الدفع', 'published' => 'منشور', 'rejected' => 'مرفوض', 'stopped' => 'موقوف', 'extension_pending' => 'طلب التمديد قيد المراجعة', _ => value };

  String _paymentStatus(String value) => switch (value) { 'pending' => 'بانتظار الدفع', 'submitted' => 'مرسل بانتظار تأكيد الإدارة', 'paid' => 'تم تأكيد الدفع', 'rejected' => 'الدفع مرفوض', _ => value };

  void _analytics(BuildContext context, CommercialAd ad) => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('إحصائيات الإعلان'), content: Column(mainAxisSize: MainAxisSize.min, children: [Text('المشاهدات: ${ad.views}'), Text('النقرات: ${ad.clicks}'), Text('الاتصالات: ${ad.calls}'), Text('WhatsApp: ${ad.whatsappClicks}'), Text('فتح الخريطة: ${ad.mapClicks}')]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق'))]));
  Future<void> _extend(BuildContext context, CommercialAd ad) async {
    final initial = DateTime.tryParse(ad.endAt) ?? DateTime.now();
    final date = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 730)), initialDate: initial.isBefore(DateTime.now()) ? DateTime.now() : initial);
    if (date == null) return;
    await CommercialService.instance.requestExtension(entityType: 'ad', entityId: ad.id, requestedEndAt: date.toIso8601String());
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلب التمديد للمراجعة')));
  }

}
