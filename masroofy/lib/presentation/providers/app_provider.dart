import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('ar');
  String _currencyCode = 'SAR';
  String _currencySymbol = 'ر.س';
  bool _isFirstLaunch = true;
  bool _isPremium = false;

  // Getters
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  String get currencyCode => _currencyCode;
  String get currencySymbol => _currencySymbol;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isPremium => _isPremium;
  bool get isArabic => _locale.languageCode == 'ar';

  AppProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Theme
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];

    // Locale
    final langCode = prefs.getString('locale') ?? 'ar';
    _locale = Locale(langCode);

    // Currency
    _currencyCode = prefs.getString('currencyCode') ?? 'SAR';
    _currencySymbol = prefs.getString('currencySymbol') ?? 'ر.س';

    // First Launch
    _isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    // Premium
    _isPremium = prefs.getBool('isPremium') ?? false;

    notifyListeners();
  }

  // Set Theme
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  // Toggle Theme
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  // Set Locale
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
    notifyListeners();
  }

  // Toggle Language
  Future<void> toggleLanguage() async {
    if (_locale.languageCode == 'ar') {
      await setLocale(const Locale('en'));
    } else {
      await setLocale(const Locale('ar'));
    }
  }

  // Set Currency
  Future<void> setCurrency(String code, String symbol) async {
    _currencyCode = code;
    _currencySymbol = symbol;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currencyCode', code);
    await prefs.setString('currencySymbol', symbol);
    notifyListeners();
  }

  // Complete Onboarding
  Future<void> completeOnboarding() async {
    _isFirstLaunch = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);
    notifyListeners();
  }

  // Set Premium
  Future<void> setPremium(bool value) async {
    _isPremium = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPremium', value);
    notifyListeners();
  }

  // Format Amount
  String formatAmount(double amount) {
    return '${amount.toStringAsFixed(2)} $_currencySymbol';
  }
}
