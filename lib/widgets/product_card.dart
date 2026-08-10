import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
final String title;
final int quantity;

const ProductCard({
super.key,
required this.title,
required this.quantity,
});

Color get color {
if (quantity >= 5000) {
return Colors.green;
}

if (quantity >= 1000) {
return Colors.orange;
}

return Colors.red;
}

String get status {
if (quantity >= 5000) {
return "متوفر";
}

if (quantity >= 1000) {
return "كمية محدودة";
}

return "نفد";
}

double get progress {
if (quantity >= 10000) {
return 1;
}

return quantity / 10000;
}

@override
Widget build(BuildContext context) {
return Card(
elevation: 4,
margin: const EdgeInsets.symmetric(
vertical: 8,
),
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(15),
),
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
children: [
Row(
children: [
Icon(
Icons.local_gas_station,
color: color,
),

const SizedBox(width: 10),

Expanded(
child: Text(
title,
style: const TextStyle(
fontSize: 18,
fontWeight:
FontWeight.bold,
),
),
),

Text(
"$quantity لتر",
style: const TextStyle(
fontWeight:
FontWeight.bold,
),
),
],
),

const SizedBox(height: 15),
  LinearProgressIndicator(
    value: progress,
    minHeight: 10,
    borderRadius:
    BorderRadius.circular(
      20,
    ),
    backgroundColor:
    Colors.grey.shade300,
    color: color,
  ),

  const SizedBox(height: 12),

  Text(
    status,
    style: TextStyle(
      color: color,
      fontWeight:
      FontWeight.bold,
      fontSize: 16,
    ),
  ),
],
),
),
);
}
}