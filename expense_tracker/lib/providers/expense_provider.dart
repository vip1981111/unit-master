import 'package:flutter/foundation.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';

class ExpenseProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<Transaction> _transactions = [];
  List<Category> _expenseCategories = [];
  List<Category> _incomeCategories = [];
  double _totalExpenses = 0.0;
  double _totalIncome = 0.0;
  bool _isLoading = false;

  // Getters
  List<Transaction> get transactions => _transactions;
  List<Category> get expenseCategories => _expenseCategories;
  List<Category> get incomeCategories => _incomeCategories;
  List<Category> get allCategories => [..._expenseCategories, ..._incomeCategories];
  double get totalExpenses => _totalExpenses;
  double get totalIncome => _totalIncome;
  double get balance => _totalIncome - _totalExpenses;
  bool get isLoading => _isLoading;

  // Filter state
  DateTime? _startDate;
  DateTime? _endDate;
  TransactionType? _filterType;
  int? _filterCategoryId;

  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  TransactionType? get filterType => _filterType;
  int? get filterCategoryId => _filterCategoryId;

  ExpenseProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();

    await loadCategories();
    await loadTransactions();
    await _updateTotals();

    _isLoading = false;
    notifyListeners();
  }

  // ==================== Categories ====================

  Future<void> loadCategories() async {
    _expenseCategories = await _db.getCategories(isIncome: false);
    _incomeCategories = await _db.getCategories(isIncome: true);
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    await _db.insertCategory(category);
    await loadCategories();
  }

  Future<void> updateCategory(Category category) async {
    await _db.updateCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await _db.deleteCategory(id);
    await loadCategories();
  }

  Category? getCategoryById(int id) {
    try {
      return allCategories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // ==================== Transactions ====================

  Future<void> loadTransactions() async {
    _transactions = await _db.getTransactions(
      startDate: _startDate,
      endDate: _endDate,
      type: _filterType,
      categoryId: _filterCategoryId,
    );
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _db.insertTransaction(transaction);
    await loadTransactions();
    await _updateTotals();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _db.updateTransaction(transaction);
    await loadTransactions();
    await _updateTotals();
  }

  Future<void> deleteTransaction(int id) async {
    await _db.deleteTransaction(id);
    await loadTransactions();
    await _updateTotals();
  }

  // ==================== Filters ====================

  void setDateFilter(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    loadTransactions();
    _updateTotals();
  }

  void setTypeFilter(TransactionType? type) {
    _filterType = type;
    loadTransactions();
  }

  void setCategoryFilter(int? categoryId) {
    _filterCategoryId = categoryId;
    loadTransactions();
  }

  void clearFilters() {
    _startDate = null;
    _endDate = null;
    _filterType = null;
    _filterCategoryId = null;
    loadTransactions();
    _updateTotals();
  }

  // ==================== Statistics ====================

  Future<void> _updateTotals() async {
    _totalExpenses = await _db.getTotalExpenses(
      startDate: _startDate,
      endDate: _endDate,
    );
    _totalIncome = await _db.getTotalIncome(
      startDate: _startDate,
      endDate: _endDate,
    );
    notifyListeners();
  }

  Future<Map<Category, double>> getExpensesByCategory() async {
    final expensesByCategoryId = await _db.getExpensesByCategory(
      startDate: _startDate,
      endDate: _endDate,
    );

    Map<Category, double> expensesByCategory = {};
    for (final entry in expensesByCategoryId.entries) {
      final category = getCategoryById(entry.key);
      if (category != null) {
        expensesByCategory[category] = entry.value;
      }
    }

    return expensesByCategory;
  }

  Future<List<Map<String, dynamic>>> getDailyTotals({
    required DateTime startDate,
    required DateTime endDate,
    TransactionType? type,
  }) async {
    return await _db.getDailyTotals(
      startDate: startDate,
      endDate: endDate,
      type: type,
    );
  }

  // Current month transactions
  List<Transaction> get currentMonthTransactions {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return _transactions.where((t) {
      return t.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          t.date.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();
  }

  // Today's transactions
  List<Transaction> get todayTransactions {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _transactions.where((t) {
      return t.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(endOfDay.add(const Duration(seconds: 1)));
    }).toList();
  }

  // Recent transactions (last 5)
  List<Transaction> get recentTransactions {
    return _transactions.take(5).toList();
  }

  // ==================== Utility ====================

  Future<void> refresh() async {
    await _initializeData();
  }
}
