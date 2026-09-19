import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/commercial_ad.dart';
import '../services/commercial_service.dart';
import '../services/navigation_service.dart';
import '../utils/iraqi_phone_number.dart';

class CommercialAdDetailsScreen extends StatefulWidget {
  final CommercialAd ad;

  const CommercialAdDetailsScreen({
    super.key,
    required this.ad,
  });

  @override
  State<CommercialAdDetailsScreen> createState() =>
      _CommercialAdDetailsScreenState();
}

class _CommercialAdDetailsScreenState
    extends State<CommercialAdDetailsScreen> {
  @override
  void initState() {
    super.initState();

    CommercialService.instance.incrementAdMetric(
      widget.ad.id,
      'views',
    );
  }

  Future<void> _openUri(
      String value,
      String metric,
      ) async {
    await CommercialService.instance.incrementAdMetric(
      widget.ad.id,
      metric,
    );

    final launched = await launchUrl(
      Uri.parse(value),
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر فتح الرابط'),
        ),
      );
    }
  }

  Future<void> _openMap() async {
    await CommercialService.instance.incrementAdMetric(
      widget.ad.id,
      'mapClicks',
    );

    try {
      await const NavigationService().openGoogleMaps(
        widget.ad.latitude,
        widget.ad.longitude,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر فتح الموقع: $e',
          ),
        ),
      );
    }
  }

  Future<void> _openWhatsApp() async {
    final number = IraqiPhoneNumber.forWhatsApp(widget.ad.whatsapp);
    if (number == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('رقم واتساب غير صحيح. اكتب رقماً عراقياً يبدأ بـ 07'),
        ),
      );
      return;
    }

    await _openUri(
      Uri.https('wa.me', '/$number').toString(),
      'whatsappClicks',
    );
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.ad;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الإعلان'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (ad.imageUrls.isNotEmpty)
            SizedBox(
              height: 240,
              child: PageView(
                children: ad.imageUrls.map((url) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        url,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (
                            context,
                            error,
                            stackTrace,
                            ) {
                          return const ColoredBox(
                            color: Color(0xFFEAF2FF),
                            child: Center(
                              child: Icon(
                                Icons.campaign,
                                size: 70,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 15),

          if (ad.featured)
            const Align(
              alignment: Alignment.centerRight,
              child: Chip(
                label: Text('إعلان مميز'),
                avatar: Icon(Icons.star),
              ),
            ),

          Text(
            ad.title,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            ad.businessName,
            style: const TextStyle(
              fontSize: 17,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            ad.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 15),

          if (ad.governorate.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                bottom: 6,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_city_outlined,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      ad.district.isNotEmpty
                          ? 'الموقع: ${ad.governorate} - ${ad.district}'
                          : 'الموقع: ${ad.governorate}',
                    ),
                  ),
                ],
              ),
            ),

          if (ad.address.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                bottom: 6,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.place_outlined,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'العنوان: ${ad.address}',
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 15),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: LayoutBuilder(
                builder: (
                    context,
                    constraints,
                    ) {
                  final itemWidth =
                      (constraints.maxWidth - 12) / 2;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: itemWidth,
                        child: _metricItem(
                          icon: Icons.visibility_outlined,
                          label: 'المشاهدات',
                          value: ad.views.toString(),
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _metricItem(
                          icon: Icons.touch_app_outlined,
                          label: 'النقرات',
                          value: ad.clicks.toString(),
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _metricItem(
                          icon: Icons.phone_outlined,
                          label: 'الاتصالات',
                          value: ad.calls.toString(),
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _metricItem(
                          icon: Icons.chat_outlined,
                          label: 'WhatsApp',
                          value:
                          ad.whatsappClicks.toString(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (ad.phone.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () => _openUri(
                    'tel:${ad.phone}',
                    'calls',
                  ),
                  icon: const Icon(
                    Icons.phone,
                  ),
                  label: const Text(
                    'اتصال',
                  ),
                ),

              if (ad.whatsapp.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: _openWhatsApp,
                  icon: const Icon(
                    Icons.chat,
                  ),
                  label: const Text(
                    'WhatsApp',
                  ),
                ),

              if (ad.website.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () => _openUri(
                    ad.website,
                    'clicks',
                  ),
                  icon: const Icon(
                    Icons.link,
                  ),
                  label: const Text(
                    'الرابط',
                  ),
                ),

              if (ad.latitude != 0 ||
                  ad.longitude != 0)
                ElevatedButton.icon(
                  onPressed: _openMap,
                  icon: const Icon(
                    Icons.map,
                  ),
                  label: const Text(
                    'الموقع',
                  ),
                ),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _metricItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(
          alpha: 0.45,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
