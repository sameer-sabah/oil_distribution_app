import 'package:flutter/material.dart';

import '../../widgets/manager/manager_app_bar.dart';
import '../../widgets/manager/manager_drawer.dart';
import '../../widgets/manager/station_info_card.dart';
import '../../widgets/manager/statistics_cards.dart';
import '../../widgets/manager/fuel_products_card.dart';
import '../../widgets/manager/notifications_card.dart';
import '../../widgets/manager/sales_chart_card.dart';
import '../../widgets/manager/recent_orders_card.dart';
import '../../widgets/manager/quick_actions_card.dart';
import '../../widgets/manager/notes_card.dart';

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),

      // القائمة الجانبية
      drawer: const ManagerDrawer(),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: const [
              ManagerAppBar(),

              SizedBox(height: 20),

              StationInfoCard(),

              SizedBox(height: 20),

              StatisticsCards(),

              SizedBox(height: 20),

              FuelProductsCard(),

              SizedBox(height: 20),

              NotificationsCard(),

              SizedBox(height: 20),

              SalesChartCard(),

              SizedBox(height: 20),

              RecentOrdersCard(),

              SizedBox(height: 20),

              QuickActionsCard(),

              SizedBox(height: 20),

              NotesCard(),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}