import 'package:flutter/material.dart';

import '../../services/commercial_conversation_service.dart';
import '../commercial_conversation_screen.dart';

class CommercialConversationsScreen extends StatelessWidget {
  const CommercialConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('محادثات المعلنين'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream:
        CommercialConversationService.instance.allConversationsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('تعذر تحميل المحادثات: ${snapshot.error}'),
            );
          }

          final items = snapshot.data ?? const <Map<String, dynamic>>[];
          if (items.isEmpty) {
            return const Center(child: Text('لا توجد محادثات حالياً'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: items.length,
            itemBuilder: (context, index) => _card(context, items[index]),
          );
        },
      ),
    );
  }

  Widget _card(BuildContext context, Map<String, dynamic> item) {
    final unread =
        int.tryParse(item['adminUnreadCount']?.toString() ?? '') ?? 0;
    final entityType = item['entityType']?.toString() ?? 'account';
    final typeLabel = switch (entityType) {
      'ad' => 'إعلان',
      'service' => 'خدمة',
      _ => 'حساب معلن',
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Badge(
          isLabelVisible: unread > 0,
          label: Text(unread > 99 ? '99+' : '$unread'),
          child: CircleAvatar(
            child: Icon(
              entityType == 'ad'
                  ? Icons.campaign_outlined
                  : Icons.forum_outlined,
            ),
          ),
        ),
        title: Text(
          item['title']?.toString() ?? typeLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: unread > 0 ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${item['ownerName']?.toString().isNotEmpty == true ? item['ownerName'] : 'صاحب الإعلان'}\n'
              '${item['lastMessage']?.toString().isNotEmpty == true ? item['lastMessage'] : 'لا توجد رسائل بعد'}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'حذف المحادثة',
              color: Colors.red.shade700,
              onPressed: () => _deleteConversation(context, item),
              icon: const Icon(Icons.delete_outline_rounded),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CommercialConversationScreen(
              entityType: entityType,
              entityId: item['entityId']?.toString() ?? '',
              ownerUid: item['ownerUid']?.toString() ?? '',
              title: item['title']?.toString() ?? typeLabel,
              ownerName: item['ownerName']?.toString() ?? '',
              ownerPhone: item['ownerPhone']?.toString() ?? '',
              ownerWhatsapp: item['ownerWhatsapp']?.toString() ?? '',
              isAdmin: true,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteConversation(
      BuildContext context,
      Map<String, dynamic> item,
      ) async {
    final entityType = item['entityType']?.toString() ?? 'account';
    final entityId = item['entityId']?.toString() ?? '';
    final title = item['title']?.toString() ?? 'هذه المحادثة';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
        title: const Text('حذف المحادثة'),
        content: Text(
          'سيتم حذف محادثة «$title» وجميع الرسائل الموجودة داخلها نهائياً. هل تريد المتابعة؟',
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
      await CommercialConversationService.instance.deleteConversation(
        entityType: entityType,
        entityId: entityId,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف المحادثة')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر حذف المحادثة: $error')),
      );
    }
  }
}
