import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _open(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // =========================================================
            // 1. الخلفية الثابتة الفاخرة باللون الكحلي مع زخرفة مضخة الوقود
            // =========================================================
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

            // زخرفة جرافيك بمضخة الوقود ثابتة في الخلفية بحجم كبير وبشفافية خفيفة
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
            Positioned(
              left: -50,
              bottom: 40,
              child: Opacity(
                opacity: 0.04,
                child: const Icon(
                  Icons.local_gas_station_rounded,
                  size: 350,
                  color: Colors.white,
                ),
              ),
            ),

            // =========================================================
            // 2. المحتوى وشريط التطبيق القابل للتمرير
            // =========================================================
            SafeArea(
              child: Column(
                children: [
                  // شريط العنوان - العنوان يميناً وزر العودة يساراً مشيراً لليسار
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Text(
                          l10n.settingsTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
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

                  // الإيعازات القابلة للتصعيد للأعلى والأسفل على خلفية ثابتة
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                      children: [
                        _sectionTitle(l10n.general),

                        _parchmentTile(
                          context,
                          icon: Icons.language_rounded,
                          title: l10n.language,
                          subtitle: 'العربية / الكردية / الفارسية / English',
                          route: '/language',
                        ),

                        _parchmentTile(
                          context,
                          icon: Icons.notifications_active_rounded,
                          title: l10n.notifications,
                          subtitle: 'تنبيهات المنتجات والإعلانات',
                          route: '/notifications',
                        ),

                        const SizedBox(height: 12),

                        _sectionTitle(l10n.ads),

                        _parchmentTile(
                          context,
                          icon: Icons.storefront_rounded,
                          title: 'لوحة المعلن',
                          subtitle: 'إضافة الإعلانات ومتابعتها والمدفوعات والتواصل',
                          route: '/advertiserAccount',
                        ),

                        _parchmentTile(
                          context,
                          icon: Icons.campaign_rounded,
                          title: l10n.viewAds,
                          subtitle: l10n.viewAdsSubtitle,
                          route: '/commercialAds',
                          badgeText: 'جديد',
                        ),

                        const SizedBox(height: 12),

                        _sectionTitle(l10n.supportAndApp),

                        _parchmentTile(
                          context,
                          icon: Icons.headset_mic_rounded,
                          title: l10n.contactUs,
                          subtitle: 'إرسال رسالة إلى الإدارة',
                          route: '/contact',
                        ),

                        _parchmentTile(
                          context,
                          icon: Icons.star_rounded,
                          title: l10n.rateApp,
                          subtitle: 'شاركونا رأيكم',
                          route: '/rating',
                        ),

                        _parchmentTile(
                          context,
                          icon: Icons.info_rounded,
                          title: l10n.aboutApp,
                          subtitle: 'معلومات التطبيق والمطور',
                          route: '/about',
                        ),

                        _parchmentTile(
                          context,
                          icon: Icons.privacy_tip_rounded,
                          title: l10n.privacyPolicy,
                          subtitle: l10n.privacyPolicySubtitle,
                          route: '/privacy',
                        ),

                        _parchmentTile(
                          context,
                          icon: Icons.gavel_rounded,
                          title: l10n.termsConditions,
                          subtitle: l10n.termsConditionsSubtitle,
                          route: '/terms',
                        ),

                        const SizedBox(height: 14),

                        // بطاقة الإصدار الرخامية المذهبة
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFDFBF7), Color(0xFFF3EFE6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0xFFC5A059), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFD4AF37), Color(0xFF8A6D1C)],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.verified_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.appVersion,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    FutureBuilder<PackageInfo>(
                                      future: PackageInfo.fromPlatform(),
                                      builder: (context, snapshot) {
                                        final ver = snapshot.hasData ? snapshot.data!.version : '...';
                                        return Text(
                                          'إصدار نظام موثق ومعتمد v$ver',
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        Center(
                          child: Text(
                            l10n.developer,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 6, right: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: Color(0xFFCBD5E1),
        ),
      ),
    );
  }

  Widget _parchmentTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    String? badgeText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _open(context, route),
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // 1. الأيقونة المذهبة الدائرية بقطع وتمركز موحد ومستقيم على اليمين 100%
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFF8A6D1C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDFBF7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: const Color(0xFF2D3748),
                      size: 22,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // 2. النصوص والعنوان
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          if (badgeText != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFD4AF37), Color(0xFF8A6D1C)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                badgeText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // 3. سهم الانتقال اليساري المشير إلى اليسار (<)
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: Color(0xFF8A6D1C),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
