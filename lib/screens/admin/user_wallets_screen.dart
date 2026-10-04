import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/wallet_model.dart';
import '../../services/wallet_service.dart';
import '../../services/commercial_service.dart';

class UserWalletsScreen extends StatefulWidget {
  const UserWalletsScreen({super.key});

  @override
  State<UserWalletsScreen> createState() => _UserWalletsScreenState();
}

class _UserWalletsScreenState extends State<UserWalletsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  String _filterStatus = 'pending'; // 'pending', 'approved', 'rejected', 'all'
  final _searchController = TextEditingController();
  String _searchQuery = '';

  bool _commercialLoading = true;
  List<Map<String, dynamic>> _commercialRequests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
    _loadCommercialRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCommercialRequests() async {
    try {
      final res = await CommercialService.instance.getRequests();
      if (!mounted) return;
      setState(() {
        _commercialRequests = res;
        _commercialLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _commercialLoading = false;
      });
    }
  }

  Future<void> _reviewWalletRequest(WalletTopUpRequest req, bool approved) async {
    if (!approved) {
      // Direct deletion upon rejection
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('حذف ورفض طلب الشحن'),
          content: Text('هل أنت متأكد من رفض وحذف طلب الشحن للمعلن ${req.userName}?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('رفض وحذف'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      try {
        await WalletService.instance.walletTopUpRequestsRef.child(req.id).remove();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم رفض وحذف طلب الشحن بنجاح')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر الحذف: $e')),
        );
      }
      return;
    }

    final noteController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('موافقة طلب شحن بمبلغ ${req.amount.toStringAsFixed(0)} د.ع'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('المعلن: ${req.userName} (${req.userPhone})'),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'ملاحظة للإدارة / المعلن (اختياري)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('موافقة وإضافة الرصيد'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await WalletService.instance.adminReviewRequest(
        requestId: req.id,
        approved: true,
        adminNote: noteController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت الموافقة وإضافة الرصيد بنجاح')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر إتمام العمليات: $e')),
      );
    }
  }

  Future<void> _approveCommercial(Map<String, dynamic> request) async {
    final durationDays = int.tryParse(request['durationDays']?.toString() ?? '7') ?? 7;
    final pricePerDay = double.tryParse(request['pricePerDay']?.toString() ?? '2000') ?? 2000;
    final calculatedPrice = double.tryParse(request['requestedPrice']?.toString() ?? '') ?? (durationDays * pricePerDay);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('قبول ونشر الإعلان'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('مدة الإعلان: $durationDays أيام'),
            Text('سعر اليوم الواحد: ${pricePerDay.toStringAsFixed(0)} د.ع'),
            const SizedBox(height: 12),
            Text(
              'المبلغ الإجمالي للاستقطاع: ${calculatedPrice.toStringAsFixed(0)} د.ع',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal),
            ),
            const SizedBox(height: 8),
            const Text('سيتم التحقق من رصيد ماستر كارد المعلن واستقطاعه وتحويله لماستر المشرف تلقائياً ونشر الإعلان.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('موافقة واستقطاع ونشر'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await CommercialService.instance.approveRequest(
        request: request,
        price: calculatedPrice,
        startAt: DateTime.now(),
        endAt: DateTime.now().add(Duration(days: durationDays)),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت الموافقة، استقطاع المبلغ، ونشر الإعلان بنجاح')),
      );
      _loadCommercialRequests();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر قبول الطلب: $e')),
      );
    }
  }

  Future<void> _rejectCommercial(Map<String, dynamic> request) async {
    final requestId = request['id']?.toString() ?? '';
    final entityId = request['entityId']?.toString() ?? '';
    final entityType = request['entityType']?.toString() ?? 'ad';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('رفض وحذف الطلب'),
        content: const Text('هل أنت متأكد من رفض وحذف هذا الطلب نهائياً؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('رفض وحذف'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final updates = <String, Object?>{
        'commercialRequests/$requestId': null,
      };
      if (entityId.isNotEmpty) {
        updates['${entityType == 'ad' ? 'commercialAds' : 'commercialServices'}/$entityId'] = null;
      }
      await FirebaseDatabase.instance.ref().update(updates);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم رفض وحذف الطلب بنجاح')));
      _loadCommercialRequests();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر الرفض والحذف: $e')),
      );
    }
  }

  Future<void> _deleteCommercial(Map<String, dynamic> request) async {
    final requestId = request['id']?.toString() ?? '';
    final entityId = request['entityId']?.toString() ?? '';
    final entityType = request['entityType']?.toString() ?? 'ad';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الطلب أو الإعلان'),
        content: const Text('هل أنت متأكد من حذف هذا الطلب والإعلان نهائياً؟'),
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

    if (confirm != true) return;

    try {
      final updates = <String, Object?>{
        'commercialRequests/$requestId': null,
      };
      if (entityId.isNotEmpty) {
        updates['${entityType == 'ad' ? 'commercialAds' : 'commercialServices'}/$entityId'] = null;
      }
      await FirebaseDatabase.instance.ref().update(updates);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف الطلب والإعلان بنجاح')));
      _loadCommercialRequests();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر الحذف: $e')));
    }
  }

  Future<void> _deleteWalletRequest(WalletTopUpRequest req) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف طلب الشحن'),
        content: const Text('هل أنت متأكد من حذف طلب الشحن هذا؟'),
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

    if (confirm != true) return;

    try {
      await WalletService.instance.walletTopUpRequestsRef.child(req.id).remove();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف طلب الشحن بنجاح')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر الحذف: $e')));
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('محافظ المستخدمين وطلبات الشحن والإعلانات'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'طلبات شحن المحافظ', icon: Icon(Icons.account_balance_wallet_rounded)),
            Tab(text: 'طلبات الإعلانات والخدمات', icon: Icon(Icons.campaign_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Wallet Top-Up Requests
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'بحث باسم المستخدم أو الهاتف أو رقم المرجع...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterChip('قيد المراجعة', 'pending'),
                          const SizedBox(width: 8),
                          _filterChip('المقبولة', 'approved'),
                          const SizedBox(width: 8),
                          _filterChip('المرفوضة', 'rejected'),
                          const SizedBox(width: 8),
                          _filterChip('الكل', 'all'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<List<WalletTopUpRequest>>(
                  stream: WalletService.instance.allTopUpRequestsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var requests = snapshot.data ?? [];

                    if (_filterStatus != 'all') {
                      requests = requests.where((r) => r.status == _filterStatus).toList();
                    }

                    if (_searchQuery.isNotEmpty) {
                      requests = requests.where((r) =>
                      r.userName.toLowerCase().contains(_searchQuery) ||
                          r.userPhone.contains(_searchQuery) ||
                          r.referenceNumber.toLowerCase().contains(_searchQuery)).toList();
                    }

                    if (requests.isEmpty) {
                      return const Center(child: Text('لا توجد طلبات شحن مطابقة للبحث'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final req = requests[index];
                        final isPending = req.status == 'pending';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .5),
                                          child: const Icon(Icons.account_balance_wallet_rounded, size: 20),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              req.userName,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              req.userPhone,
                                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _statusColor(req.status).withValues(alpha: .15),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            _statusText(req.status),
                                            style: TextStyle(
                                              color: _statusColor(req.status),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          tooltip: 'حذف الطلب',
                                          icon: const Icon(Icons.close_rounded, color: Colors.red, size: 20),
                                          onPressed: () => _deleteWalletRequest(req),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'مبلغ الشحن: ${req.amount.toStringAsFixed(0)} د.ع',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'طريقة الدفع: ${req.method}',
                                        textAlign: TextAlign.end,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'مرجع التحويل: ${req.referenceNumber}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    FutureBuilder<DataSnapshot>(
                                      future: WalletService.instance.advertiserAccountsRef.child(req.userId).child('balance').get(),
                                      builder: (context, snap) {
                                        final bal = double.tryParse(snap.data?.value?.toString() ?? '0') ?? 0.0;
                                        return Text(
                                          'الرصيد الحالي: ${bal.toStringAsFixed(0)} د.ع',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                if (req.adminNote.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'ملاحظة: ${req.adminNote}',
                                    style: const TextStyle(color: Colors.redAccent),
                                  ),
                                ],
                                if (isPending) ...[
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red,
                                            side: const BorderSide(color: Colors.red),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          onPressed: () => _reviewWalletRequest(req, false),
                                          icon: const Icon(Icons.close_rounded),
                                          label: const Text('رفض وحذف'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: FilledButton.icon(
                                          style: FilledButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          onPressed: () => _reviewWalletRequest(req, true),
                                          icon: const Icon(Icons.check_rounded),
                                          label: const Text('موافقة وإضافة الرصيد'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // Tab 2: Commercial Requests (Ads & Services)
          _commercialLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: _loadCommercialRequests,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_commercialRequests.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(child: Text('لا توجد طلبات إعلانات أو خدمات تجارية حالياً')),
                  ),
                ..._commercialRequests.map((req) {
                  final isAd = req['entityType']?.toString() == 'ad';
                  final type = isAd ? 'إعلان' : 'خدمة';
                  final status = req['status']?.toString() ?? 'pending';
                  final isApproved = status == 'approved' || status == 'published';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blue.shade50,
                                    child: Icon(isAd ? Icons.campaign_rounded : Icons.miscellaneous_services_rounded, color: Colors.blue),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        req['title']?.toString() ?? type,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'المعلن: ${req['ownerName']?.toString().isNotEmpty == true ? req['ownerName'] : req['ownerUid'] ?? ''}',
                                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isApproved ? Colors.green.withValues(alpha: .15) : Colors.blue.withValues(alpha: .15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _commercialStatusText(status),
                                      style: TextStyle(
                                        color: isApproved ? Colors.green.shade800 : Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    tooltip: 'حذف الطلب',
                                    icon: const Icon(Icons.close_rounded, color: Colors.red, size: 20),
                                    onPressed: () => _deleteCommercial(req),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (req['ownerPhone']?.toString().isNotEmpty == true) ...[
                            const SizedBox(height: 6),
                            Text('الهاتف: ${req['ownerPhone']}'),
                          ],
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (!isApproved) ...[
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => _rejectCommercial(req),
                                  icon: const Icon(Icons.close_rounded),
                                  label: const Text('رفض وحذف'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FilledButton.icon(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: () => _approveCommercial(req),
                                    icon: const Icon(Icons.check_rounded),
                                    label: const Text('قبول واستقطاع ونشر'),
                                  ),
                                ),
                              ] else
                                Expanded(
                                  child: FilledButton.icon(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: () => _deleteCommercial(req),
                                    icon: const Icon(Icons.delete_outline_rounded),
                                    label: const Text('حذف الإعلان المقبول'),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _filterStatus == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filterStatus = value),
    );
  }

  Color _statusColor(String status) => switch (status) {
    'approved' => Colors.green,
    'rejected' => Colors.red,
    _ => Colors.orange,
  };

  String _statusText(String status) => switch (status) {
    'approved' => 'المقبولة',
    'rejected' => 'المرفوضة',
    _ => 'قيد المراجعة',
  };

  String _commercialStatusText(String status) => switch (status) {
    'pending' => 'قيد المراجعة',
    'approved_pending_payment' => 'بانتظار الدفع',
    'approved' => 'مقبول ونشر',
    'published' => 'منشور',
    'rejected' => 'مرفوض',
    _ => status,
  };
}
