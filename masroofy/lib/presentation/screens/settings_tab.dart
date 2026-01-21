import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../providers/app_provider.dart';
import '../providers/transaction_provider.dart';
import 'export_screen.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isArabic = appProvider.isArabic;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Text(
            isArabic ? 'الإعدادات' : 'Settings',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Appearance Section
          _buildSectionTitle(isArabic ? 'المظهر' : 'Appearance'),
          _buildSettingsTile(
            icon: Icons.dark_mode,
            title: isArabic ? 'الوضع الداكن' : 'Dark Mode',
            trailing: Switch(
              value: appProvider.themeMode == ThemeMode.dark,
              onChanged: (_) => appProvider.toggleTheme(),
              activeColor: AppTheme.primaryColor,
            ),
          ),
          _buildSettingsTile(
            icon: Icons.language,
            title: isArabic ? 'اللغة' : 'Language',
            subtitle: isArabic ? 'العربية' : 'English',
            onTap: () => appProvider.toggleLanguage(),
          ),

          const SizedBox(height: 24),

          // Preferences Section
          _buildSectionTitle(isArabic ? 'التفضيلات' : 'Preferences'),
          _buildSettingsTile(
            icon: Icons.attach_money,
            title: isArabic ? 'العملة' : 'Currency',
            subtitle: '${appProvider.currencyCode} (${appProvider.currencySymbol})',
            onTap: () => _showCurrencyPicker(context, appProvider, isArabic),
          ),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: isArabic ? 'الإشعارات' : 'Notifications',
            trailing: Switch(
              value: true,
              onChanged: (_) {},
              activeColor: AppTheme.primaryColor,
            ),
          ),

          const SizedBox(height: 24),

          // Data Section
          _buildSectionTitle(isArabic ? 'البيانات' : 'Data'),
          _buildSettingsTile(
            icon: Icons.backup_outlined,
            title: isArabic ? 'نسخ احتياطي وتصدير' : 'Backup & Export',
            subtitle: isArabic ? 'تصدير CSV أو نسخة احتياطية' : 'Export CSV or backup',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExportScreen()),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.delete_outline,
            title: isArabic ? 'حذف جميع البيانات' : 'Delete All Data',
            textColor: AppTheme.expenseColor,
            onTap: () => _showDeleteConfirmation(context, isArabic),
          ),

          const SizedBox(height: 24),

          // Premium Section
          if (!appProvider.isPremium) ...[
            _buildPremiumCard(context, isArabic),
            const SizedBox(height: 24),
          ],

          // About Section
          _buildSectionTitle(isArabic ? 'حول' : 'About'),
          _buildSettingsTile(
            icon: Icons.star_outline,
            title: isArabic ? 'قيّم التطبيق' : 'Rate App',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.share_outlined,
            title: isArabic ? 'شارك التطبيق' : 'Share App',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: isArabic ? 'سياسة الخصوصية' : 'Privacy Policy',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: isArabic ? 'حول التطبيق' : 'About',
            subtitle: 'Masroofy v${AppConstants.appVersion}',
            onTap: () {},
          ),

          const SizedBox(height: 32),

          // Footer
          Center(
            child: Column(
              children: [
                const Text('💰', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text(
                  'Masroofy | مصروفي',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'v${AppConstants.appVersion}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: textColor ?? AppTheme.primaryColor),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        subtitle: subtitle != null
            ? Text(subtitle, style: TextStyle(color: Colors.grey[600]))
            : null,
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context, bool isArabic) {
    return Card(
      color: AppTheme.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.workspace_premium, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'النسخة المميزة' : 'Premium',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isArabic
                  ? 'احصل على جميع الميزات بدون إعلانات'
                  : 'Get all features without ads',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                ),
                child: Text(isArabic ? 'ترقية الآن' : 'Upgrade Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(
      BuildContext context, AppProvider provider, bool isArabic) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'اختر العملة' : 'Select Currency',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: AppConstants.currencies.length,
                itemBuilder: (context, index) {
                  final currency = AppConstants.currencies[index];
                  final isSelected =
                      provider.currencyCode == currency['code'];
                  return ListTile(
                    leading: Text(
                      currency['symbol'] as String,
                      style: const TextStyle(fontSize: 20),
                    ),
                    title: Text(
                      isArabic
                          ? currency['name'] as String
                          : currency['nameEn'] as String,
                    ),
                    subtitle: Text(currency['code'] as String),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: AppTheme.primaryColor)
                        : null,
                    onTap: () {
                      provider.setCurrency(
                        currency['code'] as String,
                        currency['symbol'] as String,
                      );
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'تأكيد الحذف' : 'Confirm Delete'),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من حذف جميع البيانات؟ لا يمكن التراجع عن هذا الإجراء.'
              : 'Are you sure you want to delete all data? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              final transactionProvider = context.read<TransactionProvider>();
              transactionProvider.clearAllTransactions();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isArabic ? 'تم حذف جميع البيانات' : 'All data deleted',
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.expenseColor),
            child: Text(isArabic ? 'حذف' : 'Delete'),
          ),
        ],
      ),
    );
  }
}
