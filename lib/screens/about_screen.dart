import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchURL(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // خلفية داكنة فاخرة ثابتة
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E293B),
                  Color(0xFF0B132B),
                ],
              ),
            ),
          ),
          Positioned(
            right: -40,
            top: 80,
            child: Opacity(
              opacity: 0.05,
              child: const Icon(
                Icons.local_gas_station_rounded,
                size: 320,
                color: Color(0xFFD4AF37),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // شريط العنوان
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Text(
                        'عن التطبيق',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // شعار دائم مذهب
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD4AF37), Color(0xFF8A6D1C)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF0F172A),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_gas_station_rounded,
                              size: 55,
                              color: Color(0xFFFCD34D),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Center(
                        child: Text(
                          'نافذة المنتوج النفطي',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'منصة لعرض توفر المنتجات النفطية والمحطات والخدمات والإعلانات التجارية.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Color(0xFFCBD5E1)),
                        ),
                      ),
                      const SizedBox(height: 22),

                      _parchmentCard(
                        child: const Text(
                          'يوفر التطبيق للمواطن معرفة المحطات وتوفر المنتجات ومواقعها، مع إمكانية عرض خدمات وإعلانات تجارية مدفوعة بعد مراجعتها واعتمادها من الإدارة.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // كرت التنويه والجهة الحكومية ورابط المصدر الرسمي
                      _parchmentCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFF8A6D1C)]),
                                  ),
                                  child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'إخلاء مسؤولية ومصدر البيانات',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'هذا التطبيق هو تطبيق مستقل قام بتطويره المهندس سمير الجوعاني لخدمة وتسهيل معرفة مواقع المحطات وتوفر المنتجات. التطبيق لا يمثل أي جهة حكومية أو رسمية، وليس له أي ارتباط رسمي بوزارة النفط أو شركة توزيع المنتجات النفطية.',
                              style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFF334155), fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'مصادر البيانات والمعلومات الرسمية:',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () => _launchURL('https://opdc.oil.gov.iq'),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.link_rounded, size: 18, color: Color(0xFF8A6D1C)),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'شركة توزيع المنتجات النفطية (opdc.oil.gov.iq)',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF1D4ED8),
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => _launchURL('https://oil.gov.iq'),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.link_rounded, size: 18, color: Color(0xFF8A6D1C)),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'موقع وزارة النفط العراقية (oil.gov.iq)',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF1D4ED8),
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      _parchmentCard(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFF8A6D1C)]),
                              ),
                              child: const Icon(Icons.engineering_rounded, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('المطور', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B))),
                                  SizedBox(height: 2),
                                  Text('المهندس سمير الجوعاني', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      _parchmentCard(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFF8A6D1C)]),
                              ),
                              child: const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('الإصدار الحالي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B))),
                                  const SizedBox(height: 2),
                                  FutureBuilder<PackageInfo>(
                                    future: PackageInfo.fromPlatform(),
                                    builder: (context, snapshot) {
                                      final ver = snapshot.hasData ? snapshot.data!.version : '...';
                                      return Text('v$ver', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A)));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _parchmentCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFDFBF7), Color(0xFFF4EFE6)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFC5A059), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
