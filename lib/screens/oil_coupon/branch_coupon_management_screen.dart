import 'package:flutter/material.dart';
import '../../models/vehicle_coupon.dart';
import '../../models/fueling_log.dart';
import '../../services/oil_coupon_service.dart';
import 'branch_coupon_table_report_screen.dart';

class BranchCouponManagementScreen extends StatefulWidget {
  const BranchCouponManagementScreen({super.key});

  @override
  State<BranchCouponManagementScreen> createState() => _BranchCouponManagementScreenState();
}

class _BranchCouponManagementScreenState extends State<BranchCouponManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;

  double _privateQty = 40.0;
  int _privateIntervalDays = 2;
  double _govMonthlyQuota = 500.0;

  List<VehicleCoupon> _vehicles = [];
  List<FuelingLog> _logs = [];

  final _privateQtyController = TextEditingController();
  final _privateDaysController = TextEditingController();
  final _govQtyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _privateQtyController.dispose();
    _privateDaysController.dispose();
    _govQtyController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final rules = await OilCouponService.instance.getBranchRules();
      _privateQty = rules['privateQty'] as double;
      _privateIntervalDays = rules['privateIntervalDays'] as int;
      _govMonthlyQuota = rules['govMonthlyQuota'] as double;

      _privateQtyController.text = _privateQty.toStringAsFixed(0);
      _privateDaysController.text = _privateIntervalDays.toString();
      _govQtyController.text = _govMonthlyQuota.toStringAsFixed(0);

      // Fetch all vehicles
      final vehiclesSnap = await OilCouponService.instance.vehiclesRef.get();
      List<VehicleCoupon> vList = [];
      if (vehiclesSnap.exists && vehiclesSnap.value is Map) {
        final raw = Map<dynamic, dynamic>.from(vehiclesSnap.value as Map);
        vList = raw.entries
            .where((e) => e.value is Map)
            .map((e) => VehicleCoupon.fromMap(e.key.toString(), Map<dynamic, dynamic>.from(e.value as Map)))
            .toList();
      }

      // Fetch all logs
      final logsSnap = await OilCouponService.instance.fuelingLogsRef.get();
      List<FuelingLog> lList = [];
      if (logsSnap.exists && logsSnap.value is Map) {
        final raw = Map<dynamic, dynamic>.from(logsSnap.value as Map);
        lList = raw.entries
            .where((e) => e.value is Map)
            .map((e) => FuelingLog.fromMap(e.key.toString(), Map<dynamic, dynamic>.from(e.value as Map)))
            .toList();
      }

      if (!mounted) return;
      setState(() {
        _vehicles = vList;
        _logs = lList;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _saveRules() async {
    final pQty = double.tryParse(_privateQtyController.text.trim());
    final pDays = int.tryParse(_privateDaysController.text.trim());
    final gQty = double.tryParse(_govQtyController.text.trim());

    if (pQty == null || pQty <= 0 || pDays == null || pDays <= 0 || gQty == null || gQty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال قيم صحيحة للحصص وفترات الاستحقاق')),
      );
      return;
    }

    try {
      await OilCouponService.instance.setBranchRules(
        privateQty: pQty,
        privateIntervalDays: pDays,
        govMonthlyQuota: gQty,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم تحديث وتعميم التوجيهات على كافة المنافذ والمركبات بنجاح')),
      );
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر حفظ التوجيهات: $e')),
      );
    }
  }

  Future<void> _deleteMonthFolder(String monthKey, bool isGov) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الموقف الشهري بالكامل'),
        content: Text('هل أنت متأكد من حذف سجلات وتزويدات شهر ($monthKey) بالكامل؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إغلاق')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف الشهر'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final updates = <String, Object?>{};
      for (final l in _logs) {
        final v = _vehicles.firstWhere((veh) => veh.id == l.vehicleId, orElse: () => _vehicles.first);
        if (v.isGovernment == isGov && l.createdAt.startsWith(monthKey)) {
          updates['fuelingLogs/${l.id}'] = null;
        }
      }

      if (updates.isNotEmpty) {
        await OilCouponService.instance.branchRulesRef.root.update(updates);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الموقف الشهري بنجاح')),
      );
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر الحذف: $e')),
      );
    }
  }

  @override
  Widget build(context) {
    final govVehicles = _vehicles.where((v) => v.isGovernment).toList();
    final privateVehicles = _vehicles.where((v) => !v.isGovernment).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الكوبون النفطي والحصص (مدير الفرع)'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'السيارات الخصوصية (المواطنين)', icon: Icon(Icons.directions_car_rounded)),
            Tab(text: 'السيارات الحكومية', icon: Icon(Icons.account_balance_rounded)),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          // Private Tab
          _buildCategoryTab(
            title: 'إعدادات وإحصائيات السيارات الخصوصية (المواطنين)',
            isGov: false,
            vehicles: privateVehicles,
          ),
          // Government Tab
          _buildCategoryTab(
            title: 'إعدادات وإحصائيات السيارات الحكومية (حصة شهرية)',
            isGov: true,
            vehicles: govVehicles,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab({required String title, required bool isGov, required List<VehicleCoupon> vehicles}) {
    final totalLiters = _logs
        .where((l) {
      final v = _vehicles.firstWhere((veh) => veh.id == l.vehicleId, orElse: () => _vehicles.first);
      return v.isGovernment == isGov;
    })
        .fold<double>(0.0, (sum, l) => sum + l.quantity);

    // Group logs by month
    final Set<String> months = {};
    months.add(DateTime.now().toIso8601String().substring(0, 7));
    for (final l in _logs) {
      final v = _vehicles.firstWhere((veh) => veh.id == l.vehicleId, orElse: () => _vehicles.first);
      if (v.isGovernment == isGov && l.createdAt.length >= 7) {
        months.add(l.createdAt.substring(0, 7));
      }
    }
    final sortedMonths = months.toList()..sort((a, b) => b.compareTo(a));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(isGov ? Icons.account_balance_rounded : Icons.directions_car_rounded, color: Colors.blue, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                if (!isGov) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _privateQtyController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'الكمية المقررة لكل تزويد (لتر)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _privateDaysController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'فترة الاستحقاق (كل كم يوم)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  TextField(
                    controller: _govQtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'الحصة الشهرية للسيارة الحكومية (لتر / شهر)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '⚠️ ملاحظة: تتصفر الكمية تلقائياً في بداية كل شهر ميلادي جديد وتبدأ حصة شهرية جديدة كاملة.',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _saveRules,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('تحديث وحفظ الإعدادات', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: _statCard('عدد المركبات', '${vehicles.length}', Icons.directions_car_rounded, Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard('إجمالي الوقود المصروف', '${totalLiters.toStringAsFixed(0)} لتر', Icons.local_gas_station_rounded, Colors.teal),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Monthly Folders Section
        Text(
          isGov ? '📂 الموقف الشهري للسيارات الحكومية (أرشيف الأشهر)' : '📂 الموقف الشهري للسيارات الخصوصية (أرشيف الأشهر)',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        ...sortedMonths.map((m) {
          final monthLogs = _logs.where((l) {
            final v = _vehicles.firstWhere((veh) => veh.id == l.vehicleId, orElse: () => _vehicles.first);
            return v.isGovernment == isGov && l.createdAt.startsWith(m);
          }).toList();

          final monthLiters = monthLogs.fold<double>(0.0, (sum, l) => sum + l.quantity);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.folder_rounded, color: Colors.blue),
              ),
              title: Text(
                'الموقف الشهري لشهر: $m',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text('عمليات التزويد: ${monthLogs.length}  |  إجمالي الوقود: ${monthLiters.toStringAsFixed(0)} لتر'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_rounded, color: Colors.red, size: 22),
                    tooltip: 'حذف الشهر بالكامل',
                    onPressed: () => _deleteMonthFolder(m, isGov),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BranchCouponTableReportScreen(
                      isGovernment: isGov,
                      vehicles: vehicles,
                      logs: _logs,
                      initialMonth: m,
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
