import 'package:flutter/material.dart';

import 'government_stations_screen.dart';
import 'private_stations_screen.dart';
class StationFoldersScreen extends StatelessWidget {
  final String branchId;

  const StationFoldersScreen({
    super.key,
    required this.branchId,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة المحطات"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.account_balance,
                  color: Colors.blue,
                  size: 40,
                ),
                title: const Text(
                  "المحطات الحكومية",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          GovernmentStationsScreen(
                            branchId: branchId,
                          )
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.store,
                  color: Colors.green,
                  size: 40,
                ),
                title: const Text(
                  "المحطات الأهلية",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PrivateStationsScreen(
                            branchId: branchId,
                          )
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}