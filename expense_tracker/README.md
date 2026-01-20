# Expense Tracker - متتبع المصاريف

تطبيق Flutter بسيط وجميل لتتبع المصاريف وإدارة الميزانية الشخصية.

## الميزات

- ✅ تسجيل المصاريف والدخل
- ✅ تصنيفات متعددة للمصاريف
- ✅ إحصائيات ورسوم بيانية
- ✅ دعم العربية والإنجليزية
- ✅ الوضع الداكن
- ✅ عملات متعددة (SAR, AED, USD, EUR, ...)
- ✅ قاعدة بيانات محلية (SQLite)

## البدء

### المتطلبات

- Flutter 3.0+
- Dart 3.0+

### التثبيت

```bash
# استنساخ المشروع
git clone https://github.com/vip1981111/expense_tracker.git
cd expense_tracker

# تثبيت التبعيات
flutter pub get

# تشغيل التطبيق
flutter run
```

## هيكل المشروع

```
lib/
├── main.dart                 # نقطة البداية
├── models/
│   ├── category.dart         # نموذج التصنيف
│   └── transaction.dart      # نموذج المعاملة
├── providers/
│   ├── expense_provider.dart # إدارة حالة المصاريف
│   └── settings_provider.dart# إدارة الإعدادات
├── screens/
│   ├── home_screen.dart      # الشاشة الرئيسية
│   ├── add_transaction_screen.dart
│   ├── statistics_screen.dart
│   └── settings_screen.dart
├── services/
│   ├── database_service.dart # خدمة قاعدة البيانات
│   └── ad_service.dart       # خدمة الإعلانات
├── utils/
│   └── app_theme.dart        # ثيم التطبيق
└── widgets/
    ├── balance_card.dart
    └── transaction_list_item.dart
```

## AdMob

### معرفات الإعلانات (Test)

| Platform | Banner | Interstitial |
|----------|--------|--------------|
| Android | ca-app-pub-3940256099942544/6300978111 | ca-app-pub-3940256099942544/1033173712 |
| iOS | ca-app-pub-3940256099942544/2934735716 | ca-app-pub-3940256099942544/4411468910 |

## المعلومات

| المعلومة | القيمة |
|----------|--------|
| Bundle ID | com.mohammedabdullah.expensetracker |
| الإصدار | 1.0.0 |
| المطور | Mohammed Abdullah |
| البريد | vip1981.1@gmail.com |

## الترخيص

MIT License
