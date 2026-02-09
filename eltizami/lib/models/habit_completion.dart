/// Represents a single completion record for a habit
/// Includes optional notes as requested by user
class HabitCompletion {
  final String id;
  final String habitId;
  final DateTime date;
  final int count; // For habits with targetPerDay > 1
  final String? notes; // Optional notes field
  final DateTime completedAt;

  HabitCompletion({
    required this.id,
    required this.habitId,
    required this.date,
    this.count = 1,
    this.notes,
    DateTime? completedAt,
  }) : completedAt = completedAt ?? DateTime.now();

  /// Create from database map
  factory HabitCompletion.fromMap(Map<String, dynamic> map) {
    return HabitCompletion(
      id: map['id'] as String,
      habitId: map['habitId'] as String,
      date: DateTime.parse(map['date'] as String),
      count: map['count'] as int? ?? 1,
      notes: map['notes'] as String?,
      completedAt: DateTime.parse(map['completedAt'] as String),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'date': _dateOnly(date).toIso8601String(),
      'count': count,
      'notes': notes,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  /// Copy with modifications
  HabitCompletion copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    int? count,
    String? notes,
    DateTime? completedAt,
  }) {
    return HabitCompletion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      count: count ?? this.count,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Get date only (without time)
  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  String toString() =>
      'HabitCompletion(habitId: $habitId, date: $date, notes: $notes)';
}
