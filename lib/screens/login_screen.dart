import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../core/constants/user_roles.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/auth_service.dart';
import '../services/station_service.dart';
import '../screens/station_manager_dashboard.dart';
import 'password_reset_request_screen.dart';
import 'home_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  String _appVersion = '';

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();

    if (!mounted) return;

    setState(() {
      _appVersion = info.version;
    });
  }
  String _tr(String key) {
    final lang = Localizations.localeOf(context).languageCode;

    const translations = <String, Map<String, String>>{
      'ar': {
        'invalidCredentials': 'اسم المستخدم أو كلمة المرور غير صحيحة',
        'unknownRole': 'صلاحية غير معرفة',
        'appName': 'نافذة المنتوج النفطي',
        'motto': 'خدمة المواطن مسؤولية، وحماية المصلحة العامة أمانة',
        'anbarBranch': 'فرع الأنبار',
        'login': 'تسجيل الدخول',
        'username': 'اسم المستخدم',
        'enterUsername': 'أدخل اسم المستخدم',
        'usernameRequired': 'ادخل اسم المستخدم',
        'password': 'كلمة المرور',
        'enterPassword': 'أدخل كلمة المرور',
        'passwordRequired': 'ادخل كلمة المرور',
        'forgotPassword': 'نسيت كلمة المرور؟',
        'registerNewStation': 'تسجيل محطة جديدة',
        'registerStationSubtitle': 'لإضافة محطة جديدة إلى النظام',
        'secureReliable': 'آمن وموثوق',
        'nearestStation': 'أقرب محطة',
        'instantNotifications': 'تنبيهات فورية',
        'versionText': 'نافذة المنتوج النفطي • الإصدار',
        'securityDescription':
        'نظام نافذة المنتوج النفطي يعتمد على نظام صلاحيات لتحديد وصول المستخدمين، مع حماية بيانات النظام وتنظيم الوصول حسب نوع المستخدم.',
        'close': 'إغلاق',
      },
      'en': {
        'invalidCredentials': 'Incorrect username or password',
        'unknownRole': 'Unknown role',
        'appName': 'Oil Product Window',
        'motto': 'Serving citizens is a responsibility, and protecting the public interest is a trust',
        'anbarBranch': 'Anbar Branch',
        'login': 'Login',
        'username': 'Username',
        'enterUsername': 'Enter username',
        'usernameRequired': 'Please enter username',
        'password': 'Password',
        'enterPassword': 'Enter password',
        'passwordRequired': 'Please enter password',
        'forgotPassword': 'Forgot password?',
        'registerNewStation': 'Register New Station',
        'registerStationSubtitle': 'Add a new station to the system',
        'secureReliable': 'Secure & Reliable',
        'nearestStation': 'Nearest Station',
        'instantNotifications': 'Instant Notifications',
        'versionText': 'Oil Product Window • Version',
        'securityDescription':
        'The Oil Product Window uses a permissions system to control user access, protect system data, and organize access according to user type.',
        'close': 'Close',
      },
      'ku': {
        'invalidCredentials': 'ناوی بەکارهێنەر یان وشەی نهێنی هەڵەیە',
        'unknownRole': 'دەسەڵات ناسراو نییە',
        'appName': 'پەنجەرەی بەرهەمی نەوتی',
        'motto': 'خزمەتکردنی هاووڵاتی بەرپرسیارییە، و پاراستنی بەرژەوەندی گشتی ئەمانەتە',
        'anbarBranch': 'لقی ئەنبار',
        'login': 'چوونەژوورەوە',
        'username': 'ناوی بەکارهێنەر',
        'enterUsername': 'ناوی بەکارهێنەر بنووسە',
        'usernameRequired': 'تکایە ناوی بەکارهێنەر بنووسە',
        'password': 'وشەی نهێنی',
        'enterPassword': 'وشەی نهێنی بنووسە',
        'passwordRequired': 'تکایە وشەی نهێنی بنووسە',
        'forgotPassword': 'وشەی نهێنیت لەبیر کردووە؟',
        'registerNewStation': 'تۆمارکردنی بەنزینخانەی نوێ',
        'registerStationSubtitle': 'بۆ زیادکردنی بەنزینخانەیەکی نوێ بۆ سیستەم',
        'secureReliable': 'پارێزراو و متمانەپێکراو',
        'nearestStation': 'نزیکترین بەنزینخانە',
        'instantNotifications': 'ئاگادارکردنەوەی دەستبەجێ',
        'versionText': 'پەنجەرەی بەرهەمی نەوتی • وەشان',
        'securityDescription':
        'سیستەمی پەنجەرەی بەرهەمی نەوتی پشت بە سیستەمی دەسەڵات دەبەستێت بۆ دیاریکردنی دەستگەیشتنی بەکارهێنەران، پاراستنی داتاکانی سیستەم و ڕێکخستنی دەستگەیشتن بەپێی جۆری بەکارهێنەر.',
        'close': 'داخستن',
      },
      'fa': {
        'invalidCredentials': 'نام کاربری یا رمز عبور نادرست است',
        'unknownRole': 'نقش ناشناخته',
        'appName': 'پنجره محصولات نفتی',
        'motto': 'خدمت به شهروند مسئولیت است و حفاظت از منافع عمومی امانت',
        'anbarBranch': 'شعبه الانبار',
        'login': 'ورود',
        'username': 'نام کاربری',
        'enterUsername': 'نام کاربری را وارد کنید',
        'usernameRequired': 'لطفاً نام کاربری را وارد کنید',
        'password': 'رمز عبور',
        'enterPassword': 'رمز عبور را وارد کنید',
        'passwordRequired': 'لطفاً رمز عبور را وارد کنید',
        'forgotPassword': 'رمز عبور را فراموش کرده‌اید؟',
        'registerNewStation': 'ثبت جایگاه جدید',
        'registerStationSubtitle': 'برای افزودن جایگاه جدید به سیستم',
        'secureReliable': 'امن و قابل اعتماد',
        'nearestStation': 'نزدیک‌ترین جایگاه',
        'instantNotifications': 'اعلان‌های فوری',
        'versionText': 'پنجره محصولات نفتی • نسخه',
        'securityDescription':
        'سامانه پنجره محصولات نفتی از سیستم مجوزها برای تعیین دسترسی کاربران، حفاظت از داده‌های سیستم و سازمان‌دهی دسترسی بر اساس نوع کاربر استفاده می‌کند.',
        'close': 'بستن',
      },
    };

    return translations[lang]?[key] ?? translations['ar']![key] ?? key;
  }

  TextDirection get _textDirection =>
      Localizations.localeOf(context).languageCode == 'en'
          ? TextDirection.ltr
          : TextDirection.rtl;
  final formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool hidePassword = true;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _loadAppVersion();

    // حركة الحلقة الضوئية
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
  }

  // =========================================================
  // تسجيل الدخول
  // =========================================================

  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    final user = await AuthService.instance.login(
      username: usernameController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      loading = false;
    });

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr('invalidCredentials'),
            textDirection: _textDirection,
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // =========================================================
    // توجيه المستخدم حسب الصلاحية
    // =========================================================

    debugPrint("ROLE FROM FIREBASE = ${user.role}");

    switch (UserRoles.normalize(user.role)) {
      case UserRoles.admin:
        Navigator.pushReplacementNamed(
          context,
          "/admin",
        );
        break;

      case UserRoles.branchManager:
        Navigator.pushReplacementNamed(
          context,
          "/branch",
        );
        break;

      case "station":
      case UserRoles.stationManager:
        final station = await StationService.instance.getStation(
          user.stationId,
        );

        if (!mounted) {
          return;
        }

        if (station != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => StationManagerDashboard(
                station: station,
              ),
            ),
          );
        }
        break;

      case "employee":
        Navigator.pushReplacementNamed(
          context,
          "/employee",
        );
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${_tr('unknownRole')}: ${user.role}",
              textDirection: _textDirection,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF3F7F4),
      body: SafeArea(
        child: Directionality(
          textDirection: _textDirection,
          child: Stack(
            children: [
              // =====================================================
              // خلفية متحركة جديدة - لا تؤثر على أي وظيفة
              // =====================================================
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _SoftAnimatedBackgroundPainter(
                        progress: _animationController.value,
                      ),
                    );
                  },
                ),
              ),

              // طبقة هادئة فوق الخلفية
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.34),
                        const Color(0xFFF3F7F4).withValues(alpha: 0.72),
                        const Color(0xFFE8F0EB).withValues(alpha: 0.88),
                      ],
                    ),
                  ),
                ),
              ),

              // =====================================================
              // المحتوى الرئيسي
              // =====================================================
              LayoutBuilder(
                builder: (context, constraints) {
                  final keyboardVisible =
                      MediaQuery.viewInsetsOf(context).bottom > 0;

                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      18,
                      keyboardVisible ? 12 : 22,
                      18,
                      keyboardVisible ? 28 : 24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 620,
                        ),
                        child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // =================================================
                              // الشعار والحركة
                              // =================================================
                              SizedBox(
                                width: keyboardVisible ? 112 : 158,
                                height: keyboardVisible ? 112 : 158,
                                child: AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return CustomPaint(
                                      painter: _GlowRingPainter(
                                        progress:
                                        _animationController.value,
                                      ),
                                      child: child,
                                    );
                                  },
                                  child: Center(
                                    child: Container(
                                      width: keyboardVisible ? 68 : 94,
                                      height: keyboardVisible ? 68 : 94,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF0F766E),
                                            Color(0xFF064E3B),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: const Color(0xFFD5B45A),
                                          width: 2.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF0F766E)
                                                .withValues(alpha: 0.24),
                                            blurRadius: 28,
                                            spreadRadius: 3,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.local_gas_station_rounded,
                                        color: const Color(0xFFF7E7B0),
                                        size: keyboardVisible ? 36 : 48,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                _tr('appName'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF12372A),
                                  fontSize: 29,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                _tr('motto'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF0F766E),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                _tr('anbarBranch'),
                                style: const TextStyle(
                                  color: Color(0xFF9A741E),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 18),

                              // =================================================
                              // صندوق تسجيل الدخول
                              // =================================================
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(
                                  18,
                                  20,
                                  18,
                                  18,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.94),
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: const Color(0xFF0F766E)
                                        .withValues(alpha: 0.18),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF164E3B)
                                          .withValues(alpha: 0.12),
                                      blurRadius: 28,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: AlignmentDirectional.centerStart,
                                      child: Text(
                                        _tr('login'),
                                        style: const TextStyle(
                                          color: Color(0xFF12372A),
                                          fontSize: 23,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    _buildInput(
                                      controller: usernameController,
                                      label: _tr('username'),
                                      hint: _tr('enterUsername'),
                                      icon: Icons.person_outline_rounded,
                                      validator: (v) {
                                        if (v == null ||
                                            v.trim().isEmpty) {
                                          return _tr('usernameRequired');
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 15),

                                    _buildInput(
                                      controller: passwordController,
                                      label: _tr('password'),
                                      hint: _tr('enterPassword'),
                                      icon: Icons.lock_outline_rounded,
                                      obscureText: hidePassword,
                                      suffixIcon: IconButton(
                                        padding: const EdgeInsets.all(12),
                                        icon: Icon(
                                          hidePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: const Color(0xFF0F766E),
                                          size: 27,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            hidePassword = !hidePassword;
                                          });
                                        },
                                      ),
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return _tr('passwordRequired');
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 6),

                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  PasswordResetRequestScreen(
                                                    initialUsername:
                                                    usernameController.text.trim(),
                                                  ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.lock_reset_rounded,
                                          color: Color(0xFF0F766E),
                                          size: 23,
                                        ),
                                        label: Text(
                                          _tr('forgotPassword'),
                                          style: const TextStyle(
                                            color: Color(0xFF0F766E),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    SizedBox(
                                      width: double.infinity,
                                      height: 64,
                                      child: ElevatedButton(
                                        onPressed: loading ? null : login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                          const Color(0xFF0F766E),
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor:
                                          const Color(0xFF9AB8B0),
                                          elevation: 4,
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(18),
                                          ),
                                        ),
                                        child: loading
                                            ? const SizedBox(
                                          width: 28,
                                          height: 28,
                                          child:
                                          CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 3,
                                          ),
                                        )
                                            : Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _tr('login'),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight:
                                                FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Icon(
                                              Icons.login_rounded,
                                              size: 26,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 18),

                              // =================================================
                              // تسجيل محطة جديدة - نفس الإيعاز الأصلي
                              // =================================================
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color(0xFFD5B45A)
                                        .withValues(alpha: 0.55),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF7A5B16)
                                          .withValues(alpha: 0.08),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.local_gas_station_rounded,
                                      color: Color(0xFF0F766E),
                                      size: 40,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _tr('registerNewStation'),
                                      style: const TextStyle(
                                        color: Color(0xFF12372A),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _tr('registerStationSubtitle'),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Color(0xFF66736D),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            "/registerStation",
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.add_location_alt_outlined,
                                          size: 25,
                                        ),
                                        label: Text(
                                          _tr('registerNewStation'),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                          const Color(0xFF0F766E),
                                          side: const BorderSide(
                                            color: Color(0xFF0F766E),
                                            width: 1.5,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(16),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 18),

                              // =================================================
                              // المزايا الثلاثة - نفس الإيعازات الأصلية
                              // =================================================
                              Row(
                                children: [
                                  Expanded(
                                    child: _feature(
                                      Icons.security_rounded,
                                      _tr('secureReliable'),
                                      onTap: () {
                                        _showSecurityDialog(context);
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: _feature(
                                      Icons.location_on_outlined,
                                      _tr('nearestStation'),
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          "/citizen",
                                        );
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: _feature(
                                      Icons.notifications_none_rounded,
                                      _tr('instantNotifications'),
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          "/notifications",
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Text(
                                '${_tr('versionText')} ${_appVersion.isEmpty ? '...' : _appVersion}',
                                style: const TextStyle(
                                  color: Color(0xFF718078),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // =====================================================
              // زر الرجوع - نفس الإيعاز الأصلي
              // =====================================================
              Positioned(
                top: 6,
                right: 6,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF31554A),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) =>
                        const HomeScreen(),
                      ),
                          (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // حقل إدخال
  // =========================================================

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(
        color: Color(0xFF17352B),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      cursorColor: const Color(0xFF0F766E),
      textInputAction: label == _tr('username')
          ? TextInputAction.next
          : TextInputAction.done,
      decoration: InputDecoration(
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 20,
        ),
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          color: Color(0xFF0F766E),
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF9AA7A1),
          fontSize: 17,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            icon,
            color: const Color(0xFF0F766E),
            size: 29,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 64,
          minHeight: 64,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8FBF9),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: const Color(0xFF0F766E).withValues(alpha: 0.22),
            width: 1.4,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFF0F766E),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // المزايا الصغيرة
  // =========================================================

  Widget _feature(
      IconData icon,
      String title, {
        required VoidCallback onTap,
        bool compact = false,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: compact ? 4 : 10,
          horizontal: 4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 45 : 54,
              height: compact ? 45 : 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00D9FF).withValues(alpha: 0.08),
                border: Border.all(
                  color:
                  const Color(0xFF00D9FF).withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                    const Color(0xFF00D9FF).withValues(alpha: 0.12),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: const Color(0xFF00D9FF),
                size: compact ? 22 : 27,
              ),
            ),

            SizedBox(
              height: compact ? 4 : 8,
            ),

            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white70,
                fontSize: compact ? 10 : 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // نافذة الأمان
  // =========================================================

  void _showSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: _textDirection,
          child: AlertDialog(
            backgroundColor: const Color(0xFF061426),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.security_rounded,
                  color: Color(0xFF00D9FF),
                ),
                const SizedBox(width: 10),
                Text(
                  _tr('secureReliable'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              _tr('securityDescription'),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.7,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  _tr('close'),
                  style: const TextStyle(
                    color: Color(0xFF00D9FF),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

// =============================================================
// الخلفية المتحركة الهادئة
// =============================================================

class _SoftAnimatedBackgroundPainter extends CustomPainter {
  final double progress;

  _SoftAnimatedBackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 2 * math.pi;

    final paint = Paint()..style = PaintingStyle.fill;

    final points = <Offset>[
      Offset(
        size.width * 0.16 + math.sin(t) * 35,
        size.height * 0.16 + math.cos(t * 0.8) * 28,
      ),
      Offset(
        size.width * 0.82 + math.cos(t * 0.7) * 45,
        size.height * 0.30 + math.sin(t) * 35,
      ),
      Offset(
        size.width * 0.25 + math.cos(t * 0.55) * 55,
        size.height * 0.82 + math.sin(t * 0.8) * 35,
      ),
      Offset(
        size.width * 0.88 + math.sin(t * 0.65) * 35,
        size.height * 0.86 + math.cos(t) * 30,
      ),
    ];

    final colors = [
      const Color(0xFF0F766E),
      const Color(0xFF2F8F83),
      const Color(0xFFD5B45A),
      const Color(0xFF4B8B7D),
    ];

    for (int i = 0; i < points.length; i++) {
      paint.color = colors[i].withValues(alpha: i == 2 ? 0.12 : 0.09);
      canvas.drawCircle(points[i], size.width * 0.28, paint);
    }

    // موجتان ناعمتان متحركتان
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = const Color(0xFF0F766E).withValues(alpha: 0.10);

    for (int w = 0; w < 2; w++) {
      final path = Path();
      final yBase = size.height * (0.32 + w * 0.42);
      final amplitude = 18.0 + w * 7;

      path.moveTo(0, yBase);
      for (double x = 0; x <= size.width; x += 8) {
        final y = yBase +
            math.sin((x / size.width) * 2 * math.pi * 1.6 + t + w) *
                amplitude;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, wavePaint);
    }

    // نقاط ضوئية صغيرة تتحرك ببطء
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF0F766E).withValues(alpha: 0.13);

    for (int i = 0; i < 18; i++) {
      final x = ((i * 83.0) + progress * 75) %
          (size.width + 50) - 25;
      final y = ((i * 137.0) + math.sin(t + i) * 20) %
          (size.height + 40) - 20;
      final r = 1.5 + (i % 3) * 0.8;
      canvas.drawCircle(Offset(x, y), r, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SoftAnimatedBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// =============================================================
// رسم الحلقة الضوئية المتحركة
// =============================================================

class _GlowRingPainter extends CustomPainter {
  final double progress;

  _GlowRingPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.width / 2 - 18;

    const int segments = 48;

    for (int i = 0; i < segments; i++) {
      final baseAngle =
          (i / segments) * 2 * math.pi - math.pi / 2;

      final animatedAngle =
          baseAngle + (progress * 2 * math.pi);

      final startRadius = radius - 18;
      final endRadius = radius + 3;

      final start = Offset(
        center.dx +
            math.cos(animatedAngle) * startRadius,
        center.dy +
            math.sin(animatedAngle) * startRadius,
      );

      final end = Offset(
        center.dx +
            math.cos(animatedAngle) * endRadius,
        center.dy +
            math.sin(animatedAngle) * endRadius,
      );

      // =====================================================
      // حساب شدة الإضاءة
      // =====================================================

      double distance =
          ((i / segments) - progress) % 1.0;

      if (distance < 0) {
        distance += 1;
      }

      double glow = math.exp(
        -math.pow(distance / 0.13, 2),
      );

      // =====================================================
      // الإضاءة الأساسية
      // =====================================================

      double opacity =
          0.12 + (glow * 0.88);

      final paint = Paint()
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..color = Color.lerp(
          const Color(0xFF12324D),
          const Color(0xFF00E5FF),
          opacity,
        )!;

      // =====================================================
      // التوهج
      // =====================================================

      if (glow > 0.35) {
        paint
          ..strokeWidth = 9
          ..maskFilter = const MaskFilter.blur(
            BlurStyle.normal,
            6,
          );
      }

      canvas.drawLine(
        start,
        end,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
      covariant _GlowRingPainter oldDelegate,
      ) {
    return oldDelegate.progress != progress;
  }
}
