import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notification_service.dart';

class SettingsViewModel extends ChangeNotifier {
  static const String _themeModeKey = 'settings.theme_mode';
  static const String _notificationsEnabledKey =
      'settings.notifications_enabled';
  static const String _languageCodeKey = 'settings.language_code';

  final NotificationService _notificationService = NotificationService();

  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  String _languageCode = 'en';
  bool _isLoaded = false;

  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  String get languageCode => _languageCode;
  bool get isLoaded => _isLoaded;

  Locale get locale => Locale(_languageCode);

  bool get isDarkModeEnabled => _themeMode == ThemeMode.dark;

  String get languageLabel {
    switch (_languageCode) {
      case 'pt':
        return 'Portuguese';
      case 'en':
      default:
        return 'English';
    }
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final storedTheme = prefs.getString(_themeModeKey);
    _themeMode = _themeModeFromString(storedTheme);
    _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
    _languageCode = prefs.getString(_languageCodeKey) ?? 'en';
    Intl.defaultLocale = _languageCode;

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setDarkModeEnabled(bool enabled) async {
    _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _themeModeToString(_themeMode));
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);

    if (enabled) {
      await _notificationService.requestPermissions();
    } else {
      await _notificationService.cancelAllNotifications();
    }

    notifyListeners();
  }

  Future<void> setLanguageCode(String languageCode) async {
    if (_languageCode == languageCode) {
      return;
    }

    _languageCode = languageCode;
    Intl.defaultLocale = _languageCode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, _languageCode);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _themeMode = ThemeMode.system;
    _notificationsEnabled = true;
    _languageCode = 'en';
    Intl.defaultLocale = _languageCode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeModeKey);
    await prefs.remove(_notificationsEnabledKey);
    await prefs.remove(_languageCodeKey);

    notifyListeners();
  }

  ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
