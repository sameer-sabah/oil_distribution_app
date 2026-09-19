import 'package:flutter/material.dart';

import '../models/advertiser_account.dart';
import '../services/advertiser_account_service.dart';
import 'advertiser_auth_screen.dart';
import 'commercial_conversation_screen.dart';
import 'wallet_screen.dart';

class AdvertiserAccountScreen extends StatefulWidget {
  const AdvertiserAccountScreen({super.key});

  @override
  State<AdvertiserAccountScreen> createState() =>
      _AdvertiserAccountScreenState();
}

class _AdvertiserAccountScreenState extends State<AdvertiserAccountScreen> {
  late Future<AdvertiserAccount?> _accountFuture;

  @override
  void initState() {
    super.initState();
    _accountFuture =
        AdvertiserAccountService.instance.getCurrentAccount();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {
      _accountFuture =
          AdvertiserAccountService.instance.getCurrentAccount();
    });
  }

  Future<void> _logout() async {
    await AdvertiserAccountService.instance.logout();
    _refresh();
  }

  Future<void> _edit(AdvertiserAccount account) async {
    final fullName = TextEditingController(text: account.fullName);
    final business = TextEditingController(text: account.businessName);
    final phone = TextEditingController(text: account.phone);
    final whatsapp = TextEditingController(text: account.whatsapp);
    final masterCard = TextEditingController(text: account.masterCardNumber);
    final formKey = GlobalKey<FormState>();

    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تعديل بيانات المعلن'),
        content: SizedBox(
          width: 440,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField(fullName, 'الاسم الكامل', required: true),
                  _dialogField(business, 'اسم الشركة أو المحل'),
                  _dialogField(
                    phone,
                    'رقم الهاتف',
                    required: true,
                    keyboardType: TextInputType.phone,
                  ),
                  _dialogField(
                    whatsapp,
                    'رقم واتساب',
                    required: true,
                    keyboardType: TextInputType.phone,
                  ),
                  _dialogField(
                    masterCard,
                    'رقم الماستر / حساب المحفظة',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (save != true) {
      fullName.dispose();
      business.dispose();
      phone.dispose();
      whatsapp.dispose();
      masterCard.dispose();
      return;
    }

    try {
      await AdvertiserAccountService.instance.updateProfile(
        fullName: fullName.text,
        businessName: business.text,
        phone: phone.text,
        whatsapp: whatsapp.text,
        masterCardNumber: masterCard.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث بيانات الحساب')),
      );
      _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر تحديث الحساب: $error')),
      );
    } finally {
      fullName.dispose();
      business.dispose();
      phone.dispose();
      whatsapp.dispose();
      masterCard.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdvertiserAccount?>(
      future: _accountFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final account = snapshot.data;
        if (account == null) {
          return AdvertiserAuthScreen(onAuthenticated: _refresh);
        }

        return _accountScaffold(account);
      },
    );
  }

  Widget _accountScaffold(AdvertiserAccount account) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة المعلن'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'تعديل البيانات',
            onPressed: () => _edit(account),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                    child: const Icon(Icons.storefront_rounded, size: 42),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    account.fullName,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (account.businessName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(account.businessName),
                  ],
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: account.isActive
                          ? Colors.green.withValues(alpha: .12)
                          : Colors.red.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      account.isActive ? 'الحساب فعال' : 'الحساب موقوف',
                      style: TextStyle(
                        color: account.isActive
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 28),
                  _info(Icons.email_outlined, account.email),
                  _info(Icons.phone_outlined, account.phone),
                  _info(Icons.chat_outlined, account.whatsapp),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _action(
            icon: Icons.add_business_rounded,
            title: 'تقديم إعلان جديد',
            subtitle: 'إنشاء إعلان وإرساله إلى الإدارة',
            onTap: account.isActive
                ? () => Navigator.pushNamed(context, '/commercialAdForm')
                : null,
          ),
          _action(
            icon: Icons.account_balance_wallet_rounded,
            title: 'محفظتي',
            subtitle: 'رصيد المحفظة وشحن الرصيد وحركات الحساب',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WalletScreen(account: account),
              ),
            ),
          ),
          _action(
            icon: Icons.campaign_rounded,
            title: 'إعلاناتي',
            subtitle: 'متابعة الموافقة والسعر وحالة النشر',
            onTap: () => Navigator.pushNamed(context, '/myCommercialAds'),
          ),
          _action(
            icon: Icons.receipt_long_rounded,
            title: 'المدفوعات والفواتير',
            subtitle: 'متابعة المبالغ وتأكيدات الدفع',
            onTap: () => Navigator.pushNamed(
              context,
              '/myCommercialPayments',
            ),
          ),
          _action(
            icon: Icons.support_agent_rounded,
            title: 'التواصل مع مدير النظام',
            subtitle: 'محادثة مباشرة بخصوص الموافقات والأمور المالية',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CommercialConversationScreen(
                  entityType: 'account',
                  entityId: account.id,
                  ownerUid: account.id,
                  title: 'المعلن - ${account.fullName}',
                  ownerName: account.fullName,
                  ownerPhone: account.phone,
                  ownerWhatsapp: account.whatsapp,
                  isAdmin: false,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('تسجيل الخروج من حساب المعلن'),
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 9),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _action({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }

  Widget _dialogField(
      TextEditingController controller,
      String label, {
        bool required = false,
        TextInputType? keyboardType,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: required
            ? (value) => (value?.trim().isEmpty ?? true)
            ? 'هذا الحقل مطلوب'
            : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
