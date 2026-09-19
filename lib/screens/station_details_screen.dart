import 'package:flutter/material.dart';
import '../widgets/commercial_ad_banner.dart';
import '../models/station.dart';

class StationDetailsScreen extends StatelessWidget {
  final Station station;

  const StationDetailsScreen({
    super.key,
    required this.station,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(station.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CommercialAdBanner(placement: 'stationDetails'),
            const SizedBox(height: 12),

            // Fuel Availability Report for Tomorrow (Updated at 9 PM automatically)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.access_time_filled_rounded, color: Colors.blue, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'حالة توفر الوقود',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'تحديث تلقائي',
                            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'حالة توفر المنتجات النفطية في المحطة للمواطن.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const Divider(height: 24),
                    ..._buildFuelAvailabilityList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            _card(
              icon: Icons.local_gas_station,
              title: "معلومات المحطة",
              children: [
                _row("اسم المحطة", station.name),
                _row("نوع المحطة", station.stationType),
                _row("المحافظة", station.governorate),
                _row("القضاء", station.district),
                _row("الفرع", station.branchName),
                _row("حالة النشاط", station.effectiveWorkingStatus),
              ],
            ),
            const SizedBox(height: 15),

            _card(
              icon: Icons.person,
              title: "بيانات المدير",
              children: [
                _row("اسم المدير", station.managerName),
                _row("هاتف المدير", station.managerPhone),
                _row("هاتف المحطة", station.phone),
              ],
            ),
            const SizedBox(height: 15),

            _card(
              icon: Icons.location_on,
              title: "الموقع",
              children: [
                _row("العنوان", station.address),
              ],
            ),
            const SizedBox(height: 15),

            _card(
              icon: Icons.inventory,
              title: "المنتجات المتاحة",
              children: [
                if (station.supportedProducts["regular95"] == true)
                  _row("بنزين عادي", station.regular95 > 0 ? "متوفر" : "غير متوفر"),
                if (station.supportedProducts["improved95"] == true)
                  _row("بنزين محسن", station.improved95 > 0 ? "متوفر" : "غير متوفر"),
                if (station.supportedProducts["super95"] == true)
                  _row("بنزين سوبر", station.super95 > 0 ? "متوفر" : "غير متوفر"),
                if (station.supportedProducts["diesel"] == true)
                  _row("زيت الغاز", station.diesel > 0 ? "متوفر" : "غير متوفر"),
                if (station.supportedProducts["whiteOil"] == true)
                  _row("النفط الأبيض", station.whiteOil > 0 ? "متوفر" : "غير متوفر"),
                if (station.supportedProducts["lpg"] == true)
                  _row("الغاز السائل", station.lpg > 0 ? "متوفر" : "غير متوفر"),
                if (!station.supportedProducts.values.any((v) => v))
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "لا توجد منتجات متاحة حاليًا",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _card({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFuelAvailabilityList() {
    final products = [
      {'key': 'regular95', 'name': 'بنزين عادي', 'qty': station.regular95},
      {'key': 'improved95', 'name': 'بنزين محسن', 'qty': station.improved95},
      {'key': 'super95', 'name': 'بنزين سوبر', 'qty': station.super95},
      {'key': 'diesel', 'name': 'زيت الغاز', 'qty': station.diesel},
      {'key': 'whiteOil', 'name': 'النفط الأبيض', 'qty': station.whiteOil},
      {'key': 'lpg', 'name': 'الغاز السائل', 'qty': station.lpg},
    ];

    final supported = products.where((p) => station.supportedProducts[p['key']] == true).toList();

    if (supported.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text(
            "لا توجد منتجات مدعومة حاليًا",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
      ];
    }

    List<Widget> rows = [];
    for (int i = 0; i < supported.length; i += 2) {
      final p1 = supported[i];
      final q1 = p1['qty'] as int;
      final isAvailable1 = q1 > 0;

      Widget item1 = Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isAvailable1 ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isAvailable1 ? Colors.green.shade200 : Colors.red.shade200),
          ),
          child: Column(
            children: [
              Text(p1['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              Text(
                isAvailable1 ? 'متوفر ($q1 لتر)' : 'غير متوفر',
                style: TextStyle(
                  color: isAvailable1 ? Colors.green.shade800 : Colors.red.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      Widget item2;
      if (i + 1 < supported.length) {
        final p2 = supported[i + 1];
        final q2 = p2['qty'] as int;
        final isAvailable2 = q2 > 0;

        item2 = Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isAvailable2 ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isAvailable2 ? Colors.green.shade200 : Colors.red.shade200),
            ),
            child: Column(
              children: [
                Text(p2['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                  isAvailable2 ? 'متوفر ($q2 لتر)' : 'غير متوفر',
                  style: TextStyle(
                    color: isAvailable2 ? Colors.green.shade800 : Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      } else {
        item2 = const Expanded(child: SizedBox());
      }

      rows.add(
        Row(
          children: [
            item1,
            const SizedBox(width: 12),
            item2,
          ],
        ),
      );

      if (i + 2 < supported.length) {
        rows.add(const SizedBox(height: 12));
      }
    }

    return rows;
  }
}
