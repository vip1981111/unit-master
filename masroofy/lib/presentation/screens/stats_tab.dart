import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../providers/transaction_provider.dart';
import '../../data/models/transaction_model.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  int _selectedPeriod = 0; // 0: Week, 1: Month, 2: Year

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final transactionProvider = context.watch<TransactionProvider>();
    final isArabic = appProvider.isArabic;

    final expenseStats =
        transactionProvider.getCategoryStats(TransactionType.expense);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            title: Text(
              isArabic ? 'الإحصائيات' : 'Statistics',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          // Period Selector
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildPeriodChip(0, isArabic ? 'أسبوع' : 'Week'),
                  const SizedBox(width: 8),
                  _buildPeriodChip(1, isArabic ? 'شهر' : 'Month'),
                  const SizedBox(width: 8),
                  _buildPeriodChip(2, isArabic ? 'سنة' : 'Year'),
                ],
              ),
            ),
          ),

          // Summary Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      isArabic ? 'الدخل' : 'Income',
                      transactionProvider.totalIncome,
                      AppTheme.incomeColor,
                      appProvider.currencySymbol,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      isArabic ? 'المصاريف' : 'Expenses',
                      transactionProvider.totalExpense,
                      AppTheme.expenseColor,
                      appProvider.currencySymbol,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Pie Chart
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'توزيع المصاريف' : 'Expense Distribution',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (expenseStats.isEmpty)
                        SizedBox(
                          height: 200,
                          child: Center(
                            child: Text(
                              isArabic
                                  ? 'لا توجد بيانات'
                                  : 'No data available',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: _buildPieSections(
                                  expenseStats, transactionProvider),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Category Breakdown
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                isArabic ? 'تفصيل الفئات' : 'Category Breakdown',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = expenseStats.entries.toList()[index];
                final category = transactionProvider.getCategoryById(entry.key);
                if (category == null) return const SizedBox();

                final total = transactionProvider.totalExpense;
                final percentage = total > 0 ? (entry.value / total) * 100 : 0;

                return _buildCategoryItem(
                  category.icon,
                  isArabic ? category.name : category.nameEn,
                  entry.value,
                  percentage,
                  category.color,
                  appProvider.currencySymbol,
                );
              },
              childCount: expenseStats.length,
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(int index, String label) {
    final isSelected = _selectedPeriod == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedPeriod = index);
      },
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, double amount, Color color, String symbol) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${amount.toStringAsFixed(2)} $symbol',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(
      Map<String, double> stats, TransactionProvider provider) {
    final total = stats.values.fold(0.0, (a, b) => a + b);
    return stats.entries.map((entry) {
      final category = provider.getCategoryById(entry.key);
      final percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        color: category?.color ?? Colors.grey,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildCategoryItem(String icon, String name, double amount,
      double percentage, Color color, String symbol) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${amount.toStringAsFixed(2)} $symbol',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
