import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/advertiser_account.dart';
import '../../services/advertiser_account_service.dart';
import '../../utils/iraqi_phone_number.dart';
import '../commercial_conversation_screen.dart';

class AdvertiserAccountsScreen extends StatelessWidget {
  const AdvertiserAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابات المعلنين'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<AdvertiserAccount>>(
        stream: AdvertiserAccountService.instance.allAccountsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('تعذر تحميل حسابات المعلنين: ${snapshot.error}'),
            );
          }

          final accounts = snapshot.data ?? const <AdvertiserAccount>[];
          if (accounts.isEmpty) {
            return const Center(child: Text('لا توجد حسابات معلنين حالياً'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: accounts.length,
            itemBuilder: (context, index) => _card(context, accounts[index]),
          );
        },
      ),
    );
  }

  Widget _card(BuildContext context, AdvertiserAccount account) {
    return Card(
      margin: const EdgeInsets.only(bottom: 11),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                child: Text(
                  account.fullName.isEmpty ? 'م' : account.fullName[0],
                ),
              ),
              title: Text(
                account.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                [
                  if (account.businessName.isNotEmpty) account.businessName,
                  account.phone,
                  account.email,
                ].where((value) => value.isNotEmpty).join('\n'),
              ),
              trailing: Chip(
                label: Text(account.isActive ? 'فعال' : 'موقوف'),
                backgroundColor: account.isActive
                    ? Colors.green.withValues(alpha: .12)
                    : Colors.red.withValues(alpha: .12),
              ),
            ),
            const Divider(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommercialConversationScreen(
                        entityType: 'account',
                        entityId: account.id,
                        ownerUid: account.id,
                        title: 'حساب المعلن - ${account.fullName}',
                        ownerName: account.fullName,
                        ownerPhone: account.phone,
                        ownerWhatsapp: account.whatsapp,
                        isAdmin: true,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.forum_outlined),
                  label: const Text('محادثة'),
                ),
                if (account.whatsapp.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => _whatsapp(context, account),
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('واتساب'),
                  ),
                OutlinedButton.icon(
                  onPressed: () => _toggleStatus(context, account),
                  icon: Icon(
                    account.isActive
                        ? Icons.block_outlined
                        : Icons.check_circle_outline,
                  ),
                  label: Text(account.isActive ? 'إيقاف' : 'تفعيل'),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                  ),
                  onPressed: () => _deleteAccount(context, account),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('حذف الحساب'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _whatsapp(
      BuildContext context,
      AdvertiserAccount account,
      ) async {
    final number = IraqiPhoneNumber.forWhatsApp(account.whatsapp);
    if (number == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('رقم واتساب غير صحيح. اكتب رقماً عراقياً يبدأ بـ 07'),
        ),
      );
      return;
    }

    final opened = await launchUrl(
      Uri.https(
        'wa.me',
        '/$number',
        <String, String>{
          'text':
          'مرحباً ${account.fullName}، معك مدير النظام بخصوص حساب الإعلانات.',
        },
      ),
      mode: LaunchMode.externalApplication,
    );

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح تطبيق واتساب')),
      );
    }
  }

  Future<void> _toggleStatus(
      BuildContext context,
      AdvertiserAccount account,
      ) async {
    final next = account.isActive ? 'suspended' : 'active';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(account.isActive ? 'إيقاف الحساب' : 'تفعيل الحساب'),
        content: Text(
          account.isActive
              ? 'هل تريد إيقاف حساب ${account.fullName}؟'
              : 'هل تريد إعادة تفعيل حساب ${account.fullName}؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(account.isActive ? 'إيقاف' : 'تفعيل'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await AdvertiserAccountService.instance.setAccountStatus(
        account.id,
        next,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(account.isActive ? 'تم إيقاف الحساب' : 'تم تفعيل الحساب'),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر تغيير حالة الحساب: $error')),
      );
    }
  }

  Future<void> _deleteAccount(
      BuildContext context,
      AdvertiserAccount account,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
        title: const Text('حذف حساب المعلن'),
        content: Text(
          'سيتم حذف بيانات حساب ${account.fullName} وجميع محادثاته نهائياً.\n\n'
              'ستتوقف جميع إعلاناته وتختفي من شاشات العرض، بينما تبقى بيانات الإعلانات والمدفوعات محفوظة كسجل إداري ومالي. هل تريد المتابعة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.delete_forever_rounded),
            label: const Text('حذف نهائي'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await AdvertiserAccountService.instance.deleteAccountProfile(account.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 7),
          content: Text(
            'تم حذف بيانات الحساب ومحادثاته وإيقاف إعلاناته. حذف تسجيل الدخول نهائياً يتم من Firebase Authentication.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر حذف الحساب: $error')),
      );
    }
  }
}
