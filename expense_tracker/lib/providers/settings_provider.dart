import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _keyIsDarkMode = 'isDarkMode';
  static const String _keyLanguage = 'language';
  static const String _keyCurrency = 'currency';
  static const String _keyIsAdsRemoved = 'isAdsRemoved';
  static const String _keyIsFirstLaunch = 'isFirstLaunch';

  bool _isDarkMode = false;
  String _language = 'ar'; // Default to Arabic
  String _currency = 'SAR'; // Default to Saudi Riyal
  bool _isAdsRemoved = false;
  bool _isFirstLaunch = true;

  // Getters
  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  String get currency => _currency;
  bool get isAdsRemoved => _isAdsRemoved;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isArabic => _language == 'ar';

  String get currencySymbol {
    switch (_currency) {
      case 'SAR':
        return 'ر.س';
      case 'AED':
        return 'د.إ';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'EGP':
        return 'ج.م';
      case 'KWD':
        return 'د.ك';
      case 'QAR':
        return 'ر.ق';
      case 'BHD':
        return 'د.ب';
      case 'OMR':
        return 'ر.ع';
      default:
        return _currency;
    }
  }

  static const Map<String, String> availableCurrencies = {
    'SAR': 'ريال سعودي',
    'AED': 'درهم إماراتي',
    'USD': 'دولار أمريكي',
    'EUR': 'يورو',
    'GBP': 'جنيه إسترليني',
    'EGP': 'جنيه مصري',
    'KWD': 'دينار كويتي',
    'QAR': 'ريال قطري',
    'BHD': 'دينار بحريني',
    'OMR': 'ريال عماني',
  };

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _isDarkMode = prefs.getBool(_keyIsDarkMode) ?? false;
    _language = prefs.getString(_keyLanguage) ?? 'ar';
    _currency = prefs.getString(_keyCurrency) ?? 'SAR';
    _isAdsRemoved = prefs.getBool(_keyIsAdsRemoved) ?? false;
    _isFirstLaunch = prefs.getBool(_keyIsFirstLaunch) ?? true;

    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsDarkMode, value);
  }

  Future<void> toggleDarkMode() async {
    await setDarkMode(!_isDarkMode);
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, value);
  }

  Future<void> setCurrency(String value) async {
    _currency = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrency, value);
  }

  Future<void> setAdsRemoved(bool value) async {
    _isAdsRemoved = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsAdsRemoved, value);
  }

  Future<void> setFirstLaunch(bool value) async {
    _isFirstLaunch = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsFirstLaunch, value);
  }

  String formatAmount(double amount) {
    final formatted = amount.toStringAsFixed(2);
    if (isArabic) {
      return '$formatted $currencySymbol';
    }
    return '$currencySymbol$formatted';
  }
}
