import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return CustomScrollView(
            slivers: [
              const SliverAppBar(
                floating: true,
                title: Text('الإعدادات'),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Appearance Section
                      _buildSectionHeader('المظهر'),
                      Card(
                        child: Column(
                          children: [
                            SwitchListTile(
                              leading: const Icon(Icons.dark_mode),
                              title: const Text('الوضع الداكن'),
                              subtitle: const Text('تفعيل المظهر الداكن'),
                              value: settings.isDarkMode,
                              onChanged: (value) => settings.setDarkMode(value),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Currency Section
                      _buildSectionHeader('العملة'),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.attach_money),
                              title: const Text('العملة'),
                              subtitle: Text(
                                SettingsProvider.availableCurrencies[settings.currency] ??
                                    settings.currency,
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _showCurrencyPicker(context, settings),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Language Section
                      _buildSectionHeader('اللغة'),
                      Card(
                        child: Column(
                          children: [
                            RadioListTile<String>(
                              title: const Text('العربية'),
                              value: 'ar',
                              groupValue: settings.language,
                              onChanged: (value) => settings.setLanguage(value!),
                            ),
                            const Divider(height: 1),
                            RadioListTile<String>(
                              title: const Text('English'),
                              value: 'en',
                              groupValue: settings.language,
                              onChanged: (value) => settings.setLanguage(value!),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Premium Section
                      _buildSectionHeader('النسخة المميزة'),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(
                                settings.isAdsRemoved
                                    ? Icons.check_circle
                                    : Icons.workspace_premium,
                                color: settings.isAdsRemoved
                                    ? Colors.green
                                    : Colors.amber,
                              ),
                              title: Text(
                                settings.isAdsRemoved
                                    ? 'تم إزالة الإعلانات'
                                    : 'إزالة الإعلانات',
                              ),
                              subtitle: Text(
                                settings.isAdsRemoved
                                    ? 'شكراً لدعمك!'
                                    : '2.99\$ فقط',
                              ),
                              trailing: settings.isAdsRemoved
                                  ? null
                                  : ElevatedButton(
                                      onPressed: () => _purchaseRemoveAds(context),
                                      child: const Text('شراء'),
                                    ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // About Section
                      _buildSectionHeader('حول التطبيق'),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.info_outline),
                              title: const Text('الإصدار'),
                              subtitle: const Text('1.0.0'),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.privacy_tip_outlined),
                              title: const Text('سياسة الخصوصية'),
                              trailing: const Icon(Icons.open_in_new, size: 18),
                              onTap: () => _openPrivacyPolicy(),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.description_outlined),
                              title: const Text('شروط الاستخدام'),
                              trailing: const Icon(Icons.open_in_new, size: 18),
                              onTap: () => _openTermsOfService(),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.email_outlined),
                              title: const Text('تواصل معنا'),
                              subtitle: const Text('vip1981.1@gmail.com'),
                              onTap: () => _contactSupport(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'اختر العملة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...SettingsProvider.availableCurrencies.entries.map((entry) {
              return RadioListTile<String>(
                title: Text(entry.value),
                subtitle: Text(entry.key),
                value: entry.key,
                groupValue: settings.currency,
                onChanged: (value) {
                  settings.setCurrency(value!);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _purchaseRemoveAds(BuildContext context) {
    // TODO: Implement IAP
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('قريباً...')),
    );
  }

  void _openPrivacyPolicy() {
    // TODO: Open privacy policy URL
  }

  void _openTermsOfService() {
    // TODO: Open terms of service URL
  }

  void _contactSupport() {
    // TODO: Open email client
  }
}
