import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/category.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer2<ExpenseProvider, SettingsProvider>(
        builder: (context, expenseProvider, settings, _) {
          return CustomScrollView(
            slivers: [
              const SliverAppBar(
                floating: true,
                title: Text('الإحصائيات'),
              ),

              // Summary Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'إجمالي الدخل',
                          amount: expenseProvider.totalIncome,
                          color: AppTheme.incomeColor,
                          icon: Icons.trending_up,
                          currencySymbol: settings.currencySymbol,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'إجمالي المصاريف',
                          amount: expenseProvider.totalExpenses,
                          color: AppTheme.expenseColor,
                          icon: Icons.trending_down,
                          currencySymbol: settings.currencySymbol,
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
                          const Text(
                            'المصاريف حسب التصنيف',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          FutureBuilder<Map<Category, double>>(
                            future: expenseProvider.getExpensesByCategory(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: Text(
                                      'لا توجد بيانات',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                );
                              }

                              final data = snapshot.data!;
                              return Column(
                                children: [
                                  SizedBox(
                                    height: 200,
                                    child: PieChart(
                                      PieChartData(
                                        pieTouchData: PieTouchData(
                                          touchCallback: (event, response) {
                                            setState(() {
                                              if (!event.isInterestedForInteractions ||
                                                  response == null ||
                                                  response.touchedSection == null) {
                                                _touchedIndex = -1;
                                                return;
                                              }
                                              _touchedIndex = response
                                                  .touchedSection!.touchedSectionIndex;
                                            });
                                          },
                                        ),
                                        sectionsSpace: 2,
                                        centerSpaceRadius: 40,
                                        sections: _buildPieSections(data),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildLegend(data, settings.currencySymbol),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Monthly Trend (Placeholder)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'الاتجاه الشهري',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 200,
                            child: Center(
                              child: Text(
                                'قريباً',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          );
        },
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<Category, double> data) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    int index = 0;

    return data.entries.map((entry) {
      final isTouched = index == _touchedIndex;
      final percentage = (entry.value / total * 100).toStringAsFixed(1);
      final radius = isTouched ? 60.0 : 50.0;
      final fontSize = isTouched ? 14.0 : 12.0;

      index++;

      return PieChartSectionData(
        color: entry.key.color,
        value: entry.value,
        title: '$percentage%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(Map<Category, double> data, String currencySymbol) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: data.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: entry.key.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${entry.key.nameAr}: ${entry.value.toStringAsFixed(0)} $currencySymbol',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;
  final String currencySymbol;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${amount.toStringAsFixed(2)} $currencySymbol',
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
}
