import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/transaction_provider.dart';

class BudgetTab extends StatelessWidget {
  const BudgetTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final transactionProvider = context.watch<TransactionProvider>();
    final isArabic = appProvider.isArabic;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            title: Text(
              isArabic ? 'الميزانية' : 'Budget',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddBudget(context, isArabic),
              ),
            ],
          ),

          // Overview Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        isArabic ? 'إجمالي الميزانية' : 'Total Budget',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${budgetProvider.budgets.fold(0.0, (sum, b) => sum + b.amount).toStringAsFixed(2)} ${appProvider.currencySymbol}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildOverviewItem(
                            isArabic ? 'المستخدم' : 'Spent',
                            budgetProvider.budgets
                                .fold(0.0, (sum, b) => sum + b.spent),
                            AppTheme.expenseColor,
                            appProvider.currencySymbol,
                          ),
                          _buildOverviewItem(
                            isArabic ? 'المتبقي' : 'Remaining',
                            budgetProvider.budgets
                                .fold(0.0, (sum, b) => sum + b.remaining),
                            AppTheme.incomeColor,
                            appProvider.currencySymbol,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Budgets Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                isArabic ? 'ميزانياتي' : 'My Budgets',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Budgets List
          if (budgetProvider.budgets.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🎯', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text(
                      isArabic
                          ? 'لم تُنشئ ميزانية بعد'
                          : 'No budgets created yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAddBudget(context, isArabic),
                      icon: const Icon(Icons.add),
                      label: Text(
                          isArabic ? 'إنشاء ميزانية' : 'Create Budget'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final budget = budgetProvider.budgets[index];
                  final category = transactionProvider.getCategoryById(
                    budget.categoryId,
                  );

                  return _buildBudgetCard(
                    context,
                    category?.icon ?? '📦',
                    budget.name,
                    budget.amount,
                    budget.spent,
                    budget.percentUsed,
                    category?.color ?? Colors.grey,
                    appProvider.currencySymbol,
                    isArabic,
                  );
                },
                childCount: budgetProvider.budgets.length,
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(
      String label, double amount, Color color, String symbol) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${amount.toStringAsFixed(2)} $symbol',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetCard(
    BuildContext context,
    String icon,
    String name,
    double amount,
    double spent,
    double percentage,
    Color color,
    String symbol,
    bool isArabic,
  ) {
    final isOver = percentage > 100;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${spent.toStringAsFixed(2)} / ${amount.toStringAsFixed(2)} $symbol',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isOver)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.expenseColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isArabic ? 'تجاوز!' : 'Over!',
                        style: const TextStyle(
                          color: AppTheme.expenseColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (percentage / 100).clamp(0, 1),
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(
                    isOver ? AppTheme.expenseColor : color,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${percentage.toStringAsFixed(0)}% ${isArabic ? 'مستخدم' : 'used'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddBudget(BuildContext context, bool isArabic) {
    final transactionProvider = context.read<TransactionProvider>();
    final budgetProvider = context.read<BudgetProvider>();
    final appProvider = context.read<AppProvider>();

    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String? selectedCategoryId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isArabic ? 'إنشاء ميزانية جديدة' : 'Create New Budget',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: isArabic ? 'اسم الميزانية' : 'Budget Name',
                  prefixIcon: const Icon(Icons.edit),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: isArabic ? 'المبلغ' : 'Amount',
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: appProvider.currencySymbol,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isArabic ? 'الفئة' : 'Category',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: transactionProvider.expenseCategories.map((cat) {
                  final isSelected = selectedCategoryId == cat.id;
                  return GestureDetector(
                    onTap: () => setState(() => selectedCategoryId = cat.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cat.color.withOpacity(0.2)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? cat.color : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(cat.icon, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(
                            isArabic ? cat.name : cat.nameEn,
                            style: TextStyle(
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? cat.color : Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text);
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isArabic
                              ? 'أدخل مبلغ صحيح'
                              : 'Enter a valid amount'),
                        ),
                      );
                      return;
                    }
                    if (selectedCategoryId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text(isArabic ? 'اختر فئة' : 'Select a category'),
                        ),
                      );
                      return;
                    }

                    final name = nameController.text.trim().isNotEmpty
                        ? nameController.text.trim()
                        : (isArabic ? 'ميزانية' : 'Budget');

                    final now = DateTime.now();
                    budgetProvider.addBudget(
                      name: name,
                      amount: amount,
                      categoryId: selectedCategoryId!,
                      startDate: DateTime(now.year, now.month, 1),
                      endDate: DateTime(now.year, now.month + 1, 0),
                    );

                    Navigator.pop(context);
                  },
                  child: Text(
                    isArabic ? 'إنشاء' : 'Create',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
