# مشروع Flutter - تعليمات Claude

## نوع المشروع
- **Framework:** Flutter
- **اللغة:** Dart
- **المنصات:** iOS, Android

## أوامر مهمة

```bash
# تثبيت Dependencies
flutter pub get

# تشغيل التطبيق
flutter run

# اختبار
flutter test

# بناء iOS
flutter build ios --simulator

# بناء Android
flutter build apk
```

## هيكل المشروع

```
lib/
├── main.dart          # نقطة البداية
├── screens/           # الشاشات
├── widgets/           # المكونات
├── models/            # النماذج
├── services/          # الخدمات
└── utils/             # أدوات مساعدة
```

## عند تعديل الكود

1. تأكد من `flutter analyze` لا يوجد أخطاء
2. شغّل `flutter test` قبل commit
3. استخدم null safety
4. اتبع Flutter style guide

## التحكم عن بعد

للتحكم من الجوال، اكتب في GitHub Issue:
- `@claude add [feature]` - إضافة ميزة
- `@claude fix [bug]` - إصلاح مشكلة
- `@claude test` - تشغيل الاختبارات
- `@claude build ios` - بناء iOS
- `@claude build android` - بناء Android
