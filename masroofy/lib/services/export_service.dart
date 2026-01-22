import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../data/models/transaction_model.dart';
import '../data/models/budget_model.dart';

class ExportService {
  // Export transactions to CSV
  static Future<String?> exportToCSV({
    required List<TransactionModel> transactions,
    required String currencySymbol,
    required bool isArabic,
  }) async {
    try {
      final StringBuffer csv = StringBuffer();

      // Header
      if (isArabic) {
        csv.writeln('التاريخ,العنوان,المبلغ,النوع,الفئة,ملاحظة');
      } else {
        csv.writeln('Date,Title,Amount,Type,Category,Note');
      }

      // Data
      for (var t in transactions) {
        final date = DateFormat('yyyy-MM-dd').format(t.date);
        final type = t.type == TransactionType.income
            ? (isArabic ? 'دخل' : 'Income')
            : (isArabic ? 'مصروف' : 'Expense');
        final amount = '${t.amount.toStringAsFixed(2)} $currencySymbol';
        final note = t.note?.replaceAll(',', ';') ?? '';
        final title = t.title.replaceAll(',', ';');

        csv.writeln('$date,$title,$amount,$type,${t.categoryId},$note');
      }

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/masroofy_export_$timestamp.csv');
      await file.writeAsString(csv.toString());

      return file.path;
    } catch (e) {
      debugPrint('Error exporting CSV: $e');
      return null;
    }
  }

  // Export transactions to JSON (for backup)
  static Future<String?> exportToJSON({
    required List<TransactionModel> transactions,
    required List<BudgetModel> budgets,
  }) async {
    try {
      final data = {
        'exportDate': DateTime.now().toIso8601String(),
        'appVersion': '1.0.0',
        'transactions': transactions.map((t) => t.toMap()).toList(),
        'budgets': budgets.map((b) => b.toMap()).toList(),
      };

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/masroofy_backup_$timestamp.json');
      await file.writeAsString(jsonEncode(data));

      return file.path;
    } catch (e) {
      debugPrint('Error exporting JSON: $e');
      return null;
    }
  }

  // Import from JSON backup
  static Future<Map<String, dynamic>?> importFromJSON(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      return data;
    } catch (e) {
      debugPrint('Error importing JSON: $e');
      return null;
    }
  }

  // Share file
  static Future<void> shareFile(String filePath, String subject) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: subject,
      );
    } catch (e) {
      debugPrint('Error sharing file: $e');
    }
  }

  // Generate text report
  static String generateTextReport({
    required List<TransactionModel> transactions,
    required String currencySymbol,
    required bool isArabic,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final filtered = transactions.where((t) =>
        t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
        t.date.isBefore(endDate.add(const Duration(days: 1)))).toList();

    final totalIncome = filtered
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpense = filtered
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final balance = totalIncome - totalExpense;

    final StringBuffer report = StringBuffer();

    if (isArabic) {
      report.writeln('═══════════════════════════════════');
      report.writeln('           تقرير مصروفي');
      report.writeln('═══════════════════════════════════');
      report.writeln();
      report.writeln('الفترة: ${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}');
      report.writeln();
      report.writeln('───────────────────────────────────');
      report.writeln('الملخص المالي');
      report.writeln('───────────────────────────────────');
      report.writeln('إجمالي الدخل:    ${totalIncome.toStringAsFixed(2)} $currencySymbol');
      report.writeln('إجمالي المصاريف: ${totalExpense.toStringAsFixed(2)} $currencySymbol');
      report.writeln('الرصيد:          ${balance.toStringAsFixed(2)} $currencySymbol');
      report.writeln();
      report.writeln('───────────────────────────────────');
      report.writeln('عدد المعاملات: ${filtered.length}');
      report.writeln('═══════════════════════════════════');
    } else {
      report.writeln('═══════════════════════════════════');
      report.writeln('         Masroofy Report');
      report.writeln('═══════════════════════════════════');
      report.writeln();
      report.writeln('Period: ${DateFormat('MM/dd/yyyy').format(startDate)} - ${DateFormat('MM/dd/yyyy').format(endDate)}');
      report.writeln();
      report.writeln('───────────────────────────────────');
      report.writeln('Financial Summary');
      report.writeln('───────────────────────────────────');
      report.writeln('Total Income:   ${totalIncome.toStringAsFixed(2)} $currencySymbol');
      report.writeln('Total Expenses: ${totalExpense.toStringAsFixed(2)} $currencySymbol');
      report.writeln('Balance:        ${balance.toStringAsFixed(2)} $currencySymbol');
      report.writeln();
      report.writeln('───────────────────────────────────');
      report.writeln('Number of transactions: ${filtered.length}');
      report.writeln('═══════════════════════════════════');
    }

    return report.toString();
  }
}
