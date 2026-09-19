import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/advertiser_account.dart';
import '../models/wallet_model.dart';
import '../services/wallet_service.dart';

class WalletScreen extends StatefulWidget {
  final AdvertiserAccount account;

  const WalletScreen({super.key, required this.account});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  void _openTopUpSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _TopUpBottomSheet(account: widget.account),
    );
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('محفظتي'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Balance Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'رصيد المحفظة',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white.withValues(alpha: .9),
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${widget.account.balance.toStringAsFixed(0)} د.ع',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _openTopUpSheet,
                    icon: const Icon(Icons.add_card_rounded),
                    label: const Text(
                      'شحن المحفظة',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'حركة المحفظة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<WalletTopUpRequest>>(
            stream: WalletService.instance.userTopUpRequestsStream(widget.account.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ));
              }
              final requests = snapshot.data ?? [];
              if (requests.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'لا توجد حركات على المحفظة بعد',
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final req = requests[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _statusColor(req.status).withValues(alpha: .15),
                        child: Icon(
                          _statusIcon(req.status),
                          color: _statusColor(req.status),
                        ),
                      ),
                      title: Text(
                        'شحن مبلغ: ${req.amount.toStringAsFixed(0)} د.ع',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'طريقة الدفع: ${req.method}\n'
                        'المرجع: ${req.referenceNumber}\n'
                        'الحالة: ${_statusText(req.status)}'
                        '${req.adminNote.isNotEmpty ? '\nملاحظة الإدارة: ${req.adminNote}' : ''}',
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) => switch (status) {
    'approved' => Colors.green,
    'rejected' => Colors.red,
    _ => Colors.orange,
  };

  IconData _statusIcon(String status) => switch (status) {
    'approved' => Icons.check_circle_rounded,
    'rejected' => Icons.cancel_rounded,
    _ => Icons.hourglass_top_rounded,
  };

  String _statusText(String status) => switch (status) {
    'approved' => 'مقبولة',
    'rejected' => 'مرفوضة',
    _ => 'قيد المراجعة',
  };
}

class _TopUpBottomSheet extends StatefulWidget {
  final AdvertiserAccount account;

  const _TopUpBottomSheet({required this.account});

  @override
  State<_TopUpBottomSheet> createState() => __TopUpBottomSheetState();
}

class __TopUpBottomSheetState extends State<_TopUpBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _refController = TextEditingController();
  final _imageController = TextEditingController();

  PaymentMethod? _selectedMethod;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار طريقة الشحن')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('المبلغ غير صحيح')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await WalletService.instance.submitTopUpRequest(
        userId: widget.account.id,
        userName: widget.account.fullName,
        userPhone: widget.account.phone,
        amount: amount,
        method: _selectedMethod!.name,
        referenceNumber: _refController.text.trim(),
        receiptImageUrl: _imageController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال طلب الشحن بنجاح، بانتظار موافقة الإدارة')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر إرسال الطلب: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      child: StreamBuilder<List<PaymentMethod>>(
        stream: WalletService.instance.paymentMethodsStream(),
        builder: (context, snapshot) {
          final methods = snapshot.data ?? [];
          if (methods.isNotEmpty) {
            if (_selectedMethod == null || !methods.contains(_selectedMethod)) {
              _selectedMethod = methods.first;
            }
          } else {
            _selectedMethod = null;
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'شحن المحفظة',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'حول المبلغ إلى إحدى طرق الدفع ثم أدخل بيانات التحويل. الرصيد يضاف بعد موافقة الإدارة.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'طريقة الشحن',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<PaymentMethod>(
                    value: _selectedMethod,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: methods.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text(m.name),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedMethod = val),
                    validator: (val) => val == null ? 'الرجاء اختيار طريقة الشحن' : null,
                  ),
                  if (_selectedMethod != null && _selectedMethod!.accountNumber.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'رقم الحساب / المحفظة: ${_selectedMethod!.accountNumber}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            tooltip: 'نسخ الرقم',
                            icon: const Icon(Icons.copy_rounded, size: 20),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _selectedMethod!.accountNumber));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم نسخ رقم الحساب')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'المبلغ',
                      prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'الرجاء إدخال مبلغ صحيح' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _refController,
                    decoration: InputDecoration(
                      labelText: 'رقم / مرجع التحويل',
                      prefixIcon: const Icon(Icons.tag_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => v?.trim().isEmpty == true ? 'الرجاء إدخال رقم المرجع' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _imageController,
                    decoration: InputDecoration(
                      labelText: 'رابط صورة وصل التحويل (اختياري)',
                      prefixIcon: const Icon(Icons.image_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isLoading ? null : _submit,
                      icon: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send_rounded),
                      label: const Text('إرسال طلب الشحن', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
