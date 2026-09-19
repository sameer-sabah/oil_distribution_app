import 'package:flutter/material.dart';
import '../models/commercial_service_model.dart';
import '../services/commercial_service.dart';
import '../services/navigation_service.dart';
import 'package:url_launcher/url_launcher.dart';

class CommercialServicesScreen extends StatefulWidget {
  const CommercialServicesScreen({super.key});
  @override
  State<CommercialServicesScreen> createState() => _CommercialServicesScreenState();
}

class _CommercialServicesScreenState extends State<CommercialServicesScreen> {
  String query = '';
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('الخدمات'), centerTitle: true),
    body: StreamBuilder<List<CommercialServiceModel>>(
      stream: CommercialService.instance.activeServices(),
      builder: (context, snapshot) {
        final items = (snapshot.data ?? []).where((s) => query.isEmpty || '${s.name} ${s.businessName} ${s.description}'.toLowerCase().contains(query.toLowerCase())).toList();
        return ListView(padding: const EdgeInsets.all(16), children: [
          TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'ابحث عن خدمة', border: OutlineInputBorder()), onChanged: (v) => setState(() => query = v)),
          const SizedBox(height: 15),
          if (items.isEmpty) const Padding(padding: EdgeInsets.all(30), child: Center(child: Text('لا توجد خدمات منشورة حالياً'))),
          ...items.map((s) => Card(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (s.imageUrls.isNotEmpty) SizedBox(height: 160, child: Image.network(s.imageUrls.first, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox(height: 160, child: Icon(Icons.miscellaneous_services, size: 60)))),
            ListTile(title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('${s.businessName}\n${s.description}', maxLines: 3, overflow: TextOverflow.ellipsis)),
            Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 12), child: Wrap(spacing: 8, children: [
              if (s.phone.isNotEmpty) ActionChip(avatar: const Icon(Icons.phone), label: const Text('اتصال'), onPressed: () { CommercialService.instance.incrementServiceMetric(s.id, 'calls'); launchUrl(Uri.parse('tel:${s.phone}')); }),
              if (s.whatsapp.isNotEmpty) ActionChip(avatar: const Icon(Icons.chat), label: const Text('WhatsApp'), onPressed: () { CommercialService.instance.incrementServiceMetric(s.id, 'whatsappClicks'); launchUrl(Uri.parse('https://wa.me/${s.whatsapp.replaceAll('+', '')}')); }),
              ActionChip(avatar: const Icon(Icons.map), label: const Text('الخريطة'), onPressed: () { CommercialService.instance.incrementServiceMetric(s.id, 'mapClicks'); const NavigationService().openGoogleMaps(s.latitude, s.longitude); }),
            ])),
          ]))),
        ]);
      },
    ),
  );
}

class CommercialServiceDetailsScreen extends StatelessWidget {
  final CommercialServiceModel service;
  const CommercialServiceDetailsScreen({super.key, required this.service});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('تفاصيل الخدمة'), centerTitle: true),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      if (service.imageUrls.isNotEmpty) SizedBox(height: 230, child: PageView(children: service.imageUrls.map((u) => ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.network(u, fit: BoxFit.cover))).toList())),
      const SizedBox(height: 15), Text(service.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), Text(service.businessName, style: const TextStyle(color: Colors.grey)), const SizedBox(height: 15), Text(service.description, style: const TextStyle(fontSize: 16)), const SizedBox(height: 15), Text('الموقع: ${service.governorate} - ${service.district}'), if (service.address.isNotEmpty) Text('العنوان: ${service.address}'), if (service.workingHours.isNotEmpty) Text('ساعات العمل: ${service.workingHours}'), const SizedBox(height: 20), Wrap(spacing: 8, runSpacing: 8, children: [
        if (service.phone.isNotEmpty) ElevatedButton.icon(onPressed: () { CommercialService.instance.incrementServiceMetric(service.id, 'calls'); launchUrl(Uri.parse('tel:${service.phone}')); }, icon: const Icon(Icons.phone), label: const Text('اتصال')),
        if (service.whatsapp.isNotEmpty) ElevatedButton.icon(onPressed: () { CommercialService.instance.incrementServiceMetric(service.id, 'whatsappClicks'); launchUrl(Uri.parse('https://wa.me/${service.whatsapp.replaceAll('+', '')}')); }, icon: const Icon(Icons.chat), label: const Text('WhatsApp')),
        ElevatedButton.icon(onPressed: () { CommercialService.instance.incrementServiceMetric(service.id, 'mapClicks'); const NavigationService().openGoogleMaps(service.latitude, service.longitude); }, icon: const Icon(Icons.map), label: const Text('الموقع')),
      ]),
    ]),
  );
}
