import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dark.dart';
import 'light.dart';

class Themeprov extends ChangeNotifier {
  ThemeData _themeData;
  final Box preferences = Hive.box('preferences');

  Themeprov() : _themeData = lightMode {
    _loadTheme();  // Load the saved theme on initialization
  }

  ThemeData get themeData => _themeData;

  bool get isDark => _themeData == darkMode;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    _saveTheme();  // Save the new theme to Hive
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }

  void _saveTheme() {
    preferences.put('isDarkMode', isDark);
  }

  void _loadTheme() {
    final isDarkMode = preferences.get('isDarkMode', defaultValue: false);
    _themeData = isDarkMode ? darkMode : lightMode;
  }
}
