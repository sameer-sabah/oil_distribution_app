import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _tr(BuildContext context, String key) {
    final lang = Localizations.localeOf(context).languageCode;

    const translations = <String, Map<String, String>>{
      'ar': {
        'appName': 'نافذة المنتوج النفطي',
        'subTitle': 'نظام إدارة المواد النفطية الموحد',
        'home': 'الرئيسية',
        'login': 'تسجيل الدخول',
        'citizen': 'دخول المواطن',
        'ads': 'الإعلانات',
        'notifications': 'الإشعارات',
        'settings': 'الإعدادات',
        'logout': 'تسجيل الخروج',
      },
      'en': {
        'appName': 'Oil Product Window',
        'subTitle': 'Unified Oil Products Management',
        'home': 'Home',
        'login': 'Login',
        'citizen': 'Citizen Access',
        'ads': 'Advertisements',
        'notifications': 'Notifications',
        'settings': 'Settings',
        'logout': 'Logout',
      },
      'ku': {
        'appName': 'پەنجەرەی بەرهەمی نەوتی',
        'subTitle': 'سیستەمی بەیەکەوەبەستراوی بەرهەمە نەوتییەکان',
        'home': 'سەرەکی',
        'login': 'چوونەژوورەوە',
        'citizen': 'چوونەژوورەوەی هاووڵاتی',
        'ads': 'ڕیکلامەکان',
        'notifications': 'ئاگادارکردنەوەکان',
        'settings': 'ڕێکخستنەکان',
        'logout': 'چوونەدەرەوە',
      },
      'fa': {
        'appName': 'پنجره محصولات نفتی',
        'subTitle': 'سامانه یکپارچه مدیریت محصولات نفتی',
        'home': 'صفحه اصلی',
        'login': 'ورود',
        'citizen': 'ورود شهروند',
        'ads': 'تبلیغات',
        'notifications': 'اعلان‌ها',
        'settings': 'تنظیمات',
        'logout': 'خروج',
      },
    };

    return translations[lang]?[key] ?? translations['ar']![key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF8FAFC),
      child: SafeArea(
        child: Column(
          children: [
            // =========================================================
            // الهيدر الأزرق الملكي الفاخر مع الشعار والعنوان الذهبي
            // =========================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0758D8), Color(0xFF0543B0)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x330758D8),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // الشعار الدائري الذهبي البارز
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF0758D8),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.local_gas_station_rounded,
                          size: 48,
                          color: Color(0xFFFCD34D),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // الإطار الذهبي المنحني للعنوان
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: const Color(0xFFFCD34D), width: 1.5),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFCD34D).withValues(alpha: 0.2),
                          const Color(0xFFD97706).withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                    child: Text(
                      _tr(context, 'appName'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // =========================================================
            // قائمة الأزرار الموحدة باللون الذهبي الملكي الفاخر
            // =========================================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Column(
                  children: [
                    // 1. الرئيسية
                    _AnimatedDrawerButton(
                      title: _tr(context, 'home'),
                      icon: Icons.home_rounded,
                      gradientColors: const [Color(0xFFB8860B), Color(0xFF8B6508)],
                      borderColor: const Color(0xFFFCD34D),
                      badgeText: "2",
                      badgeColor: Colors.redAccent,
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 10),

                    // 2. تسجيل الدخول
                    _AnimatedDrawerButton(
                      title: _tr(context, 'login'),
                      icon: Icons.person_rounded,
                      gradientColors: const [Color(0xFFB8860B), Color(0xFF8B6508)],
                      borderColor: const Color(0xFFFCD34D),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/login');
                      },
                    ),
                    const SizedBox(height: 10),

                    // 3. دخول المواطن مع شارات فرعية
                    _AnimatedDrawerButton(
                      title: _tr(context, 'citizen'),
                      icon: Icons.badge_rounded,
                      gradientColors: const [Color(0xFFB8860B), Color(0xFF8B6508)],
                      borderColor: const Color(0xFFFCD34D),
                      subBadges: const ["البيانات الشخصية", "طلب جديد", "استعلام"],
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/citizen');
                      },
                    ),
                    const SizedBox(height: 10),

                    // 4. الإعلانات
                    _AnimatedDrawerButton(
                      title: _tr(context, 'ads'),
                      icon: Icons.campaign_rounded,
                      gradientColors: const [Color(0xFFB8860B), Color(0xFF8B6508)],
                      borderColor: const Color(0xFFFCD34D),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/commercialAds');
                      },
                    ),
                    const SizedBox(height: 10),

                    // 5. الإشعارات
                    _AnimatedDrawerButton(
                      title: _tr(context, 'notifications'),
                      icon: Icons.notifications_rounded,
                      gradientColors: const [Color(0xFFB8860B), Color(0xFF8B6508)],
                      borderColor: const Color(0xFFFCD34D),
                      subBadges: const ["عاجل", "أرشيف", "مساعدة"],
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/notifications');
                      },
                    ),
                    const SizedBox(height: 10),

                    // 6. الإعدادات
                    _AnimatedDrawerButton(
                      title: _tr(context, 'settings'),
                      icon: Icons.settings_rounded,
                      gradientColors: const [Color(0xFFB8860B), Color(0xFF8B6508)],
                      borderColor: const Color(0xFFFCD34D),
                      leftIcon: Icons.tune_rounded,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/settings');
                      },
                    ),
                  ],
                ),
              ),
            ),

            // =========================================================
            // زر تسجيل الخروج السفلي الموحد
            // =========================================================
            Padding(
              padding: const EdgeInsets.all(14),
              child: _AnimatedDrawerButton(
                title: _tr(context, 'logout'),
                icon: Icons.logout_rounded,
                gradientColors: const [Color(0xFFDC2626), Color(0xFFB91C1C)],
                borderColor: const Color(0xFFFCA5A5),
                subBadges: const ["مساعدة"],
                onTap: () async {
                  final nav = Navigator.of(context);
                  await AuthService.instance.logout();
                  nav.pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// عنصر الزر الموحد باللون الذهبي المزود بأنيميشن التكبير عند الضغط
// =========================================================================
class _AnimatedDrawerButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<Color> gradientColors;
  final Color borderColor;
  final String? badgeText;
  final Color? badgeColor;
  final List<String>? subBadges;
  final IconData? leftIcon;
  final VoidCallback onTap;

  const _AnimatedDrawerButton({
    required this.title,
    required this.icon,
    required this.gradientColors,
    required this.borderColor,
    this.badgeText,
    this.badgeColor,
    this.subBadges,
    this.leftIcon,
    required this.onTap,
  });

  @override
  State<_AnimatedDrawerButton> createState() => _AnimatedDrawerButtonState();
}

class _AnimatedDrawerButtonState extends State<_AnimatedDrawerButton> {
  bool _isPressed = false;

  void _handleTap() async {
    setState(() {
      _isPressed = true;
    });

    // التكبير السلس الخفيف لمدة 120 مللي ثانية قبل التنقل
    await Future.delayed(const Duration(milliseconds: 120));

    if (mounted) {
      setState(() {
        _isPressed = false;
      });
    }

    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 1.06 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: widget.gradientColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border.all(color: widget.borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: widget.gradientColors.first.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // الشارة الذهبية الدائرية الموحدة لجميع الإيعازات
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFCD34D), Color(0xFFD97706)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFCD34D).withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    if (widget.badgeText != null)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: widget.badgeColor ?? Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            widget.badgeText!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 10),

                // عنوان الزر الرئيسي
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const Spacer(),

                // الشارات الفرعية المرنة
                if (widget.subBadges != null) ...[
                  Flexible(
                    child: Wrap(
                      spacing: 3,
                      runSpacing: 2,
                      alignment: WrapAlignment.end,
                      children: widget.subBadges!.map((text) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            text,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ] else if (widget.leftIcon != null) ...[
                  Icon(widget.leftIcon, color: Colors.white70, size: 18),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
