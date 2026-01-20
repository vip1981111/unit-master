class BudgetModel {
  final String id;
  final String name;
  final double amount;
  final double spent;
  final String categoryId;
  final String period; // monthly, weekly, yearly
  final DateTime startDate;
  final DateTime endDate;
  final bool notifyOnLimit;
  final int notifyAtPercent;

  BudgetModel({
    required this.id,
    required this.name,
    required this.amount,
    this.spent = 0,
    required this.categoryId,
    this.period = 'monthly',
    required this.startDate,
    required this.endDate,
    this.notifyOnLimit = true,
    this.notifyAtPercent = 80,
  });

  double get remaining => amount - spent;
  double get percentUsed => (spent / amount) * 100;
  bool get isOverBudget => spent > amount;

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as String,
      name: map['name'] as String,
      amount: map['amount'] as double,
      spent: map['spent'] as double? ?? 0,
      categoryId: map['categoryId'] as String,
      period: map['period'] as String? ?? 'monthly',
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      notifyOnLimit: map['notifyOnLimit'] == 1,
      notifyAtPercent: map['notifyAtPercent'] as int? ?? 80,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'spent': spent,
      'categoryId': categoryId,
      'period': period,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'notifyOnLimit': notifyOnLimit ? 1 : 0,
      'notifyAtPercent': notifyAtPercent,
    };
  }

  BudgetModel copyWith({
    String? id,
    String? name,
    double? amount,
    double? spent,
    String? categoryId,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? notifyOnLimit,
    int? notifyAtPercent,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      categoryId: categoryId ?? this.categoryId,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notifyOnLimit: notifyOnLimit ?? this.notifyOnLimit,
      notifyAtPercent: notifyAtPercent ?? this.notifyAtPercent,
    );
  }
}
