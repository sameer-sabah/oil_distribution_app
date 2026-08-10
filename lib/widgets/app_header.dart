import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Hero(
          tag: "logo",
          child: Image.asset(
            "assets/images/logo.png",
            width: 95,
          ),
        )
            .animate()
            .fade(duration: 700.ms)
            .scale(),

        const SizedBox(height: 15),

        const Text(
          "شركة توزيع المنتجات النفطية",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        )
            .animate()
            .fade(delay: 300.ms)
            .slideY(begin: -.5),

        const SizedBox(height: 8),

        const Text(
          "نافذة المنتوج النفطي",
          style: TextStyle(
            fontSize: 18,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}