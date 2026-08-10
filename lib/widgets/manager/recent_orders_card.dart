import 'package:flutter/material.dart';

class RecentOrdersCard extends StatelessWidget {
  const RecentOrdersCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: Colors.green,
                ),
                SizedBox(width: 10),
                Text(
                  "آخر الطلبات",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            ListTile(
              leading: Icon(Icons.local_shipping),
              title: Text("لا توجد طلبات حديثة"),
              subtitle: Text("سيتم عرض الطلبات هنا"),
            ),
          ],
        ),
      ),
    );
  }
}