import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'commercial_payment_screen.dart';

class MyCommercialPaymentsScreen extends StatelessWidget {
  const MyCommercialPaymentsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('المدفوعات والفواتير'), centerTitle: true),
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance
            .ref('commercialPayments')
            .orderByChild('ownerUid')
            .equalTo(uid)
            .onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('تعذر تحميل المدفوعات: ${snapshot.error}'),
            );
          }
          final value = snapshot.data?.snapshot.value;
          if (value == null) return const Center(child: Text('لا توجد عمليات دفع'));
          final raw = Map<dynamic, dynamic>.from(value as Map);
          final list = raw.entries.map((e) => Map<String, dynamic>.from(e.value as Map)).where((e) => e['ownerUid']?.toString() == uid).toList();
          list.sort((a, b) => (b['createdAt'] ?? '').toString().compareTo((a['createdAt'] ?? '').toString()));
          if (list.isEmpty) return const Center(child: Text('لا توجد عمليات دفع'));
          return ListView.builder(padding: const EdgeInsets.all(16), itemCount: list.length, itemBuilder: (_, i) {
            final p = list[i];
            final status = p['status']?.toString() ?? '';
            final canPay = status == 'awaiting_payment';
            final amount = double.tryParse(p['amount']?.toString() ?? '') ?? 0;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
                    title: Text(
                      '${amount.toStringAsFixed(0)} د.ع',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'النوع: ${p['entityType'] == 'ad' ? 'إعلان' : 'خدمة'}\n'
                          'طريقة الدفع: ${(p['method'] ?? '').toString().isEmpty ? 'لم تحدد بعد' : p['method']}\n'
                          'الحالة: ${_status(status)}',
                    ),
                    isThreeLine: true,
                  ),
                  if (canPay)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: amount <= 0
                              ? null
                              : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CommercialPaymentScreen(
                                entityType: p['entityType']?.toString() ?? 'ad',
                                entityId: p['entityId']?.toString() ?? '',
                                amount: amount,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.payment),
                          label: const Text('إتمام الدفع'),
                        ),
                      ),
                    ),
                ],
              ),
            );
          });
        },
      ),
    );
  }
  String _status(String v) => switch (v) { 'awaiting_payment' => 'بانتظار الدفع', 'submitted' => 'مرسل للمراجعة', 'paid' => 'مدفوع ومنشور', 'rejected' => 'مرفوض', _ => v };
}
