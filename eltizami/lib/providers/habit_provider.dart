import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/database_service.dart';

/// Provider for managing habits state
class HabitProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final Uuid _uuid = const Uuid();

  List<Habit> _habits = [];
  Map<String, List<HabitCompletion>> _completionsByDate = {};
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // Getters
  List<Habit> get habits => _habits;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  /// Get habits that should be done today
  List<Habit> get todayHabits {
    return _habits.where((h) => h.shouldDoOnDay(_selectedDate)).toList();
  }

  /// Initialize provider and load data
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await loadHabits();
    await loadCompletionsForDate(_selectedDate);

    _isLoading = false;
    notifyListeners();
  }

  /// Load all habits from database
  Future<void> loadHabits() async {
    _habits = await _db.getHabits();
    notifyListeners();
  }

  /// Load completions for a specific date
  Future<void> loadCompletionsForDate(DateTime date) async {
    final dateKey = _dateKey(date);
    final completions = await _db.getCompletionsForDate(date);
    _completionsByDate[dateKey] = completions;
    notifyListeners();
  }

  /// Set selected date (for calendar)
  Future<void> setSelectedDate(DateTime date) async {
    _selectedDate = date;
    await loadCompletionsForDate(date);
    notifyListeners();
  }

  /// Add a new habit
  Future<void> addHabit({
    required String name,
    String? description,
    required IconData icon,
    required Color color,
    HabitFrequency frequency = HabitFrequency.daily,
    List<int>? weekDays,
    int targetPerDay = 1,
    bool reminderEnabled = false,
    int reminderHour = 9,
    int reminderMinute = 0,
  }) async {
    final habit = Habit(
      id: _uuid.v4(),
      name: name,
      description: description,
      icon: icon,
      color: color,
      frequency: frequency,
      weekDays: weekDays,
      targetPerDay: targetPerDay,
      reminderEnabled: reminderEnabled,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
    );

    await _db.insertHabit(habit);
    await loadHabits();
  }

  /// Update an existing habit
  Future<void> updateHabit(Habit habit) async {
    await _db.updateHabit(habit);
    await loadHabits();
  }

  /// Delete a habit
  Future<void> deleteHabit(String habitId) async {
    await _db.deleteHabit(habitId);
    await loadHabits();
  }

  /// Archive a habit
  Future<void> archiveHabit(String habitId) async {
    await _db.archiveHabit(habitId);
    await loadHabits();
  }

  /// Toggle habit completion for selected date
  Future<void> toggleHabitCompletion(
    String habitId, {
    String? notes,
  }) async {
    final existing = await _db.getCompletion(habitId, _selectedDate);

    if (existing != null) {
      // Already completed - remove completion
      await _db.deleteCompletion(existing.id);
    } else {
      // Not completed - add completion
      final completion = HabitCompletion(
        id: _uuid.v4(),
        habitId: habitId,
        date: _selectedDate,
        notes: notes,
      );
      await _db.addCompletion(completion);
    }

    await loadCompletionsForDate(_selectedDate);
  }

  /// Complete habit with notes
  Future<void> completeHabitWithNotes(
    String habitId, {
    required String? notes,
  }) async {
    final existing = await _db.getCompletion(habitId, _selectedDate);

    if (existing != null) {
      // Update notes
      await _db.updateCompletionNotes(existing.id, notes);
    } else {
      // Create new completion
      final completion = HabitCompletion(
        id: _uuid.v4(),
        habitId: habitId,
        date: _selectedDate,
        notes: notes,
      );
      await _db.addCompletion(completion);
    }

    await loadCompletionsForDate(_selectedDate);
  }

  /// Check if habit is completed on selected date
  bool isHabitCompleted(String habitId) {
    final dateKey = _dateKey(_selectedDate);
    final completions = _completionsByDate[dateKey] ?? [];
    return completions.any((c) => c.habitId == habitId);
  }

  /// Get completion for a habit on selected date
  HabitCompletion? getCompletion(String habitId) {
    final dateKey = _dateKey(_selectedDate);
    final completions = _completionsByDate[dateKey] ?? [];
    try {
      return completions.firstWhere((c) => c.habitId == habitId);
    } catch (e) {
      return null;
    }
  }

  /// Get completion notes for a habit
  String? getCompletionNotes(String habitId) {
    return getCompletion(habitId)?.notes;
  }

  /// Get completions count for a date (for calendar markers)
  Future<int> getCompletionsCountForDate(DateTime date) async {
    final completions = await _db.getCompletionsForDate(date);
    return completions.length;
  }

  /// Get dates with completions in a month (for calendar)
  Future<Map<DateTime, int>> getMonthCompletions(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);

    final completions = await _db.getCompletionsInRange(start, end);

    final Map<DateTime, int> result = {};
    for (final completion in completions) {
      final date = DateTime(
        completion.date.year,
        completion.date.month,
        completion.date.day,
      );
      result[date] = (result[date] ?? 0) + 1;
    }
    return result;
  }

  /// Get streak for a habit
  Future<int> getStreak(String habitId) async {
    return await _db.getStreak(habitId);
  }

  /// Get completion rate for a habit
  Future<double> getCompletionRate(String habitId, {int days = 30}) async {
    return await _db.getCompletionRate(habitId, days);
  }

  /// Get today's progress (completed / total)
  double get todayProgress {
    if (todayHabits.isEmpty) return 0.0;
    final completed = todayHabits.where((h) => isHabitCompleted(h.id)).length;
    return completed / todayHabits.length;
  }

  /// Get completed habits count for today
  int get completedTodayCount {
    return todayHabits.where((h) => isHabitCompleted(h.id)).length;
  }

  // Helper to create date key for map
  String _dateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }
}
