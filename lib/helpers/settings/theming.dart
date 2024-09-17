import 'package:flutter/material.dart';

class ThemingSettings {
  ThemeModeApp themeMode = ThemeModeApp.amoledDark;
  Color? accentColor;
  ColorScheme? lightColorScheme;
  ColorScheme? darkColorScheme;

  void setColorscheme() {
    if (accentColor == null) {
      return;
    }
    darkColorScheme = ColorScheme.fromSeed(
        seedColor: accentColor!, brightness: Brightness.dark);
    lightColorScheme = ColorScheme.fromSeed(
        seedColor: accentColor!, brightness: Brightness.light);
  }

  Map<String, dynamic> toJson() {
    return {
      "themeMode": themeMode,
      "accentColor": accentColor,
      "lighColorScheme": lightColorScheme,
      "darkColorScheme": lightColorScheme,
    };
  }
}

enum ThemeModeApp {
  dark,
  amoledDark,
  light,
  system,
}
