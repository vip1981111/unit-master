import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/transaction_model.dart';
import '../providers/app_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_item.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  TransactionType? _filterType;
  String? _filterCategory;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionModel> _getFilteredTransactions(TransactionProvider provider) {
    var transactions = provider.transactions.toList();

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      transactions = transactions.where((t) {
        return t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (t.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    // Filter by type
    if (_filterType != null) {
      transactions = transactions.where((t) => t.type == _filterType).toList();
    }

    // Filter by category
    if (_filterCategory != null) {
      transactions = transactions.where((t) => t.categoryId == _filterCategory).toList();
    }

    // Filter by date range
    if (_startDate != null) {
      transactions = transactions.where((t) =>
        t.date.isAfter(_startDate!.subtract(const Duration(days: 1)))
      ).toList();
    }
    if (_endDate != null) {
      transactions = transactions.where((t) =>
        t.date.isBefore(_endDate!.add(const Duration(days: 1)))
      ).toList();
    }

    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final transactionProvider = context.watch<TransactionProvider>();
    final isArabic = appProvider.isArabic;
    final filteredTransactions = _getFilteredTransactions(transactionProvider);

    // Group transactions by date
    final groupedTransactions = <String, List<TransactionModel>>{};
    for (var transaction in filteredTransactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(transaction.date);
      groupedTransactions.putIfAbsent(dateKey, () => []);
      groupedTransactions[dateKey]!.add(transaction);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'كل المعاملات' : 'All Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context, transactionProvider, isArabic),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: isArabic ? 'ابحث عن معاملة...' : 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Active Filters Chips
          if (_hasActiveFilters())
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (_filterType != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Chip(
                        label: Text(
                          _filterType == TransactionType.income
                              ? (isArabic ? 'دخل' : 'Income')
                              : (isArabic ? 'مصروف' : 'Expense'),
                        ),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => setState(() => _filterType = null),
                        backgroundColor: _filterType == TransactionType.income
                            ? AppTheme.incomeColor.withOpacity(0.2)
                            : AppTheme.expenseColor.withOpacity(0.2),
                      ),
                    ),
                  if (_filterCategory != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Chip(
                        label: Text(_getCategoryName(_filterCategory!, transactionProvider, isArabic)),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => setState(() => _filterCategory = null),
                      ),
                    ),
                  if (_startDate != null || _endDate != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Chip(
                        label: Text(_getDateRangeText(isArabic)),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => setState(() {
                          _startDate = null;
                          _endDate = null;
                        }),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ActionChip(
                      label: Text(isArabic ? 'مسح الكل' : 'Clear All'),
                      onPressed: _clearAllFilters,
                    ),
                  ),
                ],
              ),
            ),

          // Summary
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    isArabic ? 'الدخل' : 'Income',
                    _calculateTotal(filteredTransactions, TransactionType.income),
                    AppTheme.incomeColor,
                    appProvider.currencySymbol,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    isArabic ? 'المصاريف' : 'Expenses',
                    _calculateTotal(filteredTransactions, TransactionType.expense),
                    AppTheme.expenseColor,
                    appProvider.currencySymbol,
                  ),
                ),
              ],
            ),
          ),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  isArabic
                      ? '${filteredTransactions.length} معاملة'
                      : '${filteredTransactions.length} transactions',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Transactions List
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 64)),
                        const SizedBox(height: 16),
                        Text(
                          isArabic
                              ? 'لا توجد معاملات مطابقة'
                              : 'No matching transactions',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: groupedTransactions.length,
                    itemBuilder: (context, index) {
                      final dateKey = groupedTransactions.keys.toList()[index];
                      final dayTransactions = groupedTransactions[dateKey]!;
                      final date = DateTime.parse(dateKey);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              _formatDateHeader(date, isArabic),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          ...dayTransactions.map((transaction) {
                            final category = transactionProvider.getCategoryById(
                              transaction.categoryId,
                              isIncome: transaction.type == TransactionType.income,
                            );
                            return TransactionItem(
                              transaction: transaction,
                              category: category,
                              currencySymbol: appProvider.currencySymbol,
                              isArabic: isArabic,
                              onTap: () => _showTransactionDetails(context, transaction, transactionProvider, appProvider),
                              onDelete: () {
                                transactionProvider.deleteTransaction(transaction.id);
                              },
                            );
                          }),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _filterType != null ||
        _filterCategory != null ||
        _startDate != null ||
        _endDate != null;
  }

  void _clearAllFilters() {
    setState(() {
      _filterType = null;
      _filterCategory = null;
      _startDate = null;
      _endDate = null;
    });
  }

  String _getCategoryName(String categoryId, TransactionProvider provider, bool isArabic) {
    final category = provider.getCategoryById(categoryId) ??
                     provider.getCategoryById(categoryId, isIncome: true);
    if (category == null) return categoryId;
    return isArabic ? category.name : category.nameEn;
  }

  String _getDateRangeText(bool isArabic) {
    if (_startDate != null && _endDate != null) {
      return '${DateFormat('MM/dd').format(_startDate!)} - ${DateFormat('MM/dd').format(_endDate!)}';
    } else if (_startDate != null) {
      return isArabic ? 'من ${DateFormat('MM/dd').format(_startDate!)}' : 'From ${DateFormat('MM/dd').format(_startDate!)}';
    } else if (_endDate != null) {
      return isArabic ? 'حتى ${DateFormat('MM/dd').format(_endDate!)}' : 'Until ${DateFormat('MM/dd').format(_endDate!)}';
    }
    return '';
  }

  double _calculateTotal(List<TransactionModel> transactions, TransactionType type) {
    return transactions
        .where((t) => t.type == type)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  String _formatDateHeader(DateTime date, bool isArabic) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return isArabic ? 'اليوم' : 'Today';
    } else if (dateOnly == yesterday) {
      return isArabic ? 'أمس' : 'Yesterday';
    } else {
      return DateFormat(isArabic ? 'EEEE, d MMMM yyyy' : 'EEEE, MMMM d, yyyy', isArabic ? 'ar' : 'en')
          .format(date);
    }
  }

  Widget _buildSummaryCard(String title, double amount, Color color, String symbol) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
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
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, TransactionProvider provider, bool isArabic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              controller: scrollController,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isArabic ? 'فلترة المعاملات' : 'Filter Transactions',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Transaction Type
                Text(
                  isArabic ? 'نوع المعاملة' : 'Transaction Type',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterOption(
                        isArabic ? 'الكل' : 'All',
                        _filterType == null,
                        () {
                          setModalState(() => _filterType = null);
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterOption(
                        isArabic ? 'دخل' : 'Income',
                        _filterType == TransactionType.income,
                        () {
                          setModalState(() => _filterType = TransactionType.income);
                          setState(() {});
                        },
                        color: AppTheme.incomeColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterOption(
                        isArabic ? 'مصروف' : 'Expense',
                        _filterType == TransactionType.expense,
                        () {
                          setModalState(() => _filterType = TransactionType.expense);
                          setState(() {});
                        },
                        color: AppTheme.expenseColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Categories
                Text(
                  isArabic ? 'الفئة' : 'Category',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(isArabic ? 'الكل' : 'All'),
                      selected: _filterCategory == null,
                      onSelected: (_) {
                        setModalState(() => _filterCategory = null);
                        setState(() {});
                      },
                    ),
                    ...(_filterType == TransactionType.income
                            ? provider.incomeCategories
                            : provider.expenseCategories)
                        .map((cat) => ChoiceChip(
                              avatar: Text(cat.icon),
                              label: Text(isArabic ? cat.name : cat.nameEn),
                              selected: _filterCategory == cat.id,
                              selectedColor: cat.color.withOpacity(0.3),
                              onSelected: (_) {
                                setModalState(() => _filterCategory = cat.id);
                                setState(() {});
                              },
                            )),
                  ],
                ),
                const SizedBox(height: 20),

                // Date Range
                Text(
                  isArabic ? 'الفترة الزمنية' : 'Date Range',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(_startDate != null
                            ? DateFormat('MM/dd/yyyy').format(_startDate!)
                            : (isArabic ? 'من' : 'From')),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setModalState(() => _startDate = date);
                            setState(() {});
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(_endDate != null
                            ? DateFormat('MM/dd/yyyy').format(_endDate!)
                            : (isArabic ? 'إلى' : 'To')),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setModalState(() => _endDate = date);
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Quick Date Filters
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      label: Text(isArabic ? 'اليوم' : 'Today'),
                      onPressed: () {
                        final today = DateTime.now();
                        setModalState(() {
                          _startDate = DateTime(today.year, today.month, today.day);
                          _endDate = DateTime(today.year, today.month, today.day);
                        });
                        setState(() {});
                      },
                    ),
                    ActionChip(
                      label: Text(isArabic ? 'هذا الأسبوع' : 'This Week'),
                      onPressed: () {
                        final now = DateTime.now();
                        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                        setModalState(() {
                          _startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
                          _endDate = DateTime(now.year, now.month, now.day);
                        });
                        setState(() {});
                      },
                    ),
                    ActionChip(
                      label: Text(isArabic ? 'هذا الشهر' : 'This Month'),
                      onPressed: () {
                        final now = DateTime.now();
                        setModalState(() {
                          _startDate = DateTime(now.year, now.month, 1);
                          _endDate = DateTime(now.year, now.month, now.day);
                        });
                        setState(() {});
                      },
                    ),
                    ActionChip(
                      label: Text(isArabic ? 'آخر 30 يوم' : 'Last 30 Days'),
                      onPressed: () {
                        final now = DateTime.now();
                        setModalState(() {
                          _startDate = now.subtract(const Duration(days: 30));
                          _endDate = DateTime(now.year, now.month, now.day);
                        });
                        setState(() {});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isArabic ? 'تطبيق الفلتر' : 'Apply Filter'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, bool isSelected, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? (color ?? AppTheme.primaryColor).withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? (color ?? AppTheme.primaryColor) : Colors.grey[300]!,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? (color ?? AppTheme.primaryColor) : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(
    BuildContext context,
    TransactionModel transaction,
    TransactionProvider provider,
    AppProvider appProvider,
  ) {
    final isArabic = appProvider.isArabic;
    final category = provider.getCategoryById(
      transaction.categoryId,
      isIncome: transaction.type == TransactionType.income,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: (category?.color ?? Colors.grey).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  category?.icon ?? '📦',
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Amount
            Text(
              '${transaction.type == TransactionType.income ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} ${appProvider.currencySymbol}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: transaction.type == TransactionType.income
                    ? AppTheme.incomeColor
                    : AppTheme.expenseColor,
              ),
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              transaction.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // Details
            _buildDetailRow(
              Icons.category,
              isArabic ? 'الفئة' : 'Category',
              isArabic ? (category?.name ?? '') : (category?.nameEn ?? ''),
            ),
            _buildDetailRow(
              Icons.calendar_today,
              isArabic ? 'التاريخ' : 'Date',
              DateFormat(isArabic ? 'dd/MM/yyyy' : 'MM/dd/yyyy').format(transaction.date),
            ),
            if (transaction.note != null && transaction.note!.isNotEmpty)
              _buildDetailRow(
                Icons.note,
                isArabic ? 'ملاحظة' : 'Note',
                transaction.note!,
              ),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete_outline, color: AppTheme.expenseColor),
                    label: Text(
                      isArabic ? 'حذف' : 'Delete',
                      style: const TextStyle(color: AppTheme.expenseColor),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.expenseColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      provider.deleteTransaction(transaction.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isArabic ? 'تم حذف المعاملة' : 'Transaction deleted'),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: Text(isArabic ? 'تعديل' : 'Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Open edit screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isArabic ? 'قريباً!' : 'Coming soon!'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
