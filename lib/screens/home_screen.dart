import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';
import '../widgets/app_drawer.dart';
import '../widgets/role_card.dart';

import 'citizen_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
const HomeScreen({super.key});
@override
Widget build(BuildContext context) {

final size = MediaQuery.of(context).size;


return Scaffold(
  drawerEnableOpenDragGesture: true,
  drawer: const AppDrawer(),
backgroundColor: AppColors.background,

body: Stack(
children: [

/// ===========================
/// الخلفية المتحركة
/// ===========================

Positioned(
top: -140,
right: -120,
child: Container(
width: 320,
height: 320,
decoration: BoxDecoration(
shape: BoxShape.circle,
color: AppColors.primary.withOpacity(.08),
),
)
.animate(
onPlay: (c) => c.repeat(reverse: true),
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
color: AppColors.secondary.withOpacity(.08),
),
)
.animate(
onPlay: (c) => c.repeat(reverse: true),
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
color: Colors.green.withOpacity(.04),
),
)
.animate(
onPlay: (c) => c.repeat(reverse: true),
)
.moveY(
begin: -10,
end: 20,
duration: 7.seconds,
),
),

SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.symmetric(
horizontal: 22,
vertical: 18,
),

child: Column(
crossAxisAlignment: CrossAxisAlignment.center,
children: [

///=========================
/// APP BAR
///=========================

Row(
children: [

Builder(
builder: (context) {
return Container(
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(16),
boxShadow: [
BoxShadow(
color: AppColors.shadow,
blurRadius: 15,
)
],
),
child: IconButton(
icon: const Icon(Icons.menu_rounded),
color: AppColors.primary,
onPressed: () {
Scaffold.of(context).openDrawer();
},
),
);
},
),

const Spacer(),

Hero(
tag: "logo",
child: Container(
padding: const EdgeInsets.all(8),
decoration: BoxDecoration(
color: Colors.white,
shape: BoxShape.circle,
boxShadow: [
BoxShadow(
color: AppColors.shadow,
blurRadius: 20,
)
],
),
child: Image.asset(
"assets/images/logo.png",
width: 85,
),
),
)
.animate()
.fade(duration: 700.ms)
.scale(),

const Spacer(),

Container(
width: 48,
),
],
),

const SizedBox(height: 22),

Text(
"شركة توزيع المنتجات النفطية",
textAlign: TextAlign.center,
style: TextStyle(
color: AppColors.text,
fontWeight: FontWeight.bold,
fontSize: 28,
),
)
.animate()
.fade(delay: 250.ms)
.slideY(begin: -.4),

const SizedBox(height: 8),

Text(
"نافذة المنتوج النفطي",
style: TextStyle(
color: AppColors.subtitle,
fontSize: 18,
),
),

const SizedBox(height: 28),

  Container(
    width: double.infinity,
    height: 250,
    margin: const EdgeInsets.only(top: 15, bottom: 30),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.18),
          blurRadius: 22,
          offset: const Offset(0, 12),
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
      .scale(begin: const Offset(.95, .95))
      .slideY(begin: .15),

  const SizedBox(height: 30),          ///=========================
/// بطاقة دخول المواطن
///=========================

  RoleCard(
    icon: Icons.public,
    title: "دخول المواطن",
    subtitle: "استعراض المحطات، الكميات، الملاحة، وأقرب محطة",
    color: AppColors.primary,
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CitizenScreen(),
        ),
      );
    },
  ),

  const SizedBox(height: 18),

  RoleCard(
    icon: Icons.admin_panel_settings_rounded,
    title: "دخول النظام",
    subtitle: "تسجيل الدخول لجميع مستخدمي النظام حسب الصلاحيات",
    color: AppColors.secondary,
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    },
  ),
const SizedBox(height: 30),

///=========================
/// حالة النظام
///=========================

Container(
width: double.infinity,
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(24),
boxShadow: [
BoxShadow(
color: AppColors.shadow,
blurRadius: 18,
offset: const Offset(0, 8),
),
],
),

child: Row(
children: [

Container(
width: 55,
height: 55,
decoration: BoxDecoration(
color: AppColors.success.withOpacity(.12),
borderRadius: BorderRadius.circular(16),
),
child: const Icon(
Icons.check_circle_rounded,
color: AppColors.success,
size: 32,
),
),

const SizedBox(width: 15),

const Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

Text(
"حالة النظام",
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 18,
),
),

SizedBox(height: 5),

Text(
"جميع الخدمات تعمل بصورة طبيعية.",
style: TextStyle(
color: AppColors.subtitle,
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

const SizedBox(height: 20),                  ///=========================
  /// الإحصائيات
  ///=========================

  Row(
    children: [

      Expanded(
        child: _buildStatCard(
          icon: Icons.local_gas_station_rounded,
          color: AppColors.primary,
          title: "المحطات",
          value: "245",
        ),
      ),

      const SizedBox(width: 15),

      Expanded(
        child: _buildStatCard(
          icon: Icons.oil_barrel,
          color: AppColors.secondary,
          title: "المنتجات",
          value: "5",
        ),
      ),

    ],
  ),

  const SizedBox(height: 15),

  Row(
    children: [

      Expanded(
        child: _buildStatCard(
          icon: Icons.people_alt_rounded,
          color: AppColors.info,
          title: "المستخدمون",
          value: "1,250",
        ),
      ),

      const SizedBox(width: 15),

      Expanded(
        child: _buildStatCard(
          icon: Icons.update,
          color: AppColors.success,
          title: "آخر تحديث",
          value: "الآن",
        ),
      ),

    ],
  ),

  const SizedBox(height: 25),

  ///=========================
  /// معلومات التطبيق
  ///=========================

  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),

    child: Column(
      children: [

        Icon(
          Icons.verified,
          color: AppColors.primary,
          size: 45,
        ),

        const SizedBox(height: 10),

        const Text(
          "شركة توزيع المنتجات النفطية",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          "نافذة المنتوج النفطي",
          style: TextStyle(
            color: AppColors.subtitle,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 15),

        const Divider(),

        const SizedBox(height: 10),

        const Text(
          "الإصدار 1.0.0",
          style: TextStyle(
            color: AppColors.subtitle,
          ),
        ),
      ],
    ),
  )
      .animate()
      .fade(delay: 1000.ms)
      .slideY(begin: .30),

  const SizedBox(height: 35),

],
),
),
),
],
),
);
}

Widget _buildStatCard({
  required IconData icon,
  required Color color,
  required String title,
  required String value,
}) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    ),

    child: Column(
      children: [

        CircleAvatar(
          radius: 26,
          backgroundColor: color.withOpacity(.12),
          child: Icon(
            icon,
            color: color,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          title,
          style: const TextStyle(
            color: AppColors.subtitle,
          ),
        ),

      ],
    ),
  )
      .animate()
      .fade()
      .scale();
}
}