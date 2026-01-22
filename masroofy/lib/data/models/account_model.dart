import 'package:flutter/material.dart';

class AccountModel {
  final String id;
  final String name;
  final String nameEn;
  final String icon;
  final Color color;
  final double balance;
  final bool isDefault;

  AccountModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.icon,
    required this.color,
    this.balance = 0.0,
    this.isDefault = false,
  });

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'] as String,
      name: map['name'] as String,
      nameEn: map['nameEn'] as String,
      icon: map['icon'] as String,
      color: Color(map['color'] as int),
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      isDefault: map['isDefault'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'icon': icon,
      'color': color.value,
      'balance': balance,
      'isDefault': isDefault ? 1 : 0,
    };
  }

  AccountModel copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? icon,
    Color? color,
    double? balance,
    bool? isDefault,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      balance: balance ?? this.balance,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
