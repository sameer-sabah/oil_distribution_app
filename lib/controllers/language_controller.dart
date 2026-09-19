import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends ChangeNotifier {
  static final LanguageController instance =
  LanguageController._internal();

  LanguageController._internal();

  Locale _locale = const Locale('ar');

  Locale get locale => _locale;

  Future<void> load() async {
    final prefs =
    await SharedPreferences.getInstance();

    final code =
        prefs.getString('app_language') ?? 'ar';

    _locale = Locale(code);

    notifyListeners();
  }

  Future<void> changeLanguage(String code) async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(
      'app_language',
      code,
    );

    _locale = Locale(code);

    notifyListeners();
  }
}