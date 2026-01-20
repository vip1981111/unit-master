import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/budget_model.dart';

class BudgetProvider extends ChangeNotifier {
  final List<BudgetModel> _budgets = [];
  bool _isLoading = false;

  List<BudgetModel> get budgets => _budgets;
  bool get isLoading => _isLoading;

  List<BudgetModel> get activeBudgets => _budgets
      .where((b) => b.endDate.isAfter(DateTime.now()))
      .toList();

  List<BudgetModel> get overBudgets => _budgets
      .where((b) => b.isOverBudget)
      .toList();

  BudgetProvider() {
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    _isLoading = true;
    notifyListeners();

    // TODO: Load from database
    await Future.delayed(const Duration(milliseconds: 300));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addBudget({
    required String name,
    required double amount,
    required String categoryId,
    String period = 'monthly',
    required DateTime startDate,
    required DateTime endDate,
    bool notifyOnLimit = true,
    int notifyAtPercent = 80,
  }) async {
    final budget = BudgetModel(
      id: const Uuid().v4(),
      name: name,
      amount: amount,
      categoryId: categoryId,
      period: period,
      startDate: startDate,
      endDate: endDate,
      notifyOnLimit: notifyOnLimit,
      notifyAtPercent: notifyAtPercent,
    );

    _budgets.add(budget);
    notifyListeners();

    // TODO: Save to database
  }

  Future<void> updateBudgetSpent(String categoryId, double amount) async {
    for (int i = 0; i < _budgets.length; i++) {
      if (_budgets[i].categoryId == categoryId) {
        _budgets[i] = _budgets[i].copyWith(
          spent: _budgets[i].spent + amount,
        );
      }
    }
    notifyListeners();
  }

  Future<void> deleteBudget(String id) async {
    _budgets.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  BudgetModel? getBudgetByCategory(String categoryId) {
    try {
      return _budgets.firstWhere((b) => b.categoryId == categoryId);
    } catch (_) {
      return null;
    }
  }
}
