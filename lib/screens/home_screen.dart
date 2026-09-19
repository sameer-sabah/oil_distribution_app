import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';
import '../widgets/app_drawer.dart';
import '../widgets/role_card.dart';
import '../widgets/commercial_ad_banner.dart';

import 'citizen_screen.dart';
import 'login_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _tr(String key) {
    final lang = Localizations.localeOf(context).languageCode;

    const translations = <String, Map<String, String>>{
      'ar': {
        'appTitle': 'نافذة المنتوج النفطي',
        'electronicServices': 'الخدمات الإلكترونية للمنتوج النفطي',
        'citizenEntry': 'دخول المواطن',
        'citizenEntrySubtitle': 'استعراض المحطات، الكميات، الملاحة، وأقرب محطة',
        'systemEntry': 'دخول النظام',
        'systemEntrySubtitle': 'تسجيل الدخول لجميع مستخدمي النظام حسب الصلاحيات',
        'systemStatus': 'حالة النظام',
        'allServicesNormal': 'جميع الخدمات تعمل بصورة طبيعية.',
        'stations': 'المحطات',
        'products': 'المنتجات',
        'users': 'المستخدمون',
        'lastUpdate': 'آخر تحديث',
        'now': 'الآن',
        'am': 'ص',
        'pm': 'م',
      },
      'en': {
        'appTitle': 'Oil Product Window',
        'electronicServices': 'Electronic Oil Product Services',
        'citizenEntry': 'Citizen Access',
        'citizenEntrySubtitle': 'View stations, quantities, navigation, and the nearest station',
        'systemEntry': 'System Login',
        'systemEntrySubtitle': 'Login for all system users according to permissions',
        'systemStatus': 'System Status',
        'allServicesNormal': 'All services are operating normally.',
        'stations': 'Stations',
        'products': 'Products',
        'users': 'Users',
        'lastUpdate': 'Last Update',
        'now': 'Now',
        'am': 'AM',
        'pm': 'PM',
      },
      'ku': {
        'appTitle': 'پەنجەرەی بەرهەمی نەوتی',
        'electronicServices': 'خزمەتگوزارییە ئەلیکترۆنییەکانی بەرهەمی نەوتی',
        'citizenEntry': 'چوونەژوورەوەی هاووڵاتی',
        'citizenEntrySubtitle': 'بینینی بەنزینخانەکان، بڕەکان، ڕێنیشاندان و نزیکترین بەنزینخانە',
        'systemEntry': 'چوونەژوورەوەی سیستەم',
        'systemEntrySubtitle': 'چوونەژوورەوە بۆ هەموو بەکارهێنەرانی سیستەم بەپێی دەسەڵاتەکان',
        'systemStatus': 'دۆخی سیستەم',
        'allServicesNormal': 'هەموو خزمەتگوزارییەکان بە شێوەی ئاسایی کار دەکەن.',
        'stations': 'بەنزینخانەکان',
        'products': 'بەرهەمەکان',
        'users': 'بەکارهێنەران',
        'lastUpdate': 'دوایین نوێکردنەوە',
        'now': 'ئێستا',
        'am': 'پ.ن',
        'pm': 'د.ن',
      },
      'fa': {
        'appTitle': 'پنجره محصولات نفتی',
        'electronicServices': 'خدمات الکترونیکی محصولات نفتی',
        'citizenEntry': 'ورود شهروند',
        'citizenEntrySubtitle': 'مشاهده جایگاه‌ها، مقادیر، مسیریابی و نزدیک‌ترین جایگاه',
        'systemEntry': 'ورود به سیستم',
        'systemEntrySubtitle': 'ورود همه کاربران سیستم بر اساس سطح دسترسی',
        'systemStatus': 'وضعیت سیستم',
        'allServicesNormal': 'همه خدمات به‌طور عادی در حال کار هستند.',
        'stations': 'جایگاه‌ها',
        'products': 'محصولات',
        'users': 'کاربران',
        'lastUpdate': 'آخرین به‌روزرسانی',
        'now': 'اکنون',
        'am': 'ق.ظ',
        'pm': 'ب.ظ',
      },
    };

    return translations[lang]?[key] ?? translations['ar']![key] ?? key;
  }
  Timer? _clockTimer;

  StreamSubscription<DatabaseEvent>? _stationsSubscription;
  StreamSubscription? _usersSubscription;

  int _stationsCount = 0;
  DateTime _currentTime = DateTime.now();
  int _usersCount = 0;

  // =========================================================
  // كاش عداد المحطات
  // =========================================================
  //
  // نعرض آخر عدد محفوظ فورًا، ثم نحدّثه مباشرة عند أي إضافة
  // أو حذف داخل عقدة stations.
  // =========================================================
  static const String _stationsCountCacheKey =
      'home_stations_count';

  static const String _stationsCountCacheTimeKey =
      'home_stations_count_updated_at';

  // =========================================================
  // كاش عداد التثبيتات
  // =========================================================
  //
  // بدون Backend/Cloud Functions لا يوجد Count Aggregation آمن
  // داخل Realtime Database. لذلك نحفظ آخر عدد محلياً ونحدّثه
  // دورياً بدل تنزيل appInstallations في كل تشغيل.
  //
  // النتيجة:
  // - الرقم يظهر فوراً من الكاش.
  // - القراءة الثقيلة لا تتكرر إلا بعد انتهاء مدة الكاش.
  // - إذا فشلت الشبكة يبقى آخر رقم معروف ظاهراً.
  // =========================================================
  static const String _installationsCountCacheKey =
      'home_installations_count';

  Future<void> loadStationsCount() async {
    try {
      final prefs =
      await SharedPreferences.getInstance();

      final cachedCount =
      prefs.getInt(
        _stationsCountCacheKey,
      );

      // اعرض الرقم السابق فوراً.
      if (cachedCount != null && mounted) {
        setState(() {
          _stationsCount = cachedCount;
        });
      }

      // الاستماع المباشر يجعل المحطة الجديدة تظهر فور اعتمادها
      // داخل عداد المحطات في الشاشة الرئيسية، من دون انتظار الكاش.
      await _stationsSubscription?.cancel();

      _stationsSubscription = FirebaseDatabase.instance
          .ref("stations")
          .onValue
          .listen(
            (event) async {
          final freshCount =
              event.snapshot.children.length;

          if (mounted) {
            setState(() {
              _stationsCount = freshCount;
            });
          }

          await prefs.setInt(
            _stationsCountCacheKey,
            freshCount,
          );

          await prefs.setInt(
            _stationsCountCacheTimeKey,
            DateTime.now().millisecondsSinceEpoch,
          );
        },
        onError: (Object error) {
          // عند انقطاع الإنترنت يبقى آخر رقم محفوظ ظاهرًا.
          debugPrint(
            "خطأ في التحديث المباشر لعدد المحطات: $error",
          );
        },
      );
    } catch (e) {
      // إذا فشل الإنترنت يبقى آخر رقم محفوظ ظاهر.
      debugPrint(
        "خطأ في تحديث عدد المحطات: $e",
      );
    }
  }

  Future<void> loadUsersCount() async {
    try {
      final prefs =
      await SharedPreferences.getInstance();

      final cachedCount =
      prefs.getInt(
        _installationsCountCacheKey,
      );

      // نعرض آخر رقم محفوظ فوراً بدون انتظار الشبكة.
      if (cachedCount != null && mounted) {
        setState(() {
          _usersCount = cachedCount;
        });
      }

      await _usersSubscription?.cancel();

      _usersSubscription = FirebaseDatabase.instance
          .ref("users")
          .onValue
          .listen(
            (event) async {
          final freshCount =
              event.snapshot.children.length;

          if (mounted) {
            setState(() {
              _usersCount = freshCount;
            });
          }

          await prefs.setInt(
            _installationsCountCacheKey,
            freshCount,
          );
        },
        onError: (Object error) {
          debugPrint(
            "خطأ في التحديث المباشر لعدد المستخدمين: $error",
          );
        },
      );
    } catch (e) {
      // إذا كانت القراءة فشلت، يبقى آخر رقم مخزّن ظاهر.
      debugPrint(
        "خطأ في تحديث عدد المستخدمين: $e",
      );
    }
  }
  @override
  void initState() {
    super.initState();

    loadStationsCount();
    loadUsersCount();

    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (mounted) {
          setState(() {
            _currentTime = DateTime.now();
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _stationsSubscription?.cancel();
    _usersSubscription?.cancel();
    super.dispose();
  }

  String _formatTime() {
    int hour = _currentTime.hour;

    final minute =
    _currentTime.minute.toString().padLeft(2, '0');

    final second =
    _currentTime.second.toString().padLeft(2, '0');

    final period = hour >= 12 ? _tr('pm') : _tr('am');

    hour = hour % 12;

    if (hour == 0) {
      hour = 12;
    }

    return '$hour:$minute:$second $period';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      drawerEnableOpenDragGesture: true,

      drawer: const AppDrawer(),
      backgroundColor: AppColors.background,

      body: Stack(
        children: [

          // =========================================================
          // الخلفية المتحركة
          // =========================================================

          Positioned(
            top: -140,
            right: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                AppColors.primary.withValues(alpha: .08),
              ),
            )
                .animate(
              onPlay: (c) =>
                  c.repeat(reverse: true),
            )
                .moveY(
              begin: 0,
              end: -25,
              duration: 5.seconds,
            ),
          ),

          Positioned(
            bottom: -150,
            left: -110,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                AppColors.secondary.withValues(alpha: .08),
              ),
            )
                .animate(
              onPlay: (c) =>
                  c.repeat(reverse: true),
            )
                .moveY(
              begin: 0,
              end: 25,
              duration: 6.seconds,
            ),
          ),

          Positioned(
            top: size.height * .35,
            right: -70,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                Colors.green.withValues(alpha: .04),
              ),
            )
                .animate(
              onPlay: (c) =>
                  c.repeat(reverse: true),
            )
                .moveY(
              begin: -10,
              end: 20,
              duration: 7.seconds,
            ),
          ),

          // =========================================================
          // المحتوى
          // =========================================================

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 18,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.center,
                children: [

                  // =================================================
                  // الشريط العلوي
                  // =================================================

                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      // =================================================
                      // دخول النظام - زر صغير أعلى يسار الساعة
                      // =================================================

                      Column(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius:
                              BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const LoginScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 54,
                                height: 54,
                                decoration:
                                BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                  BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                      AppColors.shadow,
                                      blurRadius: 15,
                                    ),
                                  ],
                                  border: Border.all(
                                    color:
                                    AppColors.secondary
                                        .withValues(
                                      alpha: .18,
                                    ),
                                  ),
                                ),
                                child: Icon(
                                  Icons.login_rounded,
                                  size: 29,
                                  color:
                                  AppColors.secondary,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            _tr('systemEntry'),
                            style: TextStyle(
                              color:
                              AppColors.secondary,
                              fontSize: 11,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // =================================================
                      // الساعة الدائرية
                      // =================================================

                      Column(
                        children: [

                          Container(
                            width: 92,
                            height: 92,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                  AppColors.shadow,
                                  blurRadius: 20,
                                  offset:
                                  const Offset(
                                    0,
                                    8,
                                  ),
                                ),
                              ],
                              border: Border.all(
                                color: AppColors.primary
                                    .withValues(alpha: .15),
                                width: 2,
                              ),
                            ),
                            child: CustomPaint(
                              painter:
                              _ClockPainter(
                                time: _currentTime,
                                primaryColor:
                                AppColors.primary,
                              ),
                            ),
                          )
                              .animate()
                              .fade(
                            duration: 700.ms,
                          )
                              .scale(),

                          const SizedBox(height: 6),

                          Text(
                            _formatTime(),
                            style: TextStyle(
                              color:
                              AppColors.primary,
                              fontWeight:
                              FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // =================================================
                      // زر القائمة - الطرف المقابل
                      // =================================================

                      Builder(
                        builder: (context) {
                          return Container(
                            width: 54,
                            height: 54,
                            decoration:
                            BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(
                                16,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                  AppColors.shadow,
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.menu_rounded,
                                size: 29,
                              ),
                              color:
                              AppColors.primary,
                              onPressed: () {
                                Scaffold.of(context)
                                    .openDrawer();
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // =================================================
                  // عنوان الصفحة
                  // =================================================

                  Text(
                    _tr('appTitle'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  )
                      .animate()
                      .fade(delay: 250.ms)
                      .slideY(begin: -.4),

                  const SizedBox(height: 4),

                  Text(
                    _tr('electronicServices'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.subtitle,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 2),

                  // =================================================
                  // صورة المحطة - أقرب إلى عنوان الخدمات وأقصر
                  // حتى يظهر الإعلان بوضوح على الشاشة الرئيسية
                  // =================================================

                  Container(
                    width: double.infinity,
                    height: 135,
                    margin: const EdgeInsets.only(
                      top: 0,
                      bottom: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: .18),
                          blurRadius: 22,
                          offset:
                          const Offset(0, 12),
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage(
                          "assets/images/default_station.png",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                      .animate()
                      .fade(duration: 700.ms)
                      .scale(
                    begin:
                    const Offset(.95, .95),
                  )
                      .slideY(begin: .15),

                  const SizedBox(height: 2),

                  // =================================================
                  // دخول المواطن - تصميم مدمج
                  // =================================================

                  RoleCard(
                    icon: Icons.public,
                    title: _tr('citizenEntry'),
                    subtitle:
                    _tr('citizenEntrySubtitle'),
                    color: AppColors.primary,
                    compact: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const CitizenScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 4),

                  // =================================================
                  // الإعلانات التجارية المتحركة
                  // دخول النظام أصبح زرًا صغيرًا أعلى يسار الساعة
                  // =================================================

                  const CommercialAdBanner(
                    placement: 'home',
                  ),

                  const SizedBox(height: 8),

                  // =================================================
                  // حالة النظام
                  // =================================================

                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color:
                          AppColors.shadow,
                          blurRadius: 18,
                          offset:
                          const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [

                        Container(
                          width: 55,
                          height: 55,
                          decoration:
                          BoxDecoration(
                            color: AppColors
                                .success
                                .withValues(alpha: .12),
                            borderRadius:
                            BorderRadius
                                .circular(16),
                          ),
                          child: const Icon(
                            Icons
                                .check_circle_rounded,
                            color:
                            AppColors.success,
                            size: 32,
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [

                              Text(
                                _tr('systemStatus'),
                                style: TextStyle(
                                  fontWeight:
                                  FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),

                              SizedBox(height: 5),

                              Text(
                                _tr('allServicesNormal'),
                                style: TextStyle(
                                  color:
                                  AppColors.subtitle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fade(delay: 800.ms)
                      .slideY(begin: .25),

                  const SizedBox(height: 20),

                  // =================================================
// الإحصائيات
// =================================================

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.local_gas_station_rounded,
                          color: AppColors.primary,
                          title: _tr('stations'),
                          value: _stationsCount.toString(),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.oil_barrel,
                          color: AppColors.secondary,
                          title: _tr('products'),
                          value: "6",
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.people_alt_rounded,
                          color: AppColors.info,
                          title: _tr('users'),
                          value: _usersCount.toString(),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.update,
                          color: AppColors.success,
                          title: _tr('lastUpdate'),
                          value: _tr('now'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // بطاقة الإحصائيات
  // ===============================================================
  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Container(
      height: 118,
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: .10),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .10),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // الأيقونة
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),

          const SizedBox(height: 7),

          // الرقم
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),

          const SizedBox(height: 3),

          // العنوان
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              maxLines: 1,
              style: const TextStyle(
                color: AppColors.subtitle,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fade()
        .scale(
      begin: const Offset(.92, .92),
      duration: 400.ms,
    );
  }
}

// ===================================================================
// الساعة الدائرية
// ===================================================================

class _ClockPainter extends CustomPainter {
  final DateTime time;
  final Color primaryColor;

  _ClockPainter({
    required this.time,
    required this.primaryColor,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final center =
    Offset(size.width / 2, size.height / 2);

    final radius =
        size.width / 2;

    // خلفية الساعة
    final facePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center,
      radius,
      facePaint,
    );

    // إطار الساعة
    final borderPaint = Paint()
      ..color = primaryColor.withValues(alpha: .35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(
      center,
      radius - 2,
      borderPaint,
    );

    // علامات الساعة
    final markPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final angle =
          (i * 30 - 90) *
              3.1415926535 /
              180;

      final outer = Offset(
        center.dx +
            (radius - 9) *
                _cos(angle),
        center.dy +
            (radius - 9) *
                _sin(angle),
      );

      final inner = Offset(
        center.dx +
            (radius - 15) *
                _cos(angle),
        center.dy +
            (radius - 15) *
                _sin(angle),
      );

      canvas.drawLine(
        inner,
        outer,
        markPaint,
      );
    }

    // عقرب الساعات
    final hourAngle =
        ((time.hour % 12) +
            time.minute / 60) *
            30 *
            3.1415926535 /
            180 -
            3.1415926535 / 2;

    final hourHandPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      center,
      Offset(
        center.dx +
            radius *
                .42 *
                _cos(hourAngle),
        center.dy +
            radius *
                .42 *
                _sin(hourAngle),
      ),
      hourHandPaint,
    );

    // عقرب الدقائق
    final minuteAngle =
        (time.minute +
            time.second / 60) *
            6 *
            3.1415926535 /
            180 -
            3.1415926535 / 2;

    final minuteHandPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      center,
      Offset(
        center.dx +
            radius *
                .58 *
                _cos(minuteAngle),
        center.dy +
            radius *
                .58 *
                _sin(minuteAngle),
      ),
      minuteHandPaint,
    );

    // عقرب الثواني
    final secondAngle =
        time.second *
            6 *
            3.1415926535 /
            180 -
            3.1415926535 / 2;

    final secondHandPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      center,
      Offset(
        center.dx +
            radius *
                .63 *
                _cos(secondAngle),
        center.dy +
            radius *
                .63 *
                _sin(secondAngle),
      ),
      secondHandPaint,
    );

    // مركز العقارب
    final centerPaint = Paint()
      ..color = primaryColor;

    canvas.drawCircle(
      center,
      5,
      centerPaint,
    );

    final centerDotPaint = Paint()
      ..color = Colors.white;

    canvas.drawCircle(
      center,
      2,
      centerDotPaint,
    );
  }

  double _cos(double value) {
    return _cosine(value);
  }

  double _sin(double value) {
    return _sine(value);
  }

  @override
  bool shouldRepaint(
      covariant _ClockPainter oldDelegate,
      ) {
    return oldDelegate.time != time ||
        oldDelegate.primaryColor !=
            primaryColor;
  }
}

// ===================================================================
// دوال رياضية بسيطة للساعة
// ===================================================================

double _cosine(double value) {
  return _cosTable(value);
}

double _sine(double value) {
  return _sinTable(value);
}

// استخدام dart:math بدون الحاجة لإضافة أي package
double _cosTable(double value) {
  // تقريب آمن للقيم الخاصة بالساعة
  return _taylorCos(value);
}

double _sinTable(double value) {
  return _taylorSin(value);
}

double _taylorCos(double x) {
  while (x > 3.1415926535) {
    x -= 2 * 3.1415926535;
  }

  while (x < -3.1415926535) {
    x += 2 * 3.1415926535;
  }

  final x2 = x * x;

  return 1 -
      x2 / 2 +
      (x2 * x2) / 24 -
      (x2 * x2 * x2) / 720 +
      (x2 * x2 * x2 * x2) / 40320;
}

double _taylorSin(double x) {
  while (x > 3.1415926535) {
    x -= 2 * 3.1415926535;
  }

  while (x < -3.1415926535) {
    x += 2 * 3.1415926535;
  }

  final x2 = x * x;

  return x -
      (x * x2) / 6 +
      (x * x2 * x2) / 120 -
      (x * x2 * x2 * x2) / 5040 +
      (x * x2 * x2 * x2 * x2) / 362880;
}
