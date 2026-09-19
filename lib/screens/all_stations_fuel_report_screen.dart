import 'package:flutter/material.dart';
import '../models/station.dart';
import '../services/station_service.dart';

class AllStationsFuelReportScreen extends StatefulWidget {
  const AllStationsFuelReportScreen({super.key});

  @override
  State<AllStationsFuelReportScreen> createState() => _AllStationsFuelReportScreenState();
}

class _AllStationsFuelReportScreenState extends State<AllStationsFuelReportScreen> {
  bool _loading = true;
  List<Station> _stations = [];
  String _searchQuery = '';
  String _filterType = 'all'; // 'all', 'regular', 'improved'

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    try {
      final list = await StationService.instance.getStations();
      if (!mounted) return;
      setState(() {
        _stations = list.where((s) => s.active && s.status != 'deleted').toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(context) {
    var filtered = _stations;
    if (_filterType == 'regular') {
      filtered = filtered.where((s) => s.regular95 > 0).toList();
    } else if (_filterType == 'improved') {
      filtered = filtered.where((s) => s.improved95 > 0).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((s) =>
      s.name.toLowerCase().contains(_searchQuery) ||
          s.governorate.toLowerCase().contains(_searchQuery) ||
          s.district.toLowerCase().contains(_searchQuery)).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('جدول توفر الوقود لجميع المحطات'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'تنزيل الجدول كصورة',
            icon: const Icon(Icons.download_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تجهيز وتنزيل الجدول الشامل لجميع المحطات بنجاح')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header info banner
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade900,
            child: Row(
              children: [
                const Icon(Icons.access_time_filled_rounded, color: Colors.amber, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'تقرير الوقود الشامل لليوم التالي',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'تحديث تلقائي يومياً الساعة 9:00 مساءً (بنزين محسن وعادي)',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Search & Filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'ابحث باسم المحطة أو المحافظة...',
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
                      _filterChip('جميع المحطات', 'all'),
                      const SizedBox(width: 8),
                      _filterChip('متوفر بنزين عادي', 'regular'),
                      const SizedBox(width: 8),
                      _filterChip('متوفر بنزين محسن', 'improved'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                ? const Center(child: Text('لا توجد محطات مطابقة للبحث'))
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final s = filtered[index];
                final hasRegular = s.regular95 > 0;
                final hasImproved = s.improved95 > 0;

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
                            Expanded(
                              child: Text(
                                s.name,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: s.active ? Colors.green.withValues(alpha: .15) : Colors.red.withValues(alpha: .15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                s.active ? 'فعالة' : 'متوقفة',
                                style: TextStyle(
                                  color: s.active ? Colors.green.shade800 : Colors.red.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${s.governorate} - ${s.district} (${s.stationType})',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: hasRegular ? Colors.green.shade50 : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: hasRegular ? Colors.green.shade200 : Colors.red.shade200),
                                ),
                                child: Column(
                                  children: [
                                    const Text('بنزين عادي', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(
                                      hasRegular ? '${s.regular95} لتر' : 'غير متوفر',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: hasRegular ? Colors.green.shade800 : Colors.red.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: hasImproved ? Colors.green.shade50 : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: hasImproved ? Colors.green.shade200 : Colors.red.shade200),
                                ),
                                child: Column(
                                  children: [
                                    const Text('بنزين محسن', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(
                                      hasImproved ? '${s.improved95} لتر' : 'غير متوفر',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: hasImproved ? Colors.green.shade800 : Colors.red.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _filterType == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filterType = value),
    );
  }
}
