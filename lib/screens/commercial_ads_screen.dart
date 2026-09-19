import 'dart:async';

import 'package:flutter/material.dart';
import '../models/commercial_ad.dart';
import '../services/commercial_service.dart';
import 'commercial_ad_details_screen.dart';

class CommercialAdsScreen extends StatefulWidget {
  const CommercialAdsScreen({super.key});
  @override
  State<CommercialAdsScreen> createState() => _CommercialAdsScreenState();
}

class _CommercialAdsScreenState extends State<CommercialAdsScreen> {
  String query = '';
  String category = 'الكل';
  late final Stream<List<CommercialAd>> _adsStream;
  List<CommercialAd> _lastAds = const [];

  @override
  void initState() {
    super.initState();
    _adsStream = CommercialService.instance.activeAds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعلانات'), centerTitle: true),
      body: StreamBuilder<List<CommercialAd>>(
        stream: _adsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _lastAds = snapshot.data!;
          }
          if (snapshot.hasError) {
            debugPrint('تعذر تحميل قائمة الإعلانات: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting && _lastAds.isEmpty) return const Center(child: CircularProgressIndicator());
          final all = snapshot.data ?? _lastAds;
          final cats = ['الكل', ...{for (final ad in all) if (ad.category.isNotEmpty) ad.category}];
          final list = all.where((ad) => (query.isEmpty || '${ad.title} ${ad.businessName} ${ad.description}'.toLowerCase().contains(query.toLowerCase())) && (category == 'الكل' || ad.category == category)).toList();
          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView(padding: const EdgeInsets.all(16), children: [
              TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'ابحث عن إعلان', border: OutlineInputBorder()), onChanged: (v) => setState(() => query = v)),
              const SizedBox(height: 10),
              SizedBox(height: 42, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: cats.length, separatorBuilder: (_, _) => const SizedBox(width: 8), itemBuilder: (_, i) => ChoiceChip(label: Text(cats[i]), selected: category == cats[i], onSelected: (_) => setState(() => category = cats[i])))),
              const SizedBox(height: 15),
              if (list.isEmpty) const Padding(padding: EdgeInsets.all(30), child: Center(child: Text('لا توجد إعلانات منشورة حالياً'))),
              ...list.map((ad) => _adCard(ad)),
            ]),
          );
        },
      ),
    );
  }

  Widget _adCard(CommercialAd ad) => Card(
    clipBehavior: Clip.antiAlias,
    margin: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      onTap: () { CommercialService.instance.incrementAdMetric(ad.id, 'clicks'); Navigator.push(context, MaterialPageRoute(builder: (_) => CommercialAdDetailsScreen(ad: ad))); },
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(height: 170, child: ad.imageUrls.isEmpty ? const ColoredBox(color: Color(0xFFEAF2FF), child: Icon(Icons.campaign, size: 60)) : Image.network(ad.imageUrls.first, fit: BoxFit.cover, errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFFEAF2FF), child: Icon(Icons.campaign, size: 60)))),
        Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(ad.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))), if (ad.featured) const Chip(label: Text('مميز'), avatar: Icon(Icons.star, size: 15))]), Text(ad.businessName), const SizedBox(height: 5), Text(ad.description, maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 8), Text('${ad.governorate} - ${ad.district}', style: const TextStyle(color: Colors.grey))]))
      ]),
    ),
  );
}
