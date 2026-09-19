import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:oil_distribution_app/firebase_options.dart';
import 'package:oil_distribution_app/l10n/app_localizations.dart';
import 'package:oil_distribution_app/main.dart' as app_main;
import 'package:oil_distribution_app/theme/app_theme.dart';

// الشاشات الأساسية
import 'package:oil_distribution_app/screens/home_screen.dart';
import 'package:oil_distribution_app/screens/login_screen.dart';
import 'package:oil_distribution_app/screens/settings_screen.dart';
import 'package:oil_distribution_app/screens/admin_screen.dart';
import 'package:oil_distribution_app/screens/citizen_screen.dart';
import 'package:oil_distribution_app/screens/station_dashboard.dart';
import 'package:oil_distribution_app/screens/register_station_screen.dart';
import 'package:oil_distribution_app/screens/pending_stations_screen.dart';
import 'package:oil_distribution_app/screens/notifications_screen.dart';
import 'package:oil_distribution_app/screens/branch_dashboard.dart';
import 'package:oil_distribution_app/screens/distribution/approve_requests_screen.dart';
import 'package:oil_distribution_app/screens/employee/employee_dashboard.dart';
import 'package:oil_distribution_app/screens/change_password_request_screen.dart';
import 'package:oil_distribution_app/screens/about_screen.dart';
import 'package:oil_distribution_app/screens/language_screen.dart';
import 'package:oil_distribution_app/screens/contact_screen.dart';
import 'package:oil_distribution_app/screens/rating_screen.dart';
import 'package:oil_distribution_app/screens/privacy_screen.dart';
import 'package:oil_distribution_app/screens/terms_screen.dart';
import 'package:oil_distribution_app/screens/commercial_ad_form_screen.dart';
import 'package:oil_distribution_app/screens/commercial_ads_screen.dart';
import 'package:oil_distribution_app/screens/my_commercial_ads_screen.dart';
import 'package:oil_distribution_app/screens/my_commercial_payments_screen.dart';
import 'package:oil_distribution_app/screens/internal_messages_screen.dart';
import 'package:oil_distribution_app/screens/products_screen.dart';
import 'package:oil_distribution_app/screens/reports_screen.dart';

// شاشات مدير النظام
import 'package:oil_distribution_app/screens/admin/branches_screen.dart'
    as admin_branches;
import 'package:oil_distribution_app/screens/admin/commercial_payment_settings_screen.dart'
    as zain_settings;
import 'package:oil_distribution_app/screens/admin/commercial_requests_screen.dart'
    as commercial_requests;
import 'package:oil_distribution_app/screens/admin/commercial_payments_screen.dart'
    as commercial_payments;
import 'package:oil_distribution_app/screens/admin/contact_messages_screen.dart'
    as contact_messages;
import 'package:oil_distribution_app/screens/admin/ratings_screen.dart'
    as admin_ratings;
import 'package:oil_distribution_app/screens/admin/users_screen.dart'
    as admin_users;

// شاشات مدير الفرع
import 'package:oil_distribution_app/screens/branch/branch_stations_screen.dart'
    as branch_stations;
import 'package:oil_distribution_app/screens/branch/quantity_tracking_screen.dart'
    as quantity_tracking;
import 'package:oil_distribution_app/screens/branch/users_screen.dart'
    as branch_users;

// شاشات المحطات
import 'package:oil_distribution_app/screens/station_folders_screen.dart'
    as station_folders;
import 'package:oil_distribution_app/screens/government_stations_screen.dart'
    as government_stations;
import 'package:oil_distribution_app/screens/private_stations_screen.dart'
    as private_stations;
import 'package:oil_distribution_app/screens/stations_screen.dart'
    as stations_list;

final binding =
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

