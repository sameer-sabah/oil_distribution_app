import 'package:flutter/material.dart';

class SupplyRequestsScreen extends StatelessWidget {
  const SupplyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),
      appBar: AppBar(
        title: const Text("طلبات التزويد"),
        backgroundColor: const Color(0xFF0B3C6D),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SupplyCard(
            product: "البنزين العادي",
            quantity: "30,000 لتر",
            status: "قيد المراجعة",
            color: Colors.orange,
          ),
          SizedBox(height: 15),
          SupplyCard(
            product: "البنزين المحسن",
            quantity: "20,000 لتر",
            status: "تمت الموافقة",
            color: Colors.green,
          ),
          SizedBox(height: 15),
          SupplyCard(
            product: "زيت الغاز",
            quantity: "15,000 لتر",
            status: "بانتظار الإرسال",
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}

class SupplyCard extends StatelessWidget {
  final String product;
  final String quantity;
  final String status;
  final Color color;

  const SupplyCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "الكمية المطلوبة: $quantity",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Chip(
              backgroundColor: color.withValues(alpha: .15),
              label: Text(
                status,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility),
                  label: const Text("التفاصيل"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}