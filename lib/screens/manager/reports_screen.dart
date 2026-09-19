import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),
      appBar: AppBar(
        title: const Text("التقارير"),
        backgroundColor: const Color(0xFF0B3C6D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [

            _card(
              Icons.local_gas_station,
              "تقرير المنتجات",
              Colors.blue,
            ),

            _card(
              Icons.bar_chart,
              "تقرير المبيعات",
              Colors.green,
            ),

            _card(
              Icons.local_shipping,
              "طلبات التزويد",
              Colors.orange,
            ),

            _card(
              Icons.people,
              "تقرير الموظفين",
              Colors.purple,
            ),

            _card(
              Icons.picture_as_pdf,
              "تصدير PDF",
              Colors.red,
            ),

            _card(
              Icons.table_chart,
              "تصدير Excel",
              Colors.teal,
            ),

          ],
        ),
      ),
    );
  }

  Widget _card(
      IconData icon,
      String title,
      Color color,
      ) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            CircleAvatar(
              radius: 34,
              backgroundColor: color.withValues(alpha: .15),
              child: Icon(
                icon,
                color: color,
                size: 34,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
              textAlign: TextAlign.center,
            ),

          ],
        ),
      ),
    );
  }
}