class ScreenshotApp extends StatelessWidget {
  const ScreenshotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'نافذة المنتوج النفطي',
      locale: const Locale('ar'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        app_main.FallbackMaterialLocalizationsDelegate(),
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
        Locale('ku'),
        Locale('fa'),
        Locale('en'),
      ],
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      routes: {
        '/capture/login': (_) => const LoginScreen(),
        '/capture/settings': (_) => const SettingsScreen(),
        '/capture/admin': (_) => const AdminScreen(),
        '/capture/citizen': (_) => const CitizenScreen(),
        '/capture/station': (_) => const StationDashboard(),
        '/capture/employee': (_) => EmployeeDashboard(),
        '/capture/approveRequests': (_) => const ApproveRequestsScreen(),
        '/capture/changePassword': (_) => const ChangePasswordRequestScreen(),
        '/capture/registerStation': (_) => const RegisterStationScreen(),
        '/capture/pendingStations': (_) => const PendingStationsScreen(),
        '/capture/notifications': (_) => const NotificationsScreen(userId: ''),
        '/capture/about': (_) => const AboutScreen(),
        '/capture/language': (_) => const LanguageScreen(),
        '/capture/contact': (_) => const ContactScreen(),
        '/capture/rating': (_) => const RatingScreen(),
        '/capture/privacy': (_) => const PrivacyScreen(),
        '/capture/terms': (_) => const TermsScreen(),
        '/capture/adForm': (_) => const CommercialAdFormScreen(),
        '/capture/ads': (_) => const CommercialAdsScreen(),
        '/capture/myAds': (_) => const MyCommercialAdsScreen(),
        '/capture/myPayments': (_) => const MyCommercialPaymentsScreen(),
        '/capture/commercialRequests': (_) =>
            const commercial_requests.CommercialRequestsScreen(),
        '/capture/commercialPayments': (_) =>
            const commercial_payments.CommercialPaymentsScreen(),

        // مدير النظام
        '/capture/branches': (_) =>
            const admin_branches.BranchesScreen(),
        '/capture/zainSettings': (_) =>
            const zain_settings.CommercialPaymentSettingsScreen(),
        '/capture/contactMessages': (_) =>
            const contact_messages.ContactMessagesScreen(),
        '/capture/adminRatings': (_) =>
            const admin_ratings.RatingsScreen(),
        '/capture/adminUsers': (_) =>
            admin_users.UsersScreen(),
        '/capture/products': (_) => const ProductsScreen(),
        '/capture/reports': (_) => const ReportsScreen(),
        '/capture/internalMessages': (_) =>
            const InternalMessagesScreen(),

        // مدير الفرع
        '/capture/branch': (_) => const BranchDashboard(),
        '/capture/branchStations': (_) =>
            const branch_stations.BranchStationsScreen(branchId: ''),
        '/capture/quantityTracking': (_) =>
            const quantity_tracking.QuantityTrackingScreen(),
        '/capture/branchUsers': (_) =>
            const branch_users.UsersScreen(),

        // المحطات
        '/capture/stationFolders': (_) =>
            const station_folders.StationFoldersScreen(branchId: ''),
        '/capture/governmentStations': (_) =>
            const government_stations.GovernmentStationsScreen(branchId: ''),
        '/capture/privateStations': (_) =>
            const private_stations.PrivateStationsScreen(branchId: ''),
        '/capture/stationsList': (_) =>
            const stations_list.StationsScreen(),
      },
    );
  }
}

Future<void> _waitForScreen(WidgetTester tester) async {
  // لا نستخدم pumpAndSettle لأن بعض شاشات المشروع تحتوي
  // مؤقتات/حركات مستمرة مثل الإعلانات المتحركة.
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(seconds: 2));
}

Future<void> _captureCurrent(
  WidgetTester tester,
  String name,
) async {
  await _waitForScreen(tester);

  // إذا ظهر Exception من شاشة معينة نطبعه ونكمل باقي الشاشات.
  final error = tester.takeException();
  if (error != null) {
    debugPrint('SCREENSHOT WARNING [$name]: $error');
  }

  await binding.takeScreenshot(name);
}

