import 'package:flutter/material.dart';

import '../models/advertiser_account.dart';
import '../services/advertiser_account_service.dart';
import '../services/commercial_service.dart';
import '../services/commercial_payment_settings_service.dart';
import '../services/wallet_service.dart';
import 'wallet_screen.dart';

class CommercialPaymentScreen extends StatefulWidget {
  final String entityType;
  final String entityId;
  final double amount;

  const CommercialPaymentScreen({
    super.key,
    required this.entityType,
    required this.entityId,
    required this.amount,
  });

  @override
  State<CommercialPaymentScreen> createState() =>
      _CommercialPaymentScreenState();
}

class _CommercialPaymentScreenState
    extends State<CommercialPaymentScreen> {
  String method = 'اتفاق مع الإدارة';
  final note = TextEditingController();

  bool saving = false;
  bool _settingsLoading = true;

  bool _accountLoading = true;
  AdvertiserAccount? _advertiserAccount;
  bool _walletPaying = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentSettings();
    _loadAdvertiserAccount();
  }

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentSettings() async {
    try {
      await CommercialPaymentSettingsService
          .instance
          .getSettings();

      if (!mounted) return;

      setState(() {
        _settingsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _settingsLoading = false;
      });
    }
  }

  Future<void> _loadAdvertiserAccount() async {
    try {
      final acc = await AdvertiserAccountService.instance.getCurrentAccount();
      if (!mounted) return;
      setState(() {
        _advertiserAccount = acc;
        _accountLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _accountLoading = false;
      });
    }
  }

  Future<void> _payFromWallet() async {
    if (_walletPaying || _advertiserAccount == null) return;
    if (_advertiserAccount!.balance < widget.amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رصيد المحفظة غير كافٍ. يرجى شحن المحفظة أولاً.')),
      );
      return;
    }

    setState(() => _walletPaying = true);
    try {
      await WalletService.instance.payFromWallet(
        userId: _advertiserAccount!.id,
        amount: widget.amount,
        entityType: widget.entityType,
        entityId: widget.entityId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الدفع بنجاح من رصيد المحفظة وتفعيل الإعلان!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر الدفع من المحفظة: $e')),
      );
    } finally {
      if (mounted) setState(() => _walletPaying = false);
    }
  }

  Future<void> _submit() async {
    setState(() => saving = true);
    try {
      await CommercialService.instance.submitPayment(
        entityType: widget.entityType,
        entityId: widget.entityId,
        amount: widget.amount,
        method: method,
        note: note.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم تسجيل طلب الدفع، بانتظار تأكيد الإدارة',
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر تسجيل الدفع: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  Widget _walletPaymentCard() {
    if (_accountLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_advertiserAccount == null) {
      return const SizedBox.shrink();
    }

    final hasEnough = _advertiserAccount!.balance >= widget.amount;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.account_balance_wallet_rounded, color: Colors.teal, size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'الدفع من رصيد المحفظة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'رصيدك الحالي في المحفظة: ${_advertiserAccount!.balance.toStringAsFixed(0)} د.ع',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 14),
            hasEnough
                ? FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: _walletPaying ? null : _payFromWallet,
              icon: _walletPaying
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.check_circle_rounded),
              label: Text(_walletPaying ? 'جارٍ الخصم والدفع...' : 'إتمام الدفع فوراً من المحفظة'),
            )
                : OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => WalletScreen(account: _advertiserAccount!)),
                ).then((_) => _loadAdvertiserAccount());
              },
              icon: const Icon(Icons.add_card_rounded),
              label: const Text('رصيد المحفظة غير كافٍ - شحن المحفظة'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدفع والفاتورة'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.receipt_long,
                    size: 55,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'المبلغ المعتمد',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${widget.amount.toStringAsFixed(0)} د.ع',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          _walletPaymentCard(),

          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 8),

          const Text(
            'طرق الدفع اليدوية الحالية',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: method,
            items: const [
              DropdownMenuItem(
                value: 'اتفاق مع الإدارة',
                child: Text('اتفاق مع الإدارة'),
              ),
              DropdownMenuItem(
                value: 'تحويل مصرفي',
                child: Text('تحويل مصرفي'),
              ),
              DropdownMenuItem(
                value: 'طريقة أخرى',
                child: Text('طريقة أخرى'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                method = value ?? method;
              });
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: note,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText:
              'ملاحظات أو رقم التحويل',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed:
            saving ? null : _submit,
            icon: const Icon(Icons.send),
            label: Text(
              saving
                  ? 'جارٍ التسجيل...'
                  : 'تأكيد إرسال الدفع اليدوي',
            ),
          ),
        ],
      ),
    );
  }
}
