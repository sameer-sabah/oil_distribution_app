import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'services/governorate_service.dart';
import 'services/branch_service.dart';
import 'services/auth_service.dart';
import 'services/push_notification_service.dart';
import 'theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'theme/theme_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Screens
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/citizen_screen.dart';
import 'screens/station_dashboard.dart';
import 'screens/register_station_screen.dart';
import 'screens/pending_stations_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/branch_dashboard.dart';
import 'screens/distribution/approve_requests_screen.dart';
import 'screens/employee/employee_dashboard.dart';
import 'screens/change_password_request_screen.dart';
import 'screens/about_screen.dart';
import 'screens/language_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/rating_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/terms_screen.dart';
import 'screens/commercial_ad_form_screen.dart';
import 'screens/commercial_ads_screen.dart';
import 'screens/my_commercial_ads_screen.dart';
import 'screens/my_commercial_payments_screen.dart';
import 'screens/advertiser_account_screen.dart';
import 'screens/advertiser_gate_screen.dart';
import 'screens/admin/commercial_requests_screen.dart';
import 'screens/admin/commercial_payments_screen.dart';
import 'screens/admin/advertiser_accounts_screen.dart';
import 'screens/admin/commercial_conversations_screen.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'controllers/language_controller.dart';
// ============================================================
// ????? ????? ???????
// ============================================================

Future<void> registerAppInstallation() async {
  try {
    User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      final result =
      await FirebaseAuth.instance.signInAnonymously();

      user = result.user;
    }

    if (user == null) {
      debugPrint(
        "???? ?????? ??? ???? ????? ???????",
      );
      return;
    }

    final installationId =
        user.uid;

    final ref = FirebaseDatabase
        .instance
        .ref("appInstallations")
        .child(installationId);

    final snapshot =
    await ref.get();

    if (!snapshot.exists) {
      await ref.set({
        "id": installationId,
        "createdAt":
        ServerValue.timestamp,
        "lastActiveAt":
        ServerValue.timestamp,
      });

      debugPrint(
        "?? ????? ????? ????: $installationId",
      );
    } else {
      await ref.update({
        "lastActiveAt":
        ServerValue.timestamp,
      });

      debugPrint(
        "?????? ???? ??????",
      );
    }
  } catch (e) {
    debugPrint(
      "??? ?? ????? ????? ???????: $e",
    );
  }
}
// ============================================================
// ??? Material ?????
// ============================================================

class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == 'ar' ||
        locale.languageCode == 'ku' ||
        locale.languageCode == 'fa' ||
        locale.languageCode == 'en';
  }

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    final fallbackLocale =
    locale.languageCode == 'ku' ||
        locale.languageCode == 'fa'
        ? const Locale('ar')
        : locale;

    return GlobalMaterialLocalizations.delegate
        .load(fallbackLocale);
  }

  @override
  bool shouldReload(
      FallbackMaterialLocalizationsDelegate old,
      ) {
    return false;
  }
}

class ForceUpdateGate extends StatefulWidget {
  final Widget child;

  const ForceUpdateGate({
    super.key,
    required this.child,
  });

  @override
  State<ForceUpdateGate> createState() => _ForceUpdateGateState();
}

