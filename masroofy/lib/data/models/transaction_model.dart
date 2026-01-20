import 'package:flutter/material.dart';

enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String? note;
  final DateTime date;
  final String? receiptImage;
  final bool isRecurring;
  final String? recurringPeriod; // daily, weekly, monthly, yearly
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.note,
    required this.date,
    this.receiptImage,
    this.isRecurring = false,
    this.recurringPeriod,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // From Map (Database)
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: map['amount'] as double,
      type: TransactionType.values[map['type'] as int],
      categoryId: map['categoryId'] as String,
      note: map['note'] as String?,
      date: DateTime.parse(map['date'] as String),
      receiptImage: map['receiptImage'] as String?,
      isRecurring: map['isRecurring'] == 1,
      recurringPeriod: map['recurringPeriod'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // To Map (Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.index,
      'categoryId': categoryId,
      'note': note,
      'date': date.toIso8601String(),
      'receiptImage': receiptImage,
      'isRecurring': isRecurring ? 1 : 0,
      'recurringPeriod': recurringPeriod,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Copy with
  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? note,
    DateTime? date,
    String? receiptImage,
    bool? isRecurring,
    String? recurringPeriod,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      date: date ?? this.date,
      receiptImage: receiptImage ?? this.receiptImage,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPeriod: recurringPeriod ?? this.recurringPeriod,
      createdAt: createdAt,
    );
  }
}
