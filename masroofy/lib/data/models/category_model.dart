import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String nameEn;
  final String icon;
  final Color color;
  final bool isIncome;
  final bool isCustom;

  CategoryModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.icon,
    required this.color,
    this.isIncome = false,
    this.isCustom = false,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      nameEn: map['nameEn'] as String,
      icon: map['icon'] as String,
      color: Color(map['color'] as int),
      isIncome: map['isIncome'] == 1,
      isCustom: map['isCustom'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'icon': icon,
      'color': color.value,
      'isIncome': isIncome ? 1 : 0,
      'isCustom': isCustom ? 1 : 0,
    };
  }
}
