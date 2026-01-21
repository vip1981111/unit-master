import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../services/export_service.dart';
import '../providers/app_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  bool _isExporting = false;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final transactionProvider = context.watch<TransactionProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final isArabic = appProvider.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'التصدير والنسخ الاحتياطي' : 'Export & Backup'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info Card
          Card(
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isArabic
                          ? 'يمكنك تصدير بياناتك أو إنشاء نسخة احتياطية للحفاظ على معاملاتك'
                          : 'Export your data or create a backup to keep your transactions safe',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Date Range Section
          Text(
            isArabic ? 'نطاق التاريخ للتصدير' : 'Date Range for Export',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDatePicker(
                  isArabic ? 'من' : 'From',
                  _startDate,
                  (date) => setState(() => _startDate = date),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDatePicker(
                  isArabic ? 'إلى' : 'To',
                  _endDate,
                  (date) => setState(() => _endDate = date),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Quick date selection
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                label: Text(isArabic ? 'هذا الشهر' : 'This Month'),
                onPressed: () {
                  final now = DateTime.now();
                  setState(() {
                    _startDate = DateTime(now.year, now.month, 1);
                    _endDate = now;
                  });
                },
              ),
              ActionChip(
                label: Text(isArabic ? 'آخر 3 شهور' : 'Last 3 Months'),
                onPressed: () {
                  final now = DateTime.now();
                  setState(() {
                    _startDate = DateTime(now.year, now.month - 3, 1);
                    _endDate = now;
                  });
                },
              ),
              ActionChip(
                label: Text(isArabic ? 'هذه السنة' : 'This Year'),
                onPressed: () {
                  final now = DateTime.now();
                  setState(() {
                    _startDate = DateTime(now.year, 1, 1);
                    _endDate = now;
                  });
                },
              ),
              ActionChip(
                label: Text(isArabic ? 'الكل' : 'All Time'),
                onPressed: () {
                  setState(() {
                    _startDate = DateTime(2020, 1, 1);
                    _endDate = DateTime.now();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Export Options
          Text(
            isArabic ? 'خيارات التصدير' : 'Export Options',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Export to CSV
          _buildExportOption(
            icon: Icons.table_chart,
            title: isArabic ? 'تصدير CSV' : 'Export CSV',
            subtitle: isArabic
                ? 'جدول بيانات يمكن فتحه في Excel'
                : 'Spreadsheet file for Excel',
            color: Colors.green,
            onTap: _isExporting
                ? null
                : () => _exportCSV(transactionProvider, appProvider),
          ),

          // Export Text Report
          _buildExportOption(
            icon: Icons.description,
            title: isArabic ? 'تقرير نصي' : 'Text Report',
            subtitle: isArabic ? 'ملخص مالي للفترة المحددة' : 'Financial summary for the period',
            color: Colors.blue,
            onTap: _isExporting
                ? null
                : () => _shareTextReport(transactionProvider, appProvider),
          ),

          const SizedBox(height: 32),

          // Backup Section
          Text(
            isArabic ? 'النسخ الاحتياطي' : 'Backup',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Create Backup
          _buildExportOption(
            icon: Icons.backup,
            title: isArabic ? 'إنشاء نسخة احتياطية' : 'Create Backup',
            subtitle: isArabic
                ? 'حفظ جميع البيانات في ملف JSON'
                : 'Save all data to JSON file',
            color: AppTheme.primaryColor,
            onTap: _isExporting
                ? null
                : () => _createBackup(transactionProvider, budgetProvider),
          ),

          // Restore Backup
          _buildExportOption(
            icon: Icons.restore,
            title: isArabic ? 'استعادة نسخة احتياطية' : 'Restore Backup',
            subtitle: isArabic
                ? 'استعادة البيانات من ملف سابق'
                : 'Restore data from a previous file',
            color: Colors.orange,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isArabic ? 'قريباً!' : 'Coming soon!'),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Statistics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'إحصائيات البيانات' : 'Data Statistics',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    isArabic ? 'إجمالي المعاملات' : 'Total Transactions',
                    '${transactionProvider.transactions.length}',
                  ),
                  _buildStatRow(
                    isArabic ? 'إجمالي الميزانيات' : 'Total Budgets',
                    '${budgetProvider.budgets.length}',
                  ),
                  _buildStatRow(
                    isArabic ? 'المعاملات في النطاق' : 'Transactions in Range',
                    '${_getTransactionsInRange(transactionProvider).length}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime date, Function(DateTime) onChanged) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd/MM/yyyy').format(date),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: _isExporting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  List _getTransactionsInRange(TransactionProvider provider) {
    return provider.transactions.where((t) =>
        t.date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
        t.date.isBefore(_endDate.add(const Duration(days: 1)))).toList();
  }

  Future<void> _exportCSV(TransactionProvider provider, AppProvider appProvider) async {
    setState(() => _isExporting = true);

    try {
      final transactions = _getTransactionsInRange(provider);
      final filePath = await ExportService.exportToCSV(
        transactions: transactions.cast(),
        currencySymbol: appProvider.currencySymbol,
        isArabic: appProvider.isArabic,
      );

      if (filePath != null && mounted) {
        await ExportService.shareFile(
          filePath,
          appProvider.isArabic ? 'تصدير مصروفي' : 'Masroofy Export',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appProvider.isArabic ? 'حدث خطأ' : 'An error occurred'),
            backgroundColor: AppTheme.expenseColor,
          ),
        );
      }
    }

    setState(() => _isExporting = false);
  }

  Future<void> _shareTextReport(TransactionProvider provider, AppProvider appProvider) async {
    final report = ExportService.generateTextReport(
      transactions: provider.transactions,
      currencySymbol: appProvider.currencySymbol,
      isArabic: appProvider.isArabic,
      startDate: _startDate,
      endDate: _endDate,
    );

    await Share.share(
      report,
      subject: appProvider.isArabic ? 'تقرير مصروفي' : 'Masroofy Report',
    );
  }

  Future<void> _createBackup(TransactionProvider transactionProvider, BudgetProvider budgetProvider) async {
    final appProvider = context.read<AppProvider>();
    setState(() => _isExporting = true);

    try {
      final filePath = await ExportService.exportToJSON(
        transactions: transactionProvider.transactions,
        budgets: budgetProvider.budgets,
      );

      if (filePath != null && mounted) {
        await ExportService.shareFile(
          filePath,
          appProvider.isArabic ? 'نسخة احتياطية مصروفي' : 'Masroofy Backup',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              appProvider.isArabic
                  ? 'تم إنشاء النسخة الاحتياطية بنجاح!'
                  : 'Backup created successfully!',
            ),
            backgroundColor: AppTheme.incomeColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appProvider.isArabic ? 'حدث خطأ' : 'An error occurred'),
            backgroundColor: AppTheme.expenseColor,
          ),
        );
      }
    }

    setState(() => _isExporting = false);
  }
}
