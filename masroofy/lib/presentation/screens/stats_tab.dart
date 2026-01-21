import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../providers/transaction_provider.dart';
import '../../data/models/transaction_model.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> with SingleTickerProviderStateMixin {
  int _selectedPeriod = 1; // 0: Week, 1: Month, 2: Year
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  DateTime get _startDate {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 0:
        return now.subtract(const Duration(days: 7));
      case 1:
        return DateTime(now.year, now.month, 1);
      case 2:
        return DateTime(now.year, 1, 1);
      default:
        return DateTime(now.year, now.month, 1);
    }
  }

  List<TransactionModel> _getFilteredTransactions(TransactionProvider provider) {
    return provider.transactions.where((t) {
      return t.date.isAfter(_startDate.subtract(const Duration(days: 1)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final transactionProvider = context.watch<TransactionProvider>();
    final isArabic = appProvider.isArabic;

    final filteredTransactions = _getFilteredTransactions(transactionProvider);
    final expenseStats = _getCategoryStats(filteredTransactions, TransactionType.expense);
    final incomeStats = _getCategoryStats(filteredTransactions, TransactionType.income);

    final totalIncome = filteredTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = filteredTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return SafeArea(
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            title: Text(
              isArabic ? 'الإحصائيات' : 'Statistics',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Column(
                children: [
                  // Period Selector
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: isArabic ? 'المصاريف' : 'Expenses'),
                      Tab(text: isArabic ? 'الدخل' : 'Income'),
                    ],
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // Expenses Tab
            _buildStatsContent(
              context,
              isArabic,
              expenseStats,
              totalExpense,
              totalIncome,
              transactionProvider,
              appProvider,
              isExpense: true,
              transactions: filteredTransactions,
            ),
            // Income Tab
            _buildStatsContent(
              context,
              isArabic,
              incomeStats,
              totalIncome,
              totalExpense,
              transactionProvider,
              appProvider,
              isExpense: false,
              transactions: filteredTransactions,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsContent(
    BuildContext context,
    bool isArabic,
    Map<String, double> stats,
    double total,
    double otherTotal,
    TransactionProvider transactionProvider,
    AppProvider appProvider, {
    required bool isExpense,
    required List<TransactionModel> transactions,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary Cards
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                isArabic ? 'الإجمالي' : 'Total',
                total,
                isExpense ? AppTheme.expenseColor : AppTheme.incomeColor,
                appProvider.currencySymbol,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                isArabic ? 'المتوسط اليومي' : 'Daily Avg',
                _calculateDailyAverage(total),
                Colors.grey,
                appProvider.currencySymbol,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Balance Card (Income vs Expense comparison)
        _buildBalanceCard(isArabic, total, otherTotal, isExpense, appProvider.currencySymbol),
        const SizedBox(height: 16),

        // Line Chart - Trend Over Time
        _buildTrendChart(isArabic, transactions, isExpense),
        const SizedBox(height: 16),

        // Pie Chart
        _buildPieChartCard(isArabic, stats, transactionProvider),
        const SizedBox(height: 16),

        // Bar Chart - Daily/Weekly/Monthly comparison
        _buildBarChart(isArabic, transactions, isExpense, appProvider.currencySymbol),
        const SizedBox(height: 16),

        // Category Breakdown Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            isArabic ? 'تفصيل الفئات' : 'Category Breakdown',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Category List
        if (stats.isEmpty)
          _buildEmptyState(isArabic)
        else
          ...stats.entries.map((entry) {
            final category = transactionProvider.getCategoryById(
              entry.key,
              isIncome: !isExpense,
            );
            if (category == null) return const SizedBox();

            final percentage = total > 0 ? (entry.value / total) * 100 : 0;

            return _buildCategoryItem(
              category.icon,
              isArabic ? category.name : category.nameEn,
              entry.value,
              percentage,
              category.color,
              appProvider.currencySymbol,
            );
          }),

        const SizedBox(height: 100),
      ],
    );
  }

  Map<String, double> _getCategoryStats(List<TransactionModel> transactions, TransactionType type) {
    final Map<String, double> stats = {};
    final filtered = transactions.where((t) => t.type == type);

    for (var t in filtered) {
      stats[t.categoryId] = (stats[t.categoryId] ?? 0) + t.amount;
    }

    // Sort by amount descending
    final sortedEntries = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }

  double _calculateDailyAverage(double total) {
    final days = DateTime.now().difference(_startDate).inDays + 1;
    return days > 0 ? total / days : 0;
  }

  Widget _buildBalanceCard(bool isArabic, double total, double otherTotal, bool isExpense, String symbol) {
    final balance = isExpense ? otherTotal - total : total - otherTotal;
    final percentage = otherTotal > 0 ? (total / otherTotal) * 100 : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'الميزانية' : 'Balance Overview',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        isExpense
                            ? (isArabic ? 'المصاريف' : 'Expenses')
                            : (isArabic ? 'الدخل' : 'Income'),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${total.toStringAsFixed(0)} $symbol',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isExpense ? AppTheme.expenseColor : AppTheme.incomeColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        isExpense
                            ? (isArabic ? 'الدخل' : 'Income')
                            : (isArabic ? 'المصاريف' : 'Expenses'),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${otherTotal.toStringAsFixed(0)} $symbol',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isExpense ? AppTheme.incomeColor : AppTheme.expenseColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        isArabic ? 'الرصيد' : 'Balance',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${balance >= 0 ? '+' : ''}${balance.toStringAsFixed(0)} $symbol',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: balance >= 0 ? AppTheme.incomeColor : AppTheme.expenseColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage > 100 ? 1 : percentage / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(
                  isExpense ? AppTheme.expenseColor : AppTheme.incomeColor,
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isExpense
                  ? (isArabic
                      ? 'أنفقت ${percentage.toStringAsFixed(0)}% من دخلك'
                      : 'Spent ${percentage.toStringAsFixed(0)}% of income')
                  : (isArabic
                      ? 'الدخل ${percentage.toStringAsFixed(0)}% من المصاريف'
                      : 'Income is ${percentage.toStringAsFixed(0)}% of expenses'),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart(bool isArabic, List<TransactionModel> transactions, bool isExpense) {
    final type = isExpense ? TransactionType.expense : TransactionType.income;
    final filtered = transactions.where((t) => t.type == type).toList();

    // Group by day
    final Map<String, double> dailyTotals = {};
    for (var t in filtered) {
      final key = DateFormat('MM-dd').format(t.date);
      dailyTotals[key] = (dailyTotals[key] ?? 0) + t.amount;
    }

    // Get last 7 days
    final List<FlSpot> spots = [];
    final List<String> labels = [];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final key = DateFormat('MM-dd').format(date);
      spots.add(FlSpot((6 - i).toDouble(), dailyTotals[key] ?? 0));
      labels.add(DateFormat('E').format(date));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'الاتجاه (آخر 7 أيام)' : 'Trend (Last 7 Days)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: spots.every((s) => s.y == 0)
                  ? Center(
                      child: Text(
                        isArabic ? 'لا توجد بيانات' : 'No data',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: _getMaxValue(spots) / 4,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey[200]!,
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 && value.toInt() < labels.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      labels[value.toInt()],
                                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: isExpense ? AppTheme.expenseColor : AppTheme.incomeColor,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: (isExpense ? AppTheme.expenseColor : AppTheme.incomeColor)
                                  .withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxValue(List<FlSpot> spots) {
    if (spots.isEmpty) return 100;
    final max = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    return max > 0 ? max : 100;
  }

  Widget _buildBarChart(bool isArabic, List<TransactionModel> transactions, bool isExpense, String symbol) {
    final type = isExpense ? TransactionType.expense : TransactionType.income;
    final otherType = isExpense ? TransactionType.income : TransactionType.expense;

    // Group by day for last 7 days
    final Map<String, double> expenseTotals = {};
    final Map<String, double> incomeTotals = {};

    for (var t in transactions) {
      final key = DateFormat('MM-dd').format(t.date);
      if (t.type == TransactionType.expense) {
        expenseTotals[key] = (expenseTotals[key] ?? 0) + t.amount;
      } else {
        incomeTotals[key] = (incomeTotals[key] ?? 0) + t.amount;
      }
    }

    final List<BarChartGroupData> barGroups = [];
    final List<String> labels = [];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final key = DateFormat('MM-dd').format(date);
      labels.add(DateFormat('E').format(date));

      barGroups.add(
        BarChartGroupData(
          x: 6 - i,
          barRods: [
            BarChartRodData(
              toY: incomeTotals[key] ?? 0,
              color: AppTheme.incomeColor,
              width: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            BarChartRodData(
              toY: expenseTotals[key] ?? 0,
              color: AppTheme.expenseColor,
              width: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? 'المقارنة اليومية' : 'Daily Comparison',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    _buildLegendItem(isArabic ? 'دخل' : 'Income', AppTheme.incomeColor),
                    const SizedBox(width: 12),
                    _buildLegendItem(isArabic ? 'مصروف' : 'Expense', AppTheme.expenseColor),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey[200]!,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[value.toInt()],
                                style: TextStyle(color: Colors.grey[600], fontSize: 10),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: barGroups,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildPieChartCard(bool isArabic, Map<String, double> stats, TransactionProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'التوزيع حسب الفئة' : 'Distribution by Category',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (stats.isEmpty)
              SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    isArabic ? 'لا توجد بيانات' : 'No data available',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: Row(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: _buildPieSections(stats, provider),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: stats.entries.take(5).map((entry) {
                          final category = provider.getCategoryById(entry.key) ??
                                          provider.getCategoryById(entry.key, isIncome: true);
                          if (category == null) return const SizedBox();
                          final total = stats.values.fold(0.0, (a, b) => a + b);
                          final percentage = (entry.value / total) * 100;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: category.color,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isArabic ? category.name : category.nameEn,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${percentage.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
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

  Widget _buildSummaryCard(String title, double amount, Color color, String symbol) {
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
                fontSize: 12,
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

  List<PieChartSectionData> _buildPieSections(Map<String, double> stats, TransactionProvider provider) {
    final total = stats.values.fold(0.0, (a, b) => a + b);
    return stats.entries.map((entry) {
      final category = provider.getCategoryById(entry.key) ??
                      provider.getCategoryById(entry.key, isIncome: true);
      final percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        value: entry.value,
        title: percentage >= 5 ? '${percentage.toStringAsFixed(0)}%' : '',
        color: category?.color ?? Colors.grey,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildCategoryItem(String icon, String name, double amount,
      double percentage, Color color, String symbol) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
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
    );
  }

  Widget _buildEmptyState(bool isArabic) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Text('📊', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              isArabic ? 'لا توجد بيانات للعرض' : 'No data to display',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