Future<void> _openAndCapture(
  WidgetTester tester, {
  required String route,
  required String name,
}) async {
  final navigator =
      tester.state<NavigatorState>(find.byType(Navigator).first);

  await navigator.pushNamed(route);
  await _captureCurrent(tester, name);

  navigator.pop();
  await tester.pump(const Duration(milliseconds: 350));

  // تنظيف أي Exception متأخر حتى لا يوقف تصوير بقية الصفحات.
  tester.takeException();
}

void main() {
  testWidgets(
    'تصوير شاشات نافذة المنتوج النفطي تلقائيا',
    (tester) async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // مطلوب في Android حتى takeScreenshot يلتقط سطح Flutter.
      await binding.convertFlutterSurfaceToImage();

      await tester.pumpWidget(const ScreenshotApp());
      await _captureCurrent(tester, '00_home');

      const screens = <Map<String, String>>[
        {'route': '/capture/login', 'name': '01_login'},
        {'route': '/capture/citizen', 'name': '02_citizen'},
        {'route': '/capture/settings', 'name': '03_settings'},

        {'route': '/capture/admin', 'name': '04_admin'},
        {'route': '/capture/branches', 'name': '05_admin_branches'},
        {'route': '/capture/adminUsers', 'name': '06_admin_users'},
        {'route': '/capture/products', 'name': '07_products'},
        {'route': '/capture/reports', 'name': '08_reports'},
        {'route': '/capture/zainSettings', 'name': '09_zain_cash_settings'},
        {'route': '/capture/commercialRequests', 'name': '10_ad_requests'},
        {'route': '/capture/commercialPayments', 'name': '11_ad_payments'},
        {'route': '/capture/contactMessages', 'name': '12_contact_messages'},
        {'route': '/capture/adminRatings', 'name': '13_ratings_admin'},
        {'route': '/capture/internalMessages', 'name': '14_internal_messages'},

        {'route': '/capture/branch', 'name': '15_branch_dashboard'},
        {'route': '/capture/branchStations', 'name': '16_branch_stations'},
        {'route': '/capture/pendingStations', 'name': '17_pending_stations'},
        {'route': '/capture/quantityTracking', 'name': '18_quantity_tracking'},
        {'route': '/capture/branchUsers', 'name': '19_branch_users'},

        {'route': '/capture/station', 'name': '20_station_dashboard'},
        {'route': '/capture/stationFolders', 'name': '21_station_folders'},
        {'route': '/capture/governmentStations', 'name': '22_government_stations'},
        {'route': '/capture/privateStations', 'name': '23_private_stations'},
        {'route': '/capture/stationsList', 'name': '24_stations_list'},

        {'route': '/capture/employee', 'name': '25_employee_dashboard'},
        {'route': '/capture/approveRequests', 'name': '26_approve_requests'},
        {'route': '/capture/notifications', 'name': '27_notifications'},

        {'route': '/capture/registerStation', 'name': '28_register_station'},
        {'route': '/capture/changePassword', 'name': '29_change_password_request'},

        {'route': '/capture/adForm', 'name': '30_commercial_ad_form'},
        {'route': '/capture/ads', 'name': '31_commercial_ads'},
        {'route': '/capture/myAds', 'name': '32_my_commercial_ads'},
        {'route': '/capture/myPayments', 'name': '33_my_commercial_payments'},

        {'route': '/capture/about', 'name': '34_about'},
        {'route': '/capture/language', 'name': '35_language'},
        {'route': '/capture/contact', 'name': '36_contact'},
        {'route': '/capture/rating', 'name': '37_rating'},
        {'route': '/capture/privacy', 'name': '38_privacy'},
        {'route': '/capture/terms', 'name': '39_terms'},
      ];

      for (final screen in screens) {
        await _openAndCapture(
          tester,
          route: screen['route']!,
          name: screen['name']!,
        );
      }
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );
}
