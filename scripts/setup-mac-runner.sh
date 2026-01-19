#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# سكربت إعداد Mac كـ GitHub Runner
# شغّل هذا السكربت مرة واحدة على الـ Mac في بيتك
# ═══════════════════════════════════════════════════════════════

echo "🚀 بدء إعداد Mac كـ GitHub Runner..."
echo ""

# ─────────────────────────────────────────
# 1. التحقق من المتطلبات
# ─────────────────────────────────────────
echo "📋 التحقق من المتطلبات..."

# Flutter
if command -v flutter &> /dev/null; then
    echo "✅ Flutter: $(flutter --version | head -1)"
else
    echo "❌ Flutter غير مثبت"
    echo "   ثبته من: https://flutter.dev/docs/get-started/install/macos"
    exit 1
fi

# Xcode
if command -v xcodebuild &> /dev/null; then
    echo "✅ Xcode: $(xcodebuild -version | head -1)"
else
    echo "❌ Xcode غير مثبت"
    echo "   ثبته من App Store"
    exit 1
fi

# CocoaPods
if command -v pod &> /dev/null; then
    echo "✅ CocoaPods: $(pod --version)"
else
    echo "⚠️  CocoaPods غير مثبت، جاري التثبيت..."
    sudo gem install cocoapods
fi

echo ""

# ─────────────────────────────────────────
# 2. إعداد iOS Simulator
# ─────────────────────────────────────────
echo "📱 إعداد iOS Simulator..."

# قائمة Simulators المتاحة
echo "Simulators المتاحة:"
xcrun simctl list devices available | grep iPhone | head -5

echo ""

# ─────────────────────────────────────────
# 3. إعداد GitHub Runner
# ─────────────────────────────────────────
echo "🔧 إعداد GitHub Actions Runner..."
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  اتبع هذه الخطوات:"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "1. اذهب إلى: https://github.com/YOUR_USERNAME/YOUR_REPO/settings/actions/runners/new"
echo ""
echo "2. اختر: macOS"
echo ""
echo "3. انسخ ونفذ الأوامر التي يعطيك إياها GitHub"
echo ""
echo "4. عند السؤال عن labels، أضف: flutter, ios, mac"
echo ""
echo "5. بعد الانتهاء، شغّل كـ service:"
echo "   sudo ./svc.sh install"
echo "   sudo ./svc.sh start"
echo ""
echo "═══════════════════════════════════════════════════════════"

# ─────────────────────────────────────────
# 4. إعدادات الطاقة
# ─────────────────────────────────────────
echo ""
echo "⚡ إعدادات الطاقة (مهم!):"
echo ""
echo "اذهب إلى System Settings وعدّل:"
echo ""
echo "  Energy Saver / Battery:"
echo "    ✓ Prevent automatic sleeping when display is off"
echo "    ✓ Wake for network access"
echo ""
echo "  Lock Screen:"
echo "    → Turn display off: Never (أو 3 hours)"
echo ""

# ─────────────────────────────────────────
# 5. Secrets المطلوبة
# ─────────────────────────────────────────
echo "🔑 أضف هذه الـ Secrets في GitHub:"
echo ""
echo "  Settings → Secrets → Actions → New repository secret"
echo ""
echo "  ANTHROPIC_API_KEY = مفتاح Claude API الخاص بك"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "✅ انتهى! الآن يمكنك التحكم من جوالك بكتابة @claude في GitHub"
echo "═══════════════════════════════════════════════════════════"
