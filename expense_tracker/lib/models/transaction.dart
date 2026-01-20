import 'category.dart';

enum TransactionType { expense, income }

class Transaction {
  final int? id;
  final double amount;
  final String description;
  final DateTime date;
  final int categoryId;
  final TransactionType type;
  final String? note;
  final String? attachmentPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  // For display purposes (not stored in DB)
  Category? category;

  Transaction({
    this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.categoryId,
    required this.type,
    this.note,
    this.attachmentPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.category,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'category_id': categoryId,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'note': note,
      'attachment_path': attachmentPath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount'].toDouble(),
      description: map['description'],
      date: DateTime.parse(map['date']),
      categoryId: map['category_id'],
      type: map['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      note: map['note'],
      attachmentPath: map['attachment_path'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Transaction copyWith({
    int? id,
    double? amount,
    String? description,
    DateTime? date,
    int? categoryId,
    TransactionType? type,
    String? note,
    String? attachmentPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    Category? category,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      note: note ?? this.note,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      category: category ?? this.category,
    );
  }

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;

  @override
  String toString() {
    return 'Transaction(id: $id, amount: $amount, description: $description, date: $date, type: $type)';
  }
}
