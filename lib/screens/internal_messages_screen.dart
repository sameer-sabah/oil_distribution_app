import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../services/internal_message_service.dart';

class InternalMessagesScreen extends StatefulWidget {
  const InternalMessagesScreen({
    super.key,
  });

  @override
  State<InternalMessagesScreen> createState() =>
      _InternalMessagesScreenState();
}

class _InternalMessagesScreenState
    extends State<InternalMessagesScreen>
    with SingleTickerProviderStateMixin {
  final InternalMessageService messageService =
      InternalMessageService.instance;

  List<Map<String, dynamic>> recipients = [];

  bool loadingRecipients = true;
  bool sending = false;
  bool deleting = false;
  bool selectionMode = false;

  final Set<String> selectedMessageIds = <String>{};
  List<String> incomingVisibleMessageIds = <String>[];
  List<String> outgoingVisibleMessageIds = <String>[];

  late final TabController tabController;
  late final Stream<DatabaseEvent> incomingMessagesStream;
  late final Stream<DatabaseEvent> outgoingMessagesStream;
  int activeFolderIndex = 0;

  List<String> get visibleMessageIds =>
      activeFolderIndex == 0
          ? incomingVisibleMessageIds
          : outgoingVisibleMessageIds;

  bool get showingOutgoingFolder =>
      activeFolderIndex == 1;

  final TextEditingController subjectController =
  TextEditingController();

  final TextEditingController messageController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 2,
      vsync: this,
    );
    incomingMessagesStream =
        messageService.messagesStream();
    outgoingMessagesStream =
        messageService.sentMessagesStream();
    tabController.addListener(_handleFolderChanged);
    _loadRecipients();
  }

  @override
  void dispose() {
    tabController.removeListener(_handleFolderChanged);
    tabController.dispose();
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }

  void _handleFolderChanged() {
    if (activeFolderIndex == tabController.index) {
      return;
    }

    setState(() {
      activeFolderIndex = tabController.index;
      selectionMode = false;
      selectedMessageIds.clear();
    });
  }

  // =====================================================
  // جلب المستلمين
  // =====================================================

  Future<void> _loadRecipients() async {
    try {
      final result =
      await messageService.getAvailableRecipients();

      if (!mounted) return;

      setState(() {
        recipients = result;
        loadingRecipients = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingRecipients = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر جلب المستخدمين: $e',
          ),
        ),
      );
    }
  }

  // =====================================================
  // تحديد الرسائل وحذفها
  // =====================================================

  void _startSelection([String? messageId]) {
    setState(() {
      selectionMode = true;

      if (messageId != null && messageId.isNotEmpty) {
        selectedMessageIds.add(messageId);
      }
    });
  }

  void _toggleMessageSelection(String messageId) {
    if (messageId.isEmpty || deleting) {
      return;
    }

    setState(() {
      if (!selectionMode) {
        selectionMode = true;
      }

      if (!selectedMessageIds.add(messageId)) {
        selectedMessageIds.remove(messageId);
      }
    });
  }

  void _closeSelection() {
    if (deleting) {
      return;
    }

    setState(() {
      selectionMode = false;
      selectedMessageIds.clear();
    });
  }

  void _toggleSelectAll() {
    if (deleting || visibleMessageIds.isEmpty) {
      return;
    }

    final Set<String> allIds = visibleMessageIds.toSet();
    final bool allSelected =
    allIds.every(selectedMessageIds.contains);

    setState(() {
      if (allSelected) {
        selectedMessageIds.removeAll(allIds);
      } else {
        selectedMessageIds.addAll(allIds);
      }
    });
  }

  Future<bool> _confirmDelete({
    required String title,
    required String message,
  }) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              icon: const Icon(Icons.delete_forever),
              label: const Text('حذف'),
            ),
          ],
        );
      },
    );

    return confirmed == true;
  }

  Future<void> _deleteMessages({
    required Iterable<String> messageIds,
    required String confirmationTitle,
    required String confirmationMessage,
    required String successMessage,
  }) async {
    if (deleting) {
      return;
    }

    final List<String> ids = messageIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (ids.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد رسائل محددة'),
        ),
      );
      return;
    }

    final bool confirmed = await _confirmDelete(
      title: confirmationTitle,
      message: confirmationMessage,
    );

    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      deleting = true;
    });

    try {
      await messageService.deleteMessages(ids);

      if (!mounted) {
        return;
      }

      setState(() {
        deleting = false;
        selectionMode = false;
        selectedMessageIds.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        deleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر حذف الرسائل: $e'),
        ),
      );
    }
  }

  Future<void> _deleteOneMessage(
      String messageId, {
        required bool outgoing,
      }) {
    return _deleteMessages(
      messageIds: [messageId],
      confirmationTitle: 'حذف الرسالة',
      confirmationMessage: outgoing
          ? 'هل أنت متأكد من حذف هذه الرسالة الصادرة نهائيًا؟ ستختفي أيضًا من الرسائل الواردة عند المستلم.'
          : 'هل أنت متأكد من حذف هذه الرسالة الواردة نهائيًا؟',
      successMessage: 'تم حذف الرسالة',
    );
  }

  Future<void> _deleteSelectedMessages() {
    final int count = selectedMessageIds.length;
    final String folderName = showingOutgoingFolder
        ? 'الصادرة'
        : 'الواردة';

    return _deleteMessages(
      messageIds: selectedMessageIds.toList(),
      confirmationTitle: 'حذف الرسائل المحددة',
      confirmationMessage: showingOutgoingFolder
          ? 'هل أنت متأكد من حذف $count رسالة صادرة نهائيًا؟ ستختفي أيضًا من الرسائل الواردة عند المستلمين.'
          : 'هل أنت متأكد من حذف $count رسالة واردة نهائيًا؟',
      successMessage:
      'تم حذف الرسائل $folderName المحددة',
    );
  }

  Future<void> _deleteAllMessages() {
    final int count = visibleMessageIds.length;
    final String folderName = showingOutgoingFolder
        ? 'الصادرة'
        : 'الواردة';

    return _deleteMessages(
      messageIds: visibleMessageIds,
      confirmationTitle: 'حذف كل الرسائل $folderName',
      confirmationMessage: showingOutgoingFolder
          ? 'سيتم حذف جميع الرسائل الصادرة وعددها $count من قاعدة البيانات ومن وارد المستلمين. هل تريد المتابعة؟'
          : 'سيتم حذف جميع الرسائل الواردة وعددها $count من قاعدة البيانات. هل تريد المتابعة؟',
      successMessage: 'تم حذف جميع الرسائل $folderName',
    );
  }

  // =====================================================
  // فتح نافذة إرسال رسالة
  // =====================================================

  Future<void> _openSendMessageDialog(
      Map<String, dynamic> recipient,
      ) async {
    subjectController.clear();
    messageController.clear();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'إرسال رسالة إلى ${recipient['fullName'] ?? ''}',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: subjectController,
                      enabled: !sending,
                      decoration: const InputDecoration(
                        labelText: 'الموضوع',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    TextField(
                      controller: messageController,
                      enabled: !sending,
                      maxLines: 6,
                      maxLength: 5000,
                      decoration: const InputDecoration(
                        labelText: 'نص الرسالة',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: sending
                      ? null
                      : () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'إلغاء',
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: sending
                      ? null
                      : () async {
                    final String text =
                    messageController.text.trim();

                    if (text.isEmpty) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'اكتب نص الرسالة أولاً',
                          ),
                        ),
                      );
                      return;
                    }

                    setDialogState(() {
                      sending = true;
                    });

                    try {
                      await messageService.sendMessage(
                        recipient: recipient,
                        subject:
                        subjectController.text.trim(),
                        message: text,
                      );

                      if (!context.mounted) return;

                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'تم إرسال الرسالة بنجاح',
                          ),
                        ),
                      );
                    } catch (e) {
                      setDialogState(() {
                        sending = false;
                      });

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            'فشل إرسال الرسالة: $e',
                          ),
                        ),
                      );
                    }
                  },
                  icon: sending
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(
                    Icons.send,
                  ),
                  label: Text(
                    sending
                        ? 'جارٍ الإرسال...'
                        : 'إرسال',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    sending = false;
  }

  // =====================================================
  // بناء بطاقة المستلم
  // =====================================================

  Widget _recipientCard(
      Map<String, dynamic> recipient,
      ) {
    final String role =
        recipient['role']?.toString() ?? '';

    String roleName = 'مستخدم';

    if (role == 'admin') {
      roleName = 'مدير النظام';
    } else if (role == 'branchManager') {
      roleName = 'مدير الفرع';
    } else if (role == 'stationManager') {
      roleName = 'مدير المحطة';
    }

    final String fullName =
        recipient['fullName']?.toString() ?? '';

    final String branchName =
        recipient['branchName']?.toString() ?? '';

    final String stationName =
        recipient['stationName']?.toString() ?? '';

    final bool stationRecipient =
        role == 'stationManager';

    final String displayName =
    stationRecipient && stationName.isNotEmpty
        ? stationName
        : fullName;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            role == 'stationManager'
                ? Icons.local_gas_station
                : role == 'branchManager'
                ? Icons.account_tree
                : Icons.admin_panel_settings,
          ),
        ),

        title: Text(
          displayName.isEmpty
              ? 'بدون اسم'
              : displayName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              roleName,
            ),

            if (stationRecipient &&
                stationName.isNotEmpty &&
                fullName.isNotEmpty)
              Text(
                'مدير المحطة: $fullName',
              ),

            if (branchName.isNotEmpty)
              Text(
                'الفرع: $branchName',
              ),

            if (!stationRecipient &&
                stationName.isNotEmpty)
              Text(
                'المحطة: $stationName',
              ),
          ],
        ),

        trailing: IconButton(
          tooltip: 'إرسال رسالة',
          icon: const Icon(
            Icons.send,
          ),
          onPressed: () {
            _openSendMessageDialog(
              recipient,
            );
          },
        ),
      ),
    );
  }

  // =====================================================
  // بناء الرسالة
  // =====================================================

  Widget _messageCard(
      DataSnapshot message, {
        required bool outgoing,
      }) {
    final String messageId =
        message.key ?? '';

    final bool selected =
    selectedMessageIds.contains(messageId);

    final String correspondentName =
        message.child(
          outgoing
              ? 'receiverName'
              : 'senderName',
        )
            .value
            ?.toString() ??
            'غير معروف';

    final String correspondentRole =
        message.child(
          outgoing
              ? 'receiverRole'
              : 'senderRole',
        )
            .value
            ?.toString() ??
            '';

    final String subject =
        message.child('subject')
            .value
            ?.toString() ??
            'بدون موضوع';

    final String text =
        message.child('message')
            .value
            ?.toString() ??
            '';

    final String createdAt =
        message.child('createdAt')
            .value
            ?.toString() ??
            '';

    final bool read =
        message.child('read').value == true;

    final IconData messageIcon = outgoing
        ? Icons.send
        : read
        ? Icons.mail_outline
        : Icons.mark_email_unread;

    String roleName = '';

    if (correspondentRole == 'admin') {
      roleName = 'مدير النظام';
    } else if (correspondentRole == 'branchManager') {
      roleName = 'مدير الفرع';
    } else if (correspondentRole == 'stationManager') {
      roleName = 'مدير المحطة';
    }

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      elevation: read ? 1 : 3,
      color: selected
          ? Theme.of(context)
          .colorScheme
          .primaryContainer
          : null,
      child: InkWell(
        onTap: () async {
          if (selectionMode) {
            _toggleMessageSelection(messageId);
            return;
          }

          if (!outgoing && !read) {
            await messageService
                .markAsRead(messageId);
          }
        },
        onLongPress: deleting
            ? null
            : () {
          _startSelection(messageId);
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (selectionMode)
                    Checkbox(
                      value: selected,
                      onChanged: deleting
                          ? null
                          : (_) {
                        _toggleMessageSelection(
                          messageId,
                        );
                      },
                    )
                  else
                    CircleAvatar(
                      child: Icon(messageIcon),
                    ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          correspondentName,
                          style: const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        if (roleName.isNotEmpty)
                          Text(
                            roleName,
                            style: TextStyle(
                              color:
                              Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),

                  if (!selectionMode && outgoing)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: read
                            ? Colors.green
                            : Colors.orange,
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: Text(
                        read
                            ? 'تمت القراءة'
                            : 'لم تُقرأ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else if (!selectionMode && !read)
                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius:
                        BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: const Text(
                        'جديد',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),

                  if (!selectionMode)
                    IconButton(
                      tooltip: 'حذف الرسالة',
                      onPressed: deleting ||
                          messageId.isEmpty
                          ? null
                          : () {
                        _deleteOneMessage(
                          messageId,
                          outgoing: outgoing,
                        );
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                subject,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius:
                  BorderRadius.circular(10),
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                createdAt,
                style: TextStyle(
                  color:
                  Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // =====================================================
  // قسم إرسال رسالة جديدة
  // =====================================================

  Widget _buildSendSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.edit_note),
            SizedBox(width: 8),
            Text(
              'إرسال رسالة جديدة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (loadingRecipients)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (recipients.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'لا توجد جهات متاحة للمراسلة',
                ),
              ),
            ),
          )
        else
          ...recipients.map(_recipientCard),
        const SizedBox(height: 25),
      ],
    );
  }

  // =====================================================
  // فولدر الرسائل الواردة أو الصادرة
  // =====================================================

  Widget _buildMessageFolder({
    required bool outgoing,
  }) {
    final Stream<DatabaseEvent> stream = outgoing
        ? outgoingMessagesStream
        : incomingMessagesStream;

    return StreamBuilder<DatabaseEvent>(
      key: ValueKey<String>(
        outgoing
            ? 'internal-messages-outgoing-stream'
            : 'internal-messages-incoming-stream',
      ),
      stream: stream,
      builder: (context, snapshot) {
        final bool waiting =
            snapshot.connectionState ==
                ConnectionState.waiting &&
                !snapshot.hasData;

        final List<DataSnapshot> messages =
        <DataSnapshot>[];

        final Object? value =
            snapshot.data?.snapshot.value;

        if (value is Map && snapshot.hasData) {
          messages.addAll(
            snapshot.data!.snapshot.children,
          );
        }

        messages.sort((a, b) {
          final String aDate =
              a.child('createdAt')
                  .value
                  ?.toString() ??
                  '';

          final String bDate =
              b.child('createdAt')
                  .value
                  ?.toString() ??
                  '';

          return bDate.compareTo(aDate);
        });

        final List<String> ids = messages
            .map((message) => message.key ?? '')
            .where((id) => id.isNotEmpty)
            .toList();

        if (outgoing) {
          outgoingVisibleMessageIds = ids;
        } else {
          incomingVisibleMessageIds = ids;
        }

        return RefreshIndicator(
          onRefresh: _loadRecipients,
          child: ListView(
            key: PageStorageKey<String>(
              outgoing
                  ? 'internal-messages-outgoing-list'
                  : 'internal-messages-incoming-list',
            ),
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            children: [
              if (outgoing) _buildSendSection(),
              Row(
                children: [
                  Icon(
                    outgoing
                        ? Icons.outbox
                        : Icons.inbox,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    outgoing
                        ? 'الرسائل الصادرة'
                        : 'الرسائل الواردة',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (snapshot.hasError)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'حدث خطأ:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                )
              else if (waiting)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (messages.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        outgoing
                            ? 'لا توجد رسائل صادرة'
                            : 'لا توجد رسائل واردة',
                      ),
                    ),
                  )
                else
                  ...messages.map(
                        (message) => _messageCard(
                      message,
                      outgoing: outgoing,
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  // =====================================================
  // الصفحة
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final Set<String> visibleIds =
    visibleMessageIds.toSet();

    final bool allVisibleSelected =
        visibleIds.isNotEmpty &&
            visibleIds.every(
              selectedMessageIds.contains,
            );

    final String folderName = showingOutgoingFolder
        ? 'الصادرة'
        : 'الواردة';

    return Scaffold(
      appBar: AppBar(
        leading: selectionMode
            ? IconButton(
          tooltip: 'إلغاء التحديد',
          onPressed: deleting
              ? null
              : _closeSelection,
          icon: const Icon(Icons.close),
        )
            : null,
        title: Text(
          selectionMode
              ? 'تم تحديد ${selectedMessageIds.length}'
              : 'المراسلات الداخلية',
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.inbox),
              text: 'الرسائل الواردة',
            ),
            Tab(
              icon: Icon(Icons.outbox),
              text: 'الرسائل الصادرة',
            ),
          ],
        ),
        actions: [
          if (selectionMode) ...[
            IconButton(
              tooltip: allVisibleSelected
                  ? 'إلغاء تحديد الكل'
                  : 'تحديد الكل',
              onPressed: deleting ||
                  visibleMessageIds.isEmpty
                  ? null
                  : _toggleSelectAll,
              icon: Icon(
                allVisibleSelected
                    ? Icons.deselect
                    : Icons.select_all,
              ),
            ),
            if (deleting)
              const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              )
            else
              IconButton(
                tooltip: 'حذف المحدد',
                onPressed:
                selectedMessageIds.isEmpty
                    ? null
                    : _deleteSelectedMessages,
                icon: const Icon(Icons.delete),
              ),
          ] else
            PopupMenuButton<String>(
              tooltip: 'أوامر الرسائل',
              enabled: !deleting,
              onSelected: (value) {
                if (value == 'select') {
                  if (visibleMessageIds.isEmpty) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'لا توجد رسائل لتحديدها',
                        ),
                      ),
                    );
                    return;
                  }

                  _startSelection();
                } else if (value == 'deleteAll') {
                  _deleteAllMessages();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'select',
                  child: ListTile(
                    leading: Icon(Icons.checklist),
                    title: Text('تحديد الرسائل'),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'deleteAll',
                  enabled: visibleMessageIds.isNotEmpty,
                  child: ListTile(
                    leading: const Icon(
                      Icons.delete_sweep,
                      color: Colors.red,
                    ),
                    title: Text(
                      'حذف كل الرسائل $folderName',
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _buildMessageFolder(
            outgoing: false,
          ),
          _buildMessageFolder(
            outgoing: true,
          ),
        ],
      ),
    );
  }
}
