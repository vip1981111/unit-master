import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';
import '../../core/constants/app_constants.dart';

class TransactionProvider extends ChangeNotifier {
  final List<TransactionModel> _transactions = [];
  final List<CategoryModel> _expenseCategories = [];
  final List<CategoryModel> _incomeCategories = [];
  bool _isLoading = false;

  // Getters
  List<TransactionModel> get transactions => _transactions;
  List<TransactionModel> get recentTransactions =>
      _transactions.take(10).toList();
  List<CategoryModel> get expenseCategories => _expenseCategories;
  List<CategoryModel> get incomeCategories => _incomeCategories;
  bool get isLoading => _isLoading;

  // Computed Values
  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  TransactionProvider() {
    _initializeCategories();
    _loadTransactions();
  }

  void _initializeCategories() {
    // Initialize expense categories
    for (var cat in AppConstants.expenseCategories) {
      _expenseCategories.add(CategoryModel(
        id: cat['id'] as String,
        name: cat['name'] as String,
        nameEn: cat['nameEn'] as String,
        icon: cat['icon'] as String,
        color: Color(cat['color'] as int),
        isIncome: false,
      ));
    }

    // Initialize income categories
    for (var cat in AppConstants.incomeCategories) {
      _incomeCategories.add(CategoryModel(
        id: cat['id'] as String,
        name: cat['name'] as String,
        nameEn: cat['nameEn'] as String,
        icon: cat['icon'] as String,
        color: Color(cat['color'] as int),
        isIncome: true,
      ));
    }
  }

  Future<void> _loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    // TODO: Load from database
    // For now, add some sample data
    await Future.delayed(const Duration(milliseconds: 500));

    _isLoading = false;
    notifyListeners();
  }

  // Add Transaction
  Future<void> addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required String categoryId,
    String? note,
    required DateTime date,
    String? receiptImage,
    bool isRecurring = false,
    String? recurringPeriod,
  }) async {
    final transaction = TransactionModel(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      type: type,
      categoryId: categoryId,
      note: note,
      date: date,
      receiptImage: receiptImage,
      isRecurring: isRecurring,
      recurringPeriod: recurringPeriod,
    );

    _transactions.insert(0, transaction);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();

    // TODO: Save to database
  }

  // Update Transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();

      // TODO: Update in database
    }
  }

  // Delete Transaction
  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();

    // TODO: Delete from database
  }

  // Get Transactions by Category
  List<TransactionModel> getTransactionsByCategory(String categoryId) {
    return _transactions
        .where((t) => t.categoryId == categoryId)
        .toList();
  }

  // Get Transactions by Date Range
  List<TransactionModel> getTransactionsByDateRange(
      DateTime start, DateTime end) {
    return _transactions
        .where((t) => t.date.isAfter(start) && t.date.isBefore(end))
        .toList();
  }

  // Get Monthly Transactions
  List<TransactionModel> getMonthlyTransactions(int year, int month) {
    return _transactions
        .where((t) => t.date.year == year && t.date.month == month)
        .toList();
  }

  // Get Category Stats
  Map<String, double> getCategoryStats(TransactionType type) {
    final Map<String, double> stats = {};
    final filtered = _transactions.where((t) => t.type == type);

    for (var t in filtered) {
      stats[t.categoryId] = (stats[t.categoryId] ?? 0) + t.amount;
    }

    return stats;
  }

  // Get Category by ID
  CategoryModel? getCategoryById(String id, {bool isIncome = false}) {
    final categories = isIncome ? _incomeCategories : _expenseCategories;
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