class _ForceUpdateGateState extends State<ForceUpdateGate> {
  bool _checking = true;
  bool _forceUpdate = false;
  String _message = '????? ????? ???? ??????. ??? ????? ??????? ????????.';

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    try {
      // ?????? ??????? ???????? ??? ????? Android.
      if (defaultTargetPlatform != TargetPlatform.android) {
        if (mounted) {
          setState(() {
            _checking = false;
          });
        }
        return;
      }

      final packageInfo = await PackageInfo.fromPlatform();

      final currentVersionCode =
          int.tryParse(packageInfo.buildNumber) ?? 0;

      final snapshot = await FirebaseDatabase.instance
          .ref('appConfig/android')
          .get();

      if (!snapshot.exists || snapshot.value == null) {
        if (mounted) {
          setState(() {
            _checking = false;
          });
        }
        return;
      }

      final data = Map<String, dynamic>.from(
        snapshot.value as Map,
      );

      final forceUpdateEnabled =
          data['forceUpdate'] == true;

      final minVersionCode =
          int.tryParse(
            data['minVersionCode']?.toString() ?? '0',
          ) ??
              0;

      final customMessage =
      data['message']?.toString().trim();

      if (mounted) {
        setState(() {
          _checking = false;

          _forceUpdate =
              forceUpdateEnabled &&
                  currentVersionCode < minVersionCode;

          if (customMessage != null &&
              customMessage.isNotEmpty) {
            _message = customMessage;
          }
        });
      }
    } catch (e) {
      debugPrint('Force update check failed: $e');

      // ??? ??? ??? ????????? ?? Firebase
      // ?? ???? ???????? ?? ??? ???????.
      if (mounted) {
        setState(() {
          _checking = false;
        });
      }
    }
  }

  Future<void> _openGooglePlay() async {
    final marketUri = Uri.parse(
      'market://details?id=com.samir.nafithat',
    );

    final webUri = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.samir.nafithat',
    );

    try {
      final opened = await launchUrl(
        marketUri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (_) {
      await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_forceUpdate) {
      return widget.child;
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.system_update,
                    size: 85,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '????? ??????',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _openGooglePlay,
                      icon: const Icon(
                        Icons.download,
                      ),
                      label: const Text(
                        '????? ????',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// ============================================================
// Main
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options:
      DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.onBackgroundMessage(
      PushNotificationService
          .firebaseMessagingBackgroundHandler,
    );
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  try {
    await registerAppInstallation();
  } catch (e) {
    debugPrint("App install error: $e");
  }
  
  try {
    await LanguageController.instance.load();
  } catch (e) {
    debugPrint("Language error: $e");
  }
  
  try {
    await PushNotificationService
        .instance
        .initialize(
      isCitizen: false,
    ).timeout(const Duration(seconds: 5));
  } catch (e) {
    debugPrint("Push notification init error: $e");
  }

  runApp(
    const MyApp(),
  );

  Future.microtask(() async {
    try {
      await GovernorateService
          .instance
          .createDefaultGovernorates();

      await BranchService
          .instance
          .createDefaultBranches();
    } catch (e) {
      debugPrint("Services init error: $e");
    }
  });
}


// ============================================================
// ???????
// ============================================================

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageController.instance,
      builder: (context, child) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeController.themeMode,

          builder: (
              context,
              themeMode,
              child,
              ) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,

              title: "????? ??????? ??????",

              // ????? ???????
              locale: LanguageController.instance.locale,
              localeResolutionCallback: (locale, supportedLocales) {
                if (locale == null) {
                  return const Locale('ar');
                }

                for (final supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale.languageCode) {
                    return supportedLocale;
                  }
                }

                return const Locale('ar');
              },
              // ???? ???????
              localizationsDelegates: const [
                AppLocalizations.delegate,
                FallbackMaterialLocalizationsDelegate(),
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],

              // ?????? ????????
              supportedLocales: const [
                Locale('ar'),
                Locale('ku'),
                Locale('fa'),
                Locale('en'),
              ],

              theme: AppTheme.lightTheme,

              darkTheme: AppTheme.darkTheme,

              themeMode: themeMode,

              home: const ForceUpdateGate(
                child: HomeScreen(),
              ),

              routes: {
                "/branch":
                    (context) =>
                const BranchDashboard(),

                "/login":
                    (context) =>
                const LoginScreen(),

                "/settings":
                    (context) =>
                const SettingsScreen(),

                "/admin":
                    (context) =>
                const AdminScreen(),

                "/station":
                    (context) =>
                const StationDashboard(),

                "/employee":
                    (context) =>
                    EmployeeDashboard(),

                "/approveRequests":
                    (context) =>
                const ApproveRequestsScreen(),

                "/changePasswordRequest":
                    (context) =>
                const ChangePasswordRequestScreen(),

                "/citizen":
                    (context) =>
                const CitizenScreen(),

                "/registerStation":
                    (context) =>
                const RegisterStationScreen(),

                "/pendingStations":
                    (context) =>
                const PendingStationsScreen(),

                "/notifications":
                    (context) =>
                    NotificationsScreen(
                      userId:
                      AuthService
                          .instance
                          .currentUser
                          ?.id ??
                          "",
                    ),

                "/about":
                    (context) =>
                const AboutScreen(),

                "/language":
                    (context) =>
                const LanguageScreen(),

                "/contact":
                    (context) =>
                const ContactScreen(),

                "/rating":
                    (context) =>
                const RatingScreen(),

                "/privacy":
                    (context) =>
                const PrivacyScreen(),

                "/terms":
                    (context) =>
                const TermsScreen(),

                "/commercialAdForm":
                    (context) =>
                const AdvertiserGateScreen(
                  destination: CommercialAdFormScreen(),
                ),

                "/commercialAds":
                    (context) =>
                const CommercialAdsScreen(),

                "/myCommercialAds":
                    (context) =>
                const AdvertiserGateScreen(
                  destination: MyCommercialAdsScreen(),
                ),

                "/myCommercialPayments":
                    (context) =>
                const AdvertiserGateScreen(
                  destination: MyCommercialPaymentsScreen(),
                ),

                "/advertiserAccount":
                    (context) =>
                const AdvertiserAccountScreen(),

                "/commercialRequests":
                    (context) =>
                const CommercialRequestsScreen(),

                "/commercialPaymentsAdmin":
                    (context) =>
                const CommercialPaymentsScreen(),

                "/advertiserAccountsAdmin":
                    (context) =>
                const AdvertiserAccountsScreen(),

                "/commercialConversationsAdmin":
                    (context) =>
                const CommercialConversationsScreen(),
              },

              onUnknownRoute: (settings) {
                return MaterialPageRoute(
                  builder: (_) =>
                  const LoginScreen(),
                );
              },
            );
          },
        );
      },
    );
  }
}
