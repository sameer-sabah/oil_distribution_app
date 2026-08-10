import 'package:flutter/material.dart';

class FuelProductsCard extends StatelessWidget {
  const FuelProductsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _FuelCard(
          title: "البنزين العادي",
          quantity: "25,000 لتر",
          percent: .82,
          color: Colors.green,
        ),
        SizedBox(height: 16),
        _FuelCard(
          title: "البنزين المحسن",
          quantity: "18,500 لتر",
          percent: .63,
          color: Colors.orange,
        ),
        SizedBox(height: 16),
        _FuelCard(
          title: "البنزين السوبر",
          quantity: "12,300 لتر",
          percent: .44,
          color: Colors.blue,
        ),
        SizedBox(height: 16),
        _FuelCard(
          title: "زيت الغاز",
          quantity: "8,000 لتر",
          percent: .28,
          color: Colors.red,
        ),
      ],
    );
  }
}

class _FuelCard extends StatelessWidget {
  final String title;
  final String quantity;
  final double percent;
  final Color color;

  const _FuelCard({
    required this.title,
    required this.quantity,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(.12),
                child: Icon(
                  Icons.local_gas_station,
                  color: color,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  quantity,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              color: color,
              backgroundColor: Colors.grey.shade300,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit),
                label: const Text("تعديل"),
              ),

              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.visibility),
                label: const Text("التفاصيل"),
              ),

              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text("زيادة"),
              ),
            ],
          )
        ],
      ),
    );
  }
}