import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/screenshot_capture_screen.dart';

class ScreenshotMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const ScreenshotMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      const ['ar', 'ku', 'fa', 'en'].contains(locale.languageCode);

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    final fallbackLocale =
    (locale.languageCode == 'ku' || locale.languageCode == 'fa')
        ? const Locale('ar')
        : locale;

    return GlobalMaterialLocalizations.delegate.load(fallbackLocale);
  }

  @override
  bool shouldReload(
      ScreenshotMaterialLocalizationsDelegate old,
      ) => false;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ScreenshotOnlyApp());
}

class ScreenshotOnlyApp extends StatelessWidget {
  const ScreenshotOnlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'نافذة المنتوج النفطي - تصوير',
      locale: const Locale('ar'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ScreenshotMaterialLocalizationsDelegate(),
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
      home: const ScreenshotCaptureScreen(),
    );
  }
}
