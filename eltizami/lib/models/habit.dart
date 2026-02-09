import 'package:flutter/material.dart';

/// Habit frequency types
enum HabitFrequency {
  daily,
  weekly,
  custom,
}

/// Habit model representing a trackable habit
class Habit {
  final String id;
  final String name;
  final String? description;
  final IconData icon;
  final Color color;
  final HabitFrequency frequency;
  final List<int>? weekDays; // For weekly: 1=Mon, 7=Sun
  final int targetPerDay;
  final DateTime createdAt;
  final bool isArchived;
  final int reminderHour;
  final int reminderMinute;
  final bool reminderEnabled;

  Habit({
    required this.id,
    required this.name,
    this.description,
    this.icon = Icons.check_circle_outline,
    this.color = Colors.blue,
    this.frequency = HabitFrequency.daily,
    this.weekDays,
    this.targetPerDay = 1,
    DateTime? createdAt,
    this.isArchived = false,
    this.reminderHour = 9,
    this.reminderMinute = 0,
    this.reminderEnabled = false,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create Habit from database map
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      icon: IconData(map['icon'] as int, fontFamily: 'MaterialIcons'),
      color: Color(map['color'] as int),
      frequency: HabitFrequency.values[map['frequency'] as int],
      weekDays: map['weekDays'] != null
          ? (map['weekDays'] as String)
              .split(',')
              .map((e) => int.parse(e))
              .toList()
          : null,
      targetPerDay: map['targetPerDay'] as int? ?? 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isArchived: (map['isArchived'] as int) == 1,
      reminderHour: map['reminderHour'] as int? ?? 9,
      reminderMinute: map['reminderMinute'] as int? ?? 0,
      reminderEnabled: (map['reminderEnabled'] as int?) == 1,
    );
  }

  /// Convert Habit to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon.codePoint,
      'color': color.value,
      'frequency': frequency.index,
      'weekDays': weekDays?.join(','),
      'targetPerDay': targetPerDay,
      'createdAt': createdAt.toIso8601String(),
      'isArchived': isArchived ? 1 : 0,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
      'reminderEnabled': reminderEnabled ? 1 : 0,
    };
  }

  /// Create a copy with modified fields
  Habit copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    Color? color,
    HabitFrequency? frequency,
    List<int>? weekDays,
    int? targetPerDay,
    DateTime? createdAt,
    bool? isArchived,
    int? reminderHour,
    int? reminderMinute,
    bool? reminderEnabled,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      weekDays: weekDays ?? this.weekDays,
      targetPerDay: targetPerDay ?? this.targetPerDay,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    );
  }

  /// Check if habit should be done on a specific day
  bool shouldDoOnDay(DateTime date) {
    if (isArchived) return false;

    switch (frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekly:
        return weekDays?.contains(date.weekday) ?? false;
      case HabitFrequency.custom:
        return weekDays?.contains(date.weekday) ?? true;
    }
  }

  @override
  String toString() => 'Habit(id: $id, name: $name)';
}
