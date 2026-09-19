import 'package:flutter/material.dart';

class StatisticsCards extends StatelessWidget {
  const StatisticsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.35,
      children: const [
        _StatCard(
          title: "مبيعات اليوم",
          value: "15,600,000",
          subtitle: "دينار عراقي",
          icon: Icons.payments_rounded,
          color: Color(0xff2E7D32),
        ),
        _StatCard(
          title: "عدد الزبائن",
          value: "1,248",
          subtitle: "زبون",
          icon: Icons.people_alt_rounded,
          color: Color(0xff1565C0),
        ),
        _StatCard(
          title: "الوقود المباع",
          value: "34,560",
          subtitle: "لتر",
          icon: Icons.local_gas_station_rounded,
          color: Color(0xffEF6C00),
        ),
        _StatCard(
          title: "طلبات التزويد",
          value: "3",
          subtitle: "طلبات",
          icon: Icons.local_shipping_rounded,
          color: Color(0xff8E24AA),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withValues(alpha: .12),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}