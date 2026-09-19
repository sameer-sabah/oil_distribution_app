import 'package:flutter/material.dart';
import '../../models/wallet_model.dart';
import '../../services/wallet_service.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEditDialog(BuildContext context, {PaymentMethod? method}) {
    final nameController = TextEditingController(text: method?.name ?? '');
    final accountController = TextEditingController(text: method?.accountNumber ?? '');
    final descController = TextEditingController(text: method?.description ?? '');
    final balanceController = TextEditingController(text: method?.balance.toString() ?? '0');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(method == null ? 'إضافة وسيلة دفع / ماستر' : 'تعديل وسيلة الدفع / الماستر'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'اسم وسيلة الدفع (مثال: test iq, ZainCash)'),
                  validator: (v) => v?.trim().isEmpty == true ? 'الحقل مطلوب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: accountController,
                  decoration: const InputDecoration(labelText: 'رقم الماستر / الحساب / المحفظة'),
                  validator: (v) => v?.trim().isEmpty == true ? 'الحقل مطلوب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: balanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'الرصيد الحقيقي في الماستر (د.ع)'),
                  validator: (v) => double.tryParse(v ?? '') == null ? 'المبلغ غير صحيح' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'وصف أو ملاحظات (اختياري)'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await WalletService.instance.savePaymentMethod(
                    id: method?.id,
                    name: nameController.text,
                    accountNumber: accountController.text,
                    description: descController.text,
                    balance: double.tryParse(balanceController.text.trim()) ?? 0.0,
                  );
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حفظ وسيلة الدفع بنجاح')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تعذر الحفظ: $e')),
                  );
                }
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('وسائل الدفع والماستر'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن وسيلة دفع أو ماستر...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          StreamBuilder<List<PaymentMethod>>(
            stream: WalletService.instance.paymentMethodsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }
              var methods = snapshot.data ?? [];
              if (_searchQuery.isNotEmpty) {
                methods = methods.where((m) =>
                m.name.toLowerCase().contains(_searchQuery) ||
                    m.accountNumber.contains(_searchQuery)).toList();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('إجمالي وسائل الدفع: ${methods.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Text('صفحة 1 من 1', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<PaymentMethod>>(
              stream: WalletService.instance.paymentMethodsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                var methods = snapshot.data ?? [];
                if (_searchQuery.isNotEmpty) {
                  methods = methods.where((m) =>
                  m.name.toLowerCase().contains(_searchQuery) ||
                      m.accountNumber.contains(_searchQuery)).toList();
                }

                if (methods.isEmpty) {
                  return const Center(child: Text('لا توجد وسائل دفع مضافة حالياً'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: methods.length,
                  itemBuilder: (context, index) {
                    final m = methods[index];
                    return _MasterCardWidget(
                      method: m,
                      onEdit: () => _showAddEditDialog(context, method: m),
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('حذف وسيلة الدفع'),
                            content: const Text('هل أنت متأكد من حذف وسيلة الدفع هذه؟'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                              FilledButton(
                                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('حذف'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await WalletService.instance.deletePaymentMethod(m.id);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم حذف وسيلة الدفع')),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MasterCardWidget extends StatelessWidget {
  final PaymentMethod method;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MasterCardWidget({
    required this.method,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 45,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.amber.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.memory_rounded, color: Colors.brown, size: 24),
              ),
              Row(
                children: [
                  IconButton(
                    tooltip: 'تعديل',
                    icon: const Icon(Icons.edit_outlined, color: Colors.white70),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    tooltip: 'حذف',
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            method.accountNumber.isEmpty ? '**** **** **** ****' : method.accountNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 2.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('وسيلة الدفع / الماستر', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    method.name,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('الرصيد الحقيقي في الماستر', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    '${method.balance.toStringAsFixed(0)} د.ع',
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
