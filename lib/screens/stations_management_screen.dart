import 'package:flutter/material.dart';

class StationsScreen extends StatelessWidget {

  const StationsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_location),
      ),

      body: ListView(

        children: const [

          ListTile(
            leading: Icon(Icons.local_gas_station),
            title: Text("محطة الرمادي"),
            subtitle: Text("الأنبار"),
          ),

        ],

      ),

    );
  }
}