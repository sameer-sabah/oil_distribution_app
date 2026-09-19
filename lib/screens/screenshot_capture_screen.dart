import 'dart:async';

import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'login_screen.dart';
import 'citizen_screen.dart';
import 'settings_screen.dart';
import 'admin_screen.dart';
import 'branch_dashboard.dart';
import 'station_dashboard.dart';
import 'register_station_screen.dart';
import 'pending_stations_screen.dart';
import 'notifications_screen.dart';
import 'change_password_request_screen.dart';
import 'about_screen.dart';
import 'language_screen.dart';
import 'contact_screen.dart';
import 'rating_screen.dart';
import 'privacy_screen.dart';
import 'terms_screen.dart';
import 'commercial_ad_form_screen.dart';
import 'commercial_ads_screen.dart';
import 'my_commercial_ads_screen.dart';
import 'my_commercial_payments_screen.dart';
import 'internal_messages_screen.dart';
import 'products_screen.dart';
import 'reports_screen.dart';
import 'stations_screen.dart';

import 'admin/branches_screen.dart' as admin_branches;
import 'admin/users_screen.dart' as admin_users;
import 'admin/commercial_payment_settings_screen.dart' as zain_settings;
import 'admin/commercial_requests_screen.dart' as commercial_requests;
import 'admin/commercial_payments_screen.dart' as commercial_payments;
import 'admin/contact_messages_screen.dart' as contact_messages;
import 'admin/ratings_screen.dart' as admin_ratings;

import 'branch/branch_stations_screen.dart' as branch_stations;
import 'branch/quantity_tracking_screen.dart' as quantity_tracking;
import 'branch/users_screen.dart' as branch_users;

import 'station_folders_screen.dart' as station_folders;
import 'government_stations_screen.dart' as government_stations;
import 'private_stations_screen.dart' as private_stations;

class ScreenshotCaptureScreen extends StatefulWidget {
  const ScreenshotCaptureScreen({super.key});

  @override
  State<ScreenshotCaptureScreen> createState() =>
      _ScreenshotCaptureScreenState();
}

class _CaptureItem {
  final String name;
  final Widget Function() builder;

  const _CaptureItem(this.name, this.builder);
}

class _ScreenshotCaptureScreenState
    extends State<ScreenshotCaptureScreen> {
  static const Duration _initialDelay = Duration(seconds: 15);
  static const Duration _screenDuration = Duration(seconds: 5);

  late final List<_CaptureItem> _screens;
  Timer? _timer;
  int _index = 0;
  bool _started = false;

  @override
  void initState() {
    super.initState();

    _screens = <_CaptureItem>[
      _CaptureItem('00_home', () => const HomeScreen()),
      _CaptureItem('01_login', () => const LoginScreen()),
      _CaptureItem('02_citizen', () => const CitizenScreen()),
      _CaptureItem('03_settings', () => const SettingsScreen()),

      _CaptureItem('04_admin', () => const AdminScreen()),
      _CaptureItem(
        '05_admin_branches',
            () => const admin_branches.BranchesScreen(),
      ),
      _CaptureItem(
        '06_admin_users',
            () => const admin_users.UsersScreen(),
      ),
      _CaptureItem('07_products', () => const ProductsScreen()),
      _CaptureItem('08_reports', () => const ReportsScreen()),
      _CaptureItem(
        '09_zain_cash_settings',
            () => const zain_settings.CommercialPaymentSettingsScreen(),
      ),
      _CaptureItem(
        '10_commercial_requests',
            () => const commercial_requests.CommercialRequestsScreen(),
      ),
      _CaptureItem(
        '11_commercial_payments',
            () => const commercial_payments.CommercialPaymentsScreen(),
      ),
      _CaptureItem(
        '12_contact_messages',
            () => const contact_messages.ContactMessagesScreen(),
      ),
      _CaptureItem(
        '13_admin_ratings',
            () => const admin_ratings.RatingsScreen(),
      ),
      _CaptureItem(
        '14_internal_messages',
            () => const InternalMessagesScreen(),
      ),

      _CaptureItem('15_branch_dashboard', () => const BranchDashboard()),
      _CaptureItem(
        '16_branch_stations',
            () => const branch_stations.BranchStationsScreen(branchId: ''),
      ),
      _CaptureItem(
        '17_pending_stations',
            () => const PendingStationsScreen(),
      ),
      _CaptureItem(
        '18_quantity_tracking',
            () => const quantity_tracking.QuantityTrackingScreen(),
      ),
      _CaptureItem(
        '19_branch_users',
            () => const branch_users.UsersScreen(),
      ),

      _CaptureItem('20_station_dashboard', () => const StationDashboard()),
      _CaptureItem(
        '21_station_folders',
            () => const station_folders.StationFoldersScreen(branchId: ''),
      ),
      _CaptureItem(
        '22_government_stations',
            () => const government_stations.GovernmentStationsScreen(branchId: ''),
      ),
      _CaptureItem(
        '23_private_stations',
            () => const private_stations.PrivateStationsScreen(branchId: ''),
      ),
      _CaptureItem('24_stations', () => const StationsScreen()),

      _CaptureItem(
        '25_register_station',
            () => const RegisterStationScreen(),
      ),
      _CaptureItem(
        '26_change_password_request',
            () => const ChangePasswordRequestScreen(),
      ),
      _CaptureItem(
        '27_notifications',
            () => const NotificationsScreen(userId: ''),
      ),

      _CaptureItem(
        '28_commercial_ad_form',
            () => const CommercialAdFormScreen(),
      ),
      _CaptureItem(
        '29_commercial_ads',
            () => const CommercialAdsScreen(),
      ),
      _CaptureItem(
        '30_my_commercial_ads',
            () => const MyCommercialAdsScreen(),
      ),
      _CaptureItem(
        '31_my_commercial_payments',
            () => const MyCommercialPaymentsScreen(),
      ),

      _CaptureItem('32_about', () => const AboutScreen()),
      _CaptureItem('33_language', () => const LanguageScreen()),
      _CaptureItem('34_contact', () => const ContactScreen()),
      _CaptureItem('35_rating', () => const RatingScreen()),
      _CaptureItem('36_privacy', () => const PrivacyScreen()),
      _CaptureItem('37_terms', () => const TermsScreen()),
    ];

    Future<void>.delayed(_initialDelay, () {
      if (!mounted) return;

      setState(() {
        _started = true;
        _index = 0;
      });

      _timer = Timer.periodic(_screenDuration, (_) {
        if (!mounted) return;

        final next = _index + 1;
        if (next >= _screens.length) {
          _timer?.cancel();
          return;
        }

        setState(() {
          _index = next;
        });
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // قبل بدء العد التلقائي نعرض الصفحة الأولى نفسها.
    // هذا يعطي سكربت ADB وقتاً كافياً حتى يتأكد أن التطبيق اشتغل.
    final item = _screens[_started ? _index : 0];

    return KeyedSubtree(
      key: ValueKey<String>(item.name),
      child: item.builder(),
    );
  }
}
