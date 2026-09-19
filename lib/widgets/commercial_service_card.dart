import 'package:flutter/material.dart';
import '../models/commercial_service_model.dart';
import '../services/commercial_service.dart';
import '../screens/commercial_services_screen.dart';

class CommercialServiceCard extends StatelessWidget {
  final CommercialServiceModel service;
  const CommercialServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: SizedBox(
          width: 64,
          height: 64,
          child: service.imageUrls.isEmpty
              ? const DecoratedBox(decoration: BoxDecoration(color: Color(0xFFEAF2FF)), child: Icon(Icons.miscellaneous_services, color: Colors.blue))
              : Image.network(service.imageUrls.first, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.miscellaneous_services)),
        ),
        title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${service.businessName}\n${service.governorate} - ${service.district}', maxLines: 2),
        isThreeLine: true,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          CommercialService.instance.incrementServiceMetric(service.id, 'clicks');
          Navigator.push(context, MaterialPageRoute(builder: (_) => CommercialServiceDetailsScreen(service: service)));
        },
      ),
    );
  }
}
