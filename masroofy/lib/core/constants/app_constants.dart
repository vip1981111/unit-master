class AppConstants {
  // App Info
  static const String appName = 'Masroofy';
  static const String appNameAr = 'مصروفي';
  static const String appVersion = '1.0.0';

  // Currency
  static const List<Map<String, dynamic>> currencies = [
    {'code': 'SAR', 'symbol': 'ر.س', 'name': 'ريال سعودي', 'nameEn': 'Saudi Riyal'},
    {'code': 'AED', 'symbol': 'د.إ', 'name': 'درهم إماراتي', 'nameEn': 'UAE Dirham'},
    {'code': 'USD', 'symbol': '\$', 'name': 'دولار أمريكي', 'nameEn': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'يورو', 'nameEn': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'جنيه إسترليني', 'nameEn': 'British Pound'},
    {'code': 'EGP', 'symbol': 'ج.م', 'name': 'جنيه مصري', 'nameEn': 'Egyptian Pound'},
    {'code': 'KWD', 'symbol': 'د.ك', 'name': 'دينار كويتي', 'nameEn': 'Kuwaiti Dinar'},
    {'code': 'QAR', 'symbol': 'ر.ق', 'name': 'ريال قطري', 'nameEn': 'Qatari Riyal'},
    {'code': 'BHD', 'symbol': 'د.ب', 'name': 'دينار بحريني', 'nameEn': 'Bahraini Dinar'},
    {'code': 'OMR', 'symbol': 'ر.ع', 'name': 'ريال عماني', 'nameEn': 'Omani Rial'},
  ];

  // Default Categories - Expenses
  static const List<Map<String, dynamic>> expenseCategories = [
    {'id': 'food', 'name': 'طعام', 'nameEn': 'Food', 'icon': '🍔', 'color': 0xFFFF6B6B},
    {'id': 'transport', 'name': 'مواصلات', 'nameEn': 'Transport', 'icon': '🚗', 'color': 0xFF3A86FF},
    {'id': 'shopping', 'name': 'تسوق', 'nameEn': 'Shopping', 'icon': '🛍️', 'color': 0xFFFF006E},
    {'id': 'bills', 'name': 'فواتير', 'nameEn': 'Bills', 'icon': '📄', 'color': 0xFFFFBE0B},
    {'id': 'health', 'name': 'صحة', 'nameEn': 'Health', 'icon': '🏥', 'color': 0xFF00D9A5},
    {'id': 'entertainment', 'name': 'ترفيه', 'nameEn': 'Entertainment', 'icon': '🎬', 'color': 0xFF8338EC},
    {'id': 'education', 'name': 'تعليم', 'nameEn': 'Education', 'icon': '📚', 'color': 0xFF6C63FF},
    {'id': 'other', 'name': 'أخرى', 'nameEn': 'Other', 'icon': '📦', 'color': 0xFF9E9E9E},
  ];

  // Default Categories - Income
  static const List<Map<String, dynamic>> incomeCategories = [
    {'id': 'salary', 'name': 'راتب', 'nameEn': 'Salary', 'icon': '💰', 'color': 0xFF00D9A5},
    {'id': 'freelance', 'name': 'عمل حر', 'nameEn': 'Freelance', 'icon': '💻', 'color': 0xFF3A86FF},
    {'id': 'investment', 'name': 'استثمار', 'nameEn': 'Investment', 'icon': '📈', 'color': 0xFF6C63FF},
    {'id': 'gift', 'name': 'هدية', 'nameEn': 'Gift', 'icon': '🎁', 'color': 0xFFFF006E},
    {'id': 'other_income', 'name': 'أخرى', 'nameEn': 'Other', 'icon': '💵', 'color': 0xFF9E9E9E},
  ];

  // AdMob IDs (Test IDs - Replace with real ones)
  static const String adMobAppId = 'ca-app-pub-2246849300811913~2496630733';
  static const String bannerAdId = 'ca-app-pub-3940256099942544/6300978111'; // Test
  static const String interstitialAdId = 'ca-app-pub-3940256099942544/1033173712'; // Test
}
