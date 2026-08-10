import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/admin/admin_drawer.dart';

class AdminDashboardV2 extends StatelessWidget {
const AdminDashboardV2({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
drawer: const AdminDrawer(),
backgroundColor: AppColors.background,

appBar: AppBar(
elevation: 0,
centerTitle: true,
backgroundColor: AppColors.primary,
title: const Text(
"لوحة تحكم مدير النظام",
style: TextStyle(
fontWeight: FontWeight.bold,
color: Colors.white,
),
),
actions: [
IconButton(
icon: const Icon(
Icons.notifications_active,
color: Colors.white,
),
onPressed: () {},
),
],
),

body: SafeArea(
child: Padding(
padding: const EdgeInsets.all(20),

child: Column(
crossAxisAlignment: CrossAxisAlignment.start,

children: [

const SizedBox(height: 5),

const Text(
"مرحباً بك مدير النظام",
style: TextStyle(
fontSize: 28,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

const Text(
"يمكنك إدارة المحافظات والفروع والمحطات والمستخدمين.",
style: TextStyle(
color: Colors.grey,
fontSize: 15,
),
),

const SizedBox(height: 20),

Row(
children: [

Expanded(
child: _statCard(
"المحافظات",
"18",
Icons.map,
Colors.blue,
),
),

const SizedBox(width: 15),

Expanded(
child: _statCard(
"الفروع",
"18",
Icons.account_tree,
Colors.indigo,
),
),

const SizedBox(width: 15),

Expanded(
child: _statCard(
"المحطات",
"--",
Icons.local_gas_station,
Colors.green,
),
),

],
),

const SizedBox(height: 20),

Container(
padding: const EdgeInsets.all(18),

decoration: BoxDecoration(
color: Colors.white,

borderRadius:
BorderRadius.circular(22),

boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(.08),
blurRadius: 15,
offset: const Offset(0, 8),
),
],
),

child: const Row(
children: [

CircleAvatar(
radius: 28,
backgroundColor:
AppColors.primary,
child: Icon(
Icons.admin_panel_settings,
color: Colors.white,
),
),

SizedBox(width: 15),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [

Text(
"مدير النظام",
style: TextStyle(
fontWeight:
FontWeight.bold,
fontSize: 18,
),
),

SizedBox(height: 5),

Text(
"صلاحية كاملة لإدارة النظام.",
style: TextStyle(
color: Colors.grey,
),
),

],
),
),

],
),
),

const SizedBox(height: 20),

Expanded(
child: GridView.count(

crossAxisCount: 2,

crossAxisSpacing: 18,

mainAxisSpacing: 18,

childAspectRatio: .92,

children: [                    //====================================
// المحافظات
//====================================
_dashboardCard(
context,
Icons.map,
"المحافظات",
Colors.blue,
() {
// GovernoratesScreen
},
),

//====================================
// الفروع
//====================================
_dashboardCard(
context,
Icons.account_tree,
"الفروع",
Colors.indigo,
() {
// BranchesScreen
},
),

//====================================
// المحطات الحكومية
//====================================
_dashboardCard(
context,
Icons.local_gas_station,
"المحطات الحكومية",
Colors.green,
() {
// GovernmentStationsScreen
},
),

//====================================
// المحطات الأهلية
//====================================
_dashboardCard(
context,
Icons.store,
"المحطات الأهلية",
Colors.orange,
() {
// PrivateStationsScreen
},
),

//====================================
// المستخدمون
//====================================
_dashboardCard(
context,
Icons.people,
"المستخدمون",
Colors.deepPurple,
() {
// UsersScreen
},
),

//====================================
// المنتجات النفطية
//====================================
_dashboardCard(
context,
Icons.oil_barrel,
"المنتجات",
Colors.brown,
() {
// ProductsScreen
},
),

//====================================
// طلبات إنشاء المحطات
//====================================
_dashboardCard(
context,
Icons.app_registration,
"طلبات إنشاء المحطات",
Colors.teal,
() {
// StationRequestsScreen
},
),

//====================================
// طلبات تغيير كلمة السر
//====================================
_dashboardCard(
context,
Icons.lock_reset,
"طلبات تغيير كلمة السر",
Colors.red,
() {
// PasswordRequestsScreen
},
),

//====================================
// الإشعارات
//====================================
_dashboardCard(
context,
Icons.notifications_active,
"الإشعارات",
Colors.deepOrange,
() {
// NotificationsScreen
},
),

//====================================
// التقارير
//====================================
_dashboardCard(
context,
Icons.bar_chart,
"التقارير",
Colors.green,
() {
// ReportsScreen
},
),

//====================================
// الإعدادات
//====================================
_dashboardCard(
context,
Icons.settings,
"الإعدادات",
Colors.grey,
() {
// SettingsScreen
},
),

//====================================
// تسجيل الخروج
//====================================
_dashboardCard(
context,
Icons.logout,
"تسجيل الخروج",
Colors.black87,
() {
Navigator.pop(context);
},
),
],
),
),

const SizedBox(height: 15),

Container(
width: double.infinity,
padding: const EdgeInsets.all(15),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(18),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(.08),
blurRadius: 10,
offset: const Offset(0, 5),
),
],
),
child: Row(
children: [
const Icon(
Icons.info_outline,
color: AppColors.primary,
),

const SizedBox(width: 10),

Expanded(
child: Text(
"الإصدار 1.0.0   |   آخر تحديث: ${DateTime.now().toString().substring(0, 10)}",
style: const TextStyle(
color: Colors.grey,
),
),
),
],
),
),
],
),
),
),
);
}

//==================================================
// Dashboard Card
//==================================================

Widget _dashboardCard(
BuildContext context,
IconData icon,
String title,
Color color,
VoidCallback onTap,
) {
return InkWell(
onTap: onTap,
borderRadius: BorderRadius.circular(22),
child: Container(
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(22),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(.08),
blurRadius: 15,
offset: const Offset(0, 8),
),
],
),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
CircleAvatar(
radius: 32,
backgroundColor: color.withOpacity(.12),
child: Icon(
icon,
color: color,
size: 34,
),
),

const SizedBox(height: 16),

Padding(
padding: const EdgeInsets.symmetric(horizontal: 8),
child: Text(
title,
textAlign: TextAlign.center,
style: const TextStyle(
fontWeight: FontWeight.bold,
fontSize: 16,
),
),
),
],
),
),
);
}
  //==================================================
  // Statistics Card
  //==================================================

  Widget _statCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [

          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(.12),

            child: Icon(
              icon,
              color: color,
              size: 26,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),

        ],
      ),
    );
  }
}