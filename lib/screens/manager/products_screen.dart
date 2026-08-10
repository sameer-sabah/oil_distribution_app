import 'package:flutter/material.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      {
        "name": "البنزين العادي",
        "qty": "18,500 لتر",
        "percent": 0.85,
        "color": Colors.green,
      },
      {
        "name": "البنزين المحسن",
        "qty": "12,300 لتر",
        "percent": 0.62,
        "color": Colors.orange,
      },
      {
        "name": "البنزين السوبر",
        "qty": "4,900 لتر",
        "percent": 0.25,
        "color": Colors.red,
      },
      {
        "name": "زيت الغاز",
        "qty": "21,000 لتر",
        "percent": 0.93,
        "color": Colors.blue,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("المنتجات النفطية"),
        backgroundColor: const Color(0xFF0B3C6D),
      ),
      backgroundColor: const Color(0xffF4F7FC),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final item = products[index];

          return Card(
            elevation: 5,
            margin: const EdgeInsets.only(bottom: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["name"] as String,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "الكمية الحالية: ${item["qty"]}",
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 12),

                  LinearProgressIndicator(
                    value: item["percent"] as double,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(20),
                    color: item["color"] as Color,
                    backgroundColor: Colors.grey.shade300,
                  ),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit),
                        label: const Text("تعديل"),
                      ),

                      const SizedBox(width: 10),

                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.visibility),
                        label: const Text("التفاصيل"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}