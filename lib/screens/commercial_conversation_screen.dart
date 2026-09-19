import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/commercial_message.dart';
import '../services/commercial_conversation_service.dart';
import '../utils/iraqi_phone_number.dart';

class CommercialConversationScreen extends StatefulWidget {
  final String entityType;
  final String entityId;
  final String ownerUid;
  final String title;
  final String ownerName;
  final String ownerPhone;
  final String ownerWhatsapp;
  final bool isAdmin;

  const CommercialConversationScreen({
    super.key,
    required this.entityType,
    required this.entityId,
    required this.ownerUid,
    required this.title,
    required this.ownerName,
    required this.ownerPhone,
    required this.ownerWhatsapp,
    required this.isAdmin,
  });

  @override
  State<CommercialConversationScreen> createState() =>
      _CommercialConversationScreenState();
}

class _CommercialConversationScreenState
    extends State<CommercialConversationScreen> {
  final _message = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;
  bool _markingRead = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_prepareConversation);
  }

  @override
  void dispose() {
    _message.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _prepareConversation() async {
    try {
      await CommercialConversationService.instance.ensureConversation(
        entityType: widget.entityType,
        entityId: widget.entityId,
        ownerUid: widget.ownerUid,
        title: widget.title,
        ownerName: widget.ownerName,
        ownerPhone: widget.ownerPhone,
        ownerWhatsapp: widget.ownerWhatsapp,
      );
      await CommercialConversationService.instance.markRead(
        entityType: widget.entityType,
        entityId: widget.entityId,
        isAdmin: widget.isAdmin,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر فتح المحادثة: $error')),
      );
    }
  }

  Future<void> _send() async {
    final text = _message.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      await CommercialConversationService.instance.sendMessage(
        entityType: widget.entityType,
        entityId: widget.entityId,
        ownerUid: widget.ownerUid,
        title: widget.title,
        ownerName: widget.ownerName,
        ownerPhone: widget.ownerPhone,
        ownerWhatsapp: widget.ownerWhatsapp,
        text: text,
        isAdmin: widget.isAdmin,
      );
      _message.clear();
      _scrollToEnd();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر إرسال الرسالة: $error')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _markReadIfNeeded(List<CommercialMessage> messages) {
    if (_markingRead) return;
    final hasUnread = messages.any((message) {
      if (widget.isAdmin) {
        return !message.isFromAdmin && !message.readByAdmin;
      }
      return message.isFromAdmin && !message.readByOwner;
    });
    if (!hasUnread) return;

    _markingRead = true;
    Future.microtask(() async {
      try {
        await CommercialConversationService.instance.markRead(
          entityType: widget.entityType,
          entityId: widget.entityId,
          isAdmin: widget.isAdmin,
        );
      } catch (error) {
        debugPrint('تعذر تحديث حالة قراءة المحادثة: $error');
      } finally {
        _markingRead = false;
      }
    });
  }

  Future<void> _call() async {
    final phone = widget.ownerPhone.trim();
    if (phone.isEmpty) return;
    final opened = await launchUrl(Uri.parse('tel:$phone'));
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح الاتصال')),
      );
    }
  }

  Future<void> _openWhatsapp() async {
    final number = IraqiPhoneNumber.forWhatsApp(widget.ownerWhatsapp);
    if (number == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('رقم واتساب غير صحيح. اكتب رقماً عراقياً يبدأ بـ 07'),
        ),
      );
      return;
    }

    final uri = Uri.https(
      'wa.me',
      '/$number',
      <String, String>{
        'text': 'مرحباً، بخصوص ${widget.title}',
      },
    );
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح واتساب')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.isAdmin
                  ? (widget.ownerName.isEmpty
                  ? 'صاحب الإعلان'
                  : widget.ownerName)
                  : 'التواصل مع مدير النظام',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: widget.isAdmin
            ? [
          if (widget.ownerPhone.isNotEmpty)
            IconButton(
              tooltip: 'اتصال',
              onPressed: _call,
              icon: const Icon(Icons.phone_outlined),
            ),
          if (widget.ownerWhatsapp.isNotEmpty)
            IconButton(
              tooltip: 'واتساب',
              onPressed: _openWhatsapp,
              icon: const Icon(Icons.chat_outlined),
            ),
        ]
            : null,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: const Text(
              'هذه المحادثة مخصصة للموافقة والسعر والدفع. لا ترسل كلمة المرور أو بيانات البطاقة.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<CommercialMessage>>(
              stream: CommercialConversationService.instance.messagesStream(
                entityType: widget.entityType,
                entityId: widget.entityId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('تعذر تحميل الرسائل: ${snapshot.error}'),
                  );
                }

                final messages = snapshot.data ?? const <CommercialMessage>[];
                if (messages.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'ابدأ المحادثة الآن. سيظهر الرد هنا مباشرة.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                _scrollToEnd();
                _markReadIfNeeded(messages);

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(14),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final mine = widget.isAdmin
                        ? message.isFromAdmin
                        : !message.isFromAdmin;
                    return _bubble(message, mine);
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _message,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'اكتب رسالتك...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(CommercialMessage message, bool mine) {
    final parsed = DateTime.tryParse(message.createdAt)?.toLocal();
    final time = parsed == null
        ? ''
        : '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: mine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 330),
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 7),
        decoration: BoxDecoration(
          color: mine
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.senderName.isEmpty
                  ? (message.isFromAdmin ? 'مدير النظام' : 'المعلن')
                  : message.senderName,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 3),
            Text(message.text, style: const TextStyle(height: 1.35)),
            const SizedBox(height: 3),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                time,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
