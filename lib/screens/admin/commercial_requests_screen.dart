
import 'package:flutter/material.dart';

import '../../services/commercial_payment_settings_service.dart';
import '../../services/commercial_service.dart';
import '../commercial_conversation_screen.dart';

class CommercialRequestsScreen extends StatefulWidget {
  const CommercialRequestsScreen({super.key});

  @override
  State<CommercialRequestsScreen> createState() =>
      _CommercialRequestsScreenState();
}

class _CommercialRequestsScreenState
    extends State<CommercialRequestsScreen> {
  bool loading = true;

  List<Map<String, dynamic>> requests = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;

    setState(() {
      loading = true;
    });

    try {
      final result =
      await CommercialService.instance.getRequests();

      final visibleRequests = result.where((request) {
        final status = request['status']?.toString() ?? 'pending';
        return status == 'pending' || status == 'extension_pending';
      }).toList();

      if (!mounted) return;

      setState(() {
        requests = visibleRequests;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر تحميل الطلبات: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إدارة الإعلانات والخدمات',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: loading ? null : _load,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (requests.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: Text(
                    'لا توجد طلبات تجارية',
                  ),
                ),
              ),
            ...requests.map(_requestCard),
          ],
        ),
      ),
    );
  }

  Widget _requestCard(
      Map<String, dynamic> request,
      ) {
    final isAd =
        request['entityType']?.toString() ==
            'ad';

    final type =
    isAd ? 'إعلان' : 'خدمة';

    final status =
        request['status']?.toString() ??
            'pending';

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            isAd
                ? Icons.campaign
                : Icons.miscellaneous_services,
          ),
        ),
        title: Text(
          request['title']?.toString() ??
              type,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '$type\n'
              'الحالة: ${_status(status)}\n'
              'المعلن: ${request['ownerName']?.toString().isNotEmpty == true ? request['ownerName'] : request['ownerUid'] ?? ''}'
              '${request['ownerPhone']?.toString().isNotEmpty == true ? '\nالهاتف: ${request['ownerPhone']}' : ''}',
        ),
        isThreeLine: true,
        onTap: isAd
            ? () => _openConversation(request)
            : null,
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'approve':
                await _approve(request);
                break;

              case 'reject':
                await _reject(request);
                break;

              case 'stop':
                await _stop(request);
                break;

              case 'notify':
                await _notify(request);
                break;
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem<String>(
              value: 'approve',
              child: Text(
                'قبول وتحديد السعر',
              ),
            ),
            PopupMenuItem<String>(
              value: 'reject',
              child: Text(
                'رفض',
              ),
            ),
            PopupMenuItem<String>(
              value: 'stop',
              child: Text(
                'إيقاف النشر',
              ),
            ),
            PopupMenuItem<String>(
              value: 'notify',
              child: Text(
                'إرسال إعلان عبر الإشعارات',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openConversation(Map<String, dynamic> request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommercialConversationScreen(
          entityType: request['entityType']?.toString() ?? 'ad',
          entityId: request['entityId']?.toString() ?? '',
          ownerUid: request['ownerUid']?.toString() ?? '',
          title: request['title']?.toString() ?? 'إعلان',
          ownerName: request['ownerName']?.toString() ?? '',
          ownerPhone: request['ownerPhone']?.toString() ?? '',
          ownerWhatsapp: request['ownerWhatsapp']?.toString() ?? '',
          isAdmin: true,
        ),
      ),
    );
  }

  String _status(String value) {
    switch (value) {
      case 'pending':
        return 'قيد المراجعة';

      case 'approved':
      case 'approved_pending_payment':
        return 'مقبول بانتظار الدفع';

      case 'rejected':
        return 'مرفوض';

      case 'published':
        return 'منشور';

      case 'stopped':
        return 'متوقف';

      case 'extension_pending':
        return 'طلب تمديد';

      default:
        return value;
    }
  }

  Future<void> _approve(
      Map<String, dynamic> request,
      ) async {
    final start =
    DateTime.now();

    final requestedEnd =
    DateTime.tryParse(
      request['requestedEndAt']
          ?.toString() ??
          '',
    );

    final duration =
        int.tryParse(
          request['durationDays']
              ?.toString() ??
              '',
        ) ??
            7;

    CommercialPaymentSettings settings;

    try {
      settings = await CommercialPaymentSettingsService
          .instance
          .getSettings();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر قراءة سعر اليوم: $e',
          ),
        ),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    final int validDuration =
    duration > 0 ? duration : 1;

    final double pricePerDay =
    settings.pricePerDay.toDouble();

    final double totalPrice =
        validDuration * pricePerDay;

    final end =
        requestedEnd ??
            start.add(
              Duration(
                days: validDuration,
              ),
            );

    final result =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'اعتماد الطلب',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _approvalPriceRow(
                'عدد الأيام',
                '$validDuration يوم',
              ),
              const SizedBox(height: 10),
              _approvalPriceRow(
                'سعر اليوم الواحد',
                '${pricePerDay.toStringAsFixed(0)} د.ع',
              ),
              const Divider(height: 24),
              _approvalPriceRow(
                'المبلغ الإجمالي',
                '${totalPrice.toStringAsFixed(0)} د.ع',
                highlighted: true,
              ),
              const SizedBox(height: 12),
              const Text(
                'تم احتساب المبلغ تلقائياً من إعدادات سعر اليوم.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'إلغاء',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'اعتماد',
              ),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return;
    }

    if (!mounted) {
      return;
    }

    try {
      await CommercialService.instance
          .approveRequest(
        request: request,
        price: totalPrice,
        startAt: start,
        endAt: end,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'تم قبول الطلب بنجاح',
          ),
        ),
      );

      await _load();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'تعذر قبول الطلب: $e',
          ),
        ),
      );
    }
  }

  Widget _approvalPriceRow(
      String label,
      String value, {
        bool highlighted = false,
      }) {
    return Row(
      children: [
        Expanded(
          child: Text(label),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: highlighted ? 18 : 15,
            color: highlighted
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
        ),
      ],
    );
  }

  Future<void> _reject(
      Map<String, dynamic> request,
      ) async {
    String reasonText = '';

    final value =
    await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'سبب الرفض',
          ),
          content: TextField(
            autofocus: true,
            maxLines: 3,
            decoration:
            const InputDecoration(
              border:
              OutlineInputBorder(),
              hintText:
              'اكتب سبب الرفض',
            ),
            onChanged: (value) {
              reasonText =
                  value.trim();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child: const Text(
                'إلغاء',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (reasonText.isEmpty) {
                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'اكتب سبب الرفض أولاً',
                      ),
                    ),
                  );

                  return;
                }

                Navigator.of(
                  dialogContext,
                ).pop(reasonText);
              },
              child: const Text(
                'رفض',
              ),
            ),
          ],
        );
      },
    );

    if (value == null ||
        value.isEmpty) {
      return;
    }

    if (!mounted) {
      return;
    }

    try {
      await CommercialService.instance
          .rejectRequest(
        request: request,
        reason: value,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'تم رفض الطلب',
          ),
        ),
      );

      await _load();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'تعذر رفض الطلب: $e',
          ),
        ),
      );
    }
  }

  Future<void> _stop(
      Map<String, dynamic> request,
      ) async {
    final entityType =
        request['entityType']
            ?.toString() ??
            'ad';

    final entityId =
        request['entityId']
            ?.toString() ??
            '';

    if (entityId.isEmpty) {
      return;
    }

    try {
      await CommercialService.instance
          .stopPublication(
        entityType: entityType,
        entityId: entityId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'تم إيقاف النشر',
          ),
        ),
      );

      await _load();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'تعذر إيقاف النشر: $e',
          ),
        ),
      );
    }
  }

  Future<void> _notify(
      Map<String, dynamic> request,
      ) async {
    final entityType =
        request['entityType']
            ?.toString() ??
            'ad';

    final entityId =
        request['entityId']
            ?.toString() ??
            '';

    final title =
        request['title']
            ?.toString() ??
            'إعلان جديد';

    if (entityId.isEmpty) {
      return;
    }

    try {
      await CommercialService.instance
          .sendCommercialNotification(
        title: title,
        message:
        'إعلان تجاري جديد متاح الآن داخل التطبيق.',
        entityType: entityType,
        entityId: entityId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'تم إرسال الإشعار',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'تعذر إرسال الإشعار: $e',
          ),
        ),
      );
    }
  }
}
