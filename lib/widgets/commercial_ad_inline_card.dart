import 'dart:async';

import 'package:flutter/material.dart';
import '../models/commercial_ad.dart';
import '../services/commercial_service.dart';
import '../screens/commercial_ad_details_screen.dart';

class CommercialAdInlineCard extends StatefulWidget {
  const CommercialAdInlineCard({super.key});

  @override
  State<CommercialAdInlineCard> createState() =>
      _CommercialAdInlineCardState();
}

class _CommercialAdInlineCardState
    extends State<CommercialAdInlineCard> {
  late final Stream<List<CommercialAd>> _adsStream;
  List<CommercialAd> _lastAds = const [];

  @override
  void initState() {
    super.initState();
    _adsStream = CommercialService.instance.activeAds(
      placement: 'stations',
    );
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<List<CommercialAd>>(
    stream: _adsStream,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        _lastAds = snapshot.data!;
      }
      if (snapshot.hasError) {
        debugPrint(
          'تعذر تحميل إعلان المحطات: ${snapshot.error}',
        );
      }
      final ads = snapshot.data ?? _lastAds;
      if (ads.isEmpty) return const SizedBox.shrink();
      final ad = ads.first;
      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () { CommercialService.instance.incrementAdMetric(ad.id, 'clicks'); Navigator.push(context, MaterialPageRoute(builder: (_) => CommercialAdDetailsScreen(ad: ad))); },
          child: Row(children: [
            SizedBox(width: 105, height: 85, child: ad.imageUrls.isEmpty ? const ColoredBox(color: Color(0xFFEAF2FF), child: Icon(Icons.campaign)) : Image.network(ad.imageUrls.first, fit: BoxFit.cover)),
            Expanded(child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('إعلان مميز', style: TextStyle(color: Colors.blue, fontSize: 11)), Text(ad.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)), Text(ad.businessName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey))]))),
          ]),
        ),
      );
    },
  );
}
