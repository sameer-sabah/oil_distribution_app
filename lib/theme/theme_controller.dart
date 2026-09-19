import 'package:flutter/material.dart';

class ThemeController {
  ThemeController._();

  static final ValueNotifier<ThemeMode>
  themeMode =
  ValueNotifier<ThemeMode>(
    ThemeMode.light,
  );

  static bool get isDarkMode {
    return themeMode.value ==
        ThemeMode.dark;
  }

  static void setDarkMode(
      bool value,
      ) {
    themeMode.value =
    value
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  static void toggle() {
    setDarkMode(!isDarkMode);
  }
}