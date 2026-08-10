import 'package:flutter/material.dart';
import '../../screens/manager/products_screen.dart';
import '../../screens/manager/reports_screen.dart';
import '../../screens/manager/notifications_screen.dart';
import '../../screens/manager/supply_requests_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
class ManagerDrawer extends StatelessWidget {
  const ManagerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0B3C6D),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 42,
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  "assets/images/logo.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "شركة توزيع المنتجات النفطية",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "لوحة تحكم مدير المحطة",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 30),

            _drawerItem(
              icon: Icons.dashboard_rounded,
              title: "الرئيسية",
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),

            _drawerItem(
              icon: Icons.local_gas_station_rounded,
              title: "المنتجات",
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProductsScreen(),
                  ),
                );
              },
            ),

            _drawerItem(
              icon: Icons.local_shipping_rounded,
              title: "طلبات التزويد",
              onTap: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("سيتم إنشاء شاشة طلبات التزويد لاحقًا"),
                  ),
                );
              },
            ),

            _drawerItem(
              icon: Icons.bar_chart_rounded,
              title: "التقارير",
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReportsScreen(),
                  ),
                );
              },
            ),

            _drawerItem(
              icon: Icons.notifications_active_rounded,
              title: "الإشعارات",
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationsScreen(
                      userId: FirebaseAuth.instance.currentUser!.uid,
                    ),
                  ),
                );
              },
            ),

            _drawerItem(
              icon: Icons.people_alt_rounded,
              title: "الموظفون",
              onTap: () {},
            ),

            _drawerItem(
              icon: Icons.settings_rounded,
              title: "الإعدادات",
              onTap: () {},
            ),

            const Spacer(),

            const Divider(
              color: Colors.white24,
              indent: 20,
              endIndent: 20,
            ),

            _drawerItem(
              icon: Icons.logout_rounded,
              title: "تسجيل الخروج",
              color: Colors.redAccent,
              onTap: () {},
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
    Color color = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      child: Material(
        color: selected
            ? Colors.white.withOpacity(.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          leading: Icon(
            icon,
            color: color,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}