import 'dart:convert';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class InterfaceSettings {
  static InterfaceSettings? _instance;
  AppTheme _theme;
  bool _customAccentColor;
  Color _accentColor;
  bool _showHiddenFolders;
  String _fontFamily;

  InterfaceSettings._(this._theme, this._customAccentColor, this._accentColor,
      this._showHiddenFolders, this._fontFamily);

  static Future<InterfaceSettings> init() async {
    String? settingsJson =
        await const FlutterSecureStorage().read(key: "interface_settings");
    if (settingsJson == null) {
      // -----defaults-----
      InterfaceSettings settings = InterfaceSettings._(
        AppTheme.system,
        false,
        Colors.blue,
        false,
        "Poppins",
      );
      //-------------------
      Map<String, String> map = settings.toJson();
      const FlutterSecureStorage()
          .write(key: "interface_settings", value: jsonEncode(map));
      _instance = settings;
      return settings;
    } else {
      Map<String, dynamic> json = jsonDecode(settingsJson);
      _instance = fromJson(json);
      return _instance!;
    }
  }

  static InterfaceSettings fromJson(Map<String, dynamic> json) {
    bool customAccentColor = json["customAccentColor"] == "true";
    bool showHiddenFolders = json["showHiddenFolders"] == "true";
    String fontFamily = json["fontFamily"] ?? "Poppins";
    AppTheme theme = AppTheme.values.where(
      (element) {
        return element.toString() == json["theme"];
      },
    ).first;
    List<String> accentColor = json["accentColor"]!.split(",");
    int red = int.parse(accentColor[0]);
    int green = int.parse(accentColor[1]);
    int blue = int.parse(accentColor[2]);
    Color color = Color.fromARGB(255, red, green, blue);
    return InterfaceSettings._(
        theme, customAccentColor, color, showHiddenFolders, fontFamily);
  }

  Map<String, String> toJson() {
    Map<String, String> json = {
      "customAccentColor": _customAccentColor.toString(),
      "showHiddenFolders": _showHiddenFolders.toString(),
      "fontFamily": _fontFamily,
      "theme": _theme.toString()
    };
    json["accentColor"] =
        "${_accentColor.red},${_accentColor.green},${_accentColor.blue}";

    return json;
  }

  Future<ColorScheme> getDarkColorScheme() async {
    if (_customAccentColor) {
      ColorScheme scheme = ColorScheme.fromSeed(
          seedColor: _accentColor, brightness: Brightness.dark);
      if (_theme == AppTheme.black) {
        scheme = scheme.copyWith(surface: Colors.black);
      }
      return scheme;
    } else {
      Color accentColor =
          await DynamicColorPlugin.getAccentColor() ?? _accentColor;
      ColorScheme scheme = ColorScheme.fromSeed(
          seedColor: accentColor, brightness: Brightness.dark);
      if (_theme == AppTheme.black) {
        scheme = scheme.copyWith(surface: Colors.black);
      }
      return scheme;
    }
  }

  Future<ColorScheme> getLightColorScheme() async {
    if (_customAccentColor) {
      ColorScheme scheme = ColorScheme.fromSeed(
          seedColor: _accentColor, brightness: Brightness.light);
      return scheme;
    } else {
      Color accentColor =
          await DynamicColorPlugin.getAccentColor() ?? _accentColor;
      ColorScheme scheme = ColorScheme.fromSeed(
          seedColor: accentColor, brightness: Brightness.dark);
      if (_theme == AppTheme.black) {
        scheme = scheme.copyWith(surface: Colors.black);
      }
      return scheme;
    }
  }

  TextStyle getFont(TextStyle style) {
    print(GoogleFonts.asMap().keys.toList());
    return GoogleFonts.getFont(_fontFamily, textStyle: style);
  }

  bool getShowHiddenFolders() {
    return _showHiddenFolders;
  }

  bool getCustomAccentColor() {
    return _customAccentColor;
  }

  Color getAccentColor() {
    return _accentColor;
  }

  ThemeMode getTheme() {
    switch (_theme) {
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.dark:
        return ThemeMode.dark;
      case AppTheme.system:
        return ThemeMode.system;
      case AppTheme.black:
        return ThemeMode.dark;
    }
  }

  AppTheme getThemeRaw() {
    return _theme;
  }

  String getFontName() {
    return _fontFamily;
  }

  void setShowHiddenFolders(bool showhiddenFolders) {
    _showHiddenFolders = showhiddenFolders;
    _saveUpdates();
  }

  void setCustomAccentColor(bool useCustomAccentColor) {
    _customAccentColor = useCustomAccentColor;
    _saveUpdates();
  }

  void setAccentColor(Color accentColor) {
    _accentColor = accentColor;
    _saveUpdates();
  }

  void setFontFamily(String fontFamily) {
    _fontFamily = fontFamily;
    _saveUpdates();
  }

  void setTheme(AppTheme theme) {
    _theme = theme;
  }

  void _saveUpdates() async {
    Map<String, String> json = _instance!.toJson();
    await const FlutterSecureStorage()
        .write(key: "interface_settings", value: jsonEncode(json));
  }
}

enum AppTheme { light, dark, system, black }
