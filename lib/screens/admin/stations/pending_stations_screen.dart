import 'package:flutter/material.dart';

class PendingStationsScreen extends StatelessWidget {

  const PendingStationsScreen({
    super.key,
  });


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "المحطات قيد الانتظار",
        ),
        centerTitle: true,
      ),


      body: const Center(

        child: Text(
          "لا توجد محطات قيد الانتظار",
        ),

      ),

    );

  }

}