import 'package:flutter/material.dart';

class Category {
  final int? id;
  final String name;
  final String nameAr;
  final IconData icon;
  final Color color;
  final bool isIncome;
  final bool isDefault;

  const Category({
    this.id,
    required this.name,
    required this.nameAr,
    required this.icon,
    required this.color,
    this.isIncome = false,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'icon': icon.codePoint,
      'color': color.value,
      'is_income': isIncome ? 1 : 0,
      'is_default': isDefault ? 1 : 0,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      nameAr: map['name_ar'],
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
      color: Color(map['color']),
      isIncome: map['is_income'] == 1,
      isDefault: map['is_default'] == 1,
    );
  }

  Category copyWith({
    int? id,
    String? name,
    String? nameAr,
    IconData? icon,
    Color? color,
    bool? isIncome,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isIncome: isIncome ?? this.isIncome,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  // Default Expense Categories
  static List<Category> get defaultExpenseCategories => [
        const Category(
          name: 'Food & Drinks',
          nameAr: 'طعام ومشروبات',
          icon: Icons.restaurant,
          color: Colors.orange,
          isDefault: true,
        ),
        const Category(
          name: 'Shopping',
          nameAr: 'تسوق',
          icon: Icons.shopping_bag,
          color: Colors.pink,
          isDefault: true,
        ),
        const Category(
          name: 'Transportation',
          nameAr: 'مواصلات',
          icon: Icons.directions_car,
          color: Colors.blue,
          isDefault: true,
        ),
        const Category(
          name: 'Entertainment',
          nameAr: 'ترفيه',
          icon: Icons.movie,
          color: Colors.purple,
          isDefault: true,
        ),
        const Category(
          name: 'Bills & Utilities',
          nameAr: 'فواتير',
          icon: Icons.receipt_long,
          color: Colors.red,
          isDefault: true,
        ),
        const Category(
          name: 'Health',
          nameAr: 'صحة',
          icon: Icons.local_hospital,
          color: Colors.green,
          isDefault: true,
        ),
        const Category(
          name: 'Education',
          nameAr: 'تعليم',
          icon: Icons.school,
          color: Colors.indigo,
          isDefault: true,
        ),
        const Category(
          name: 'Other',
          nameAr: 'أخرى',
          icon: Icons.more_horiz,
          color: Colors.grey,
          isDefault: true,
        ),
      ];

  // Default Income Categories
  static List<Category> get defaultIncomeCategories => [
        const Category(
          name: 'Salary',
          nameAr: 'راتب',
          icon: Icons.work,
          color: Colors.green,
          isIncome: true,
          isDefault: true,
        ),
        const Category(
          name: 'Business',
          nameAr: 'أعمال',
          icon: Icons.business,
          color: Colors.teal,
          isIncome: true,
          isDefault: true,
        ),
        const Category(
          name: 'Investment',
          nameAr: 'استثمار',
          icon: Icons.trending_up,
          color: Colors.amber,
          isIncome: true,
          isDefault: true,
        ),
        const Category(
          name: 'Gift',
          nameAr: 'هدية',
          icon: Icons.card_giftcard,
          color: Colors.pink,
          isIncome: true,
          isDefault: true,
        ),
        const Category(
          name: 'Other Income',
          nameAr: 'دخل آخر',
          icon: Icons.attach_money,
          color: Colors.lightGreen,
          isIncome: true,
          isDefault: true,
        ),
      ];
}
