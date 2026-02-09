import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

/// Database service for Eltizami habit tracker
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'eltizami.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Habits table
    await db.execute('''
      CREATE TABLE habits(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        icon INTEGER NOT NULL,
        color INTEGER NOT NULL,
        frequency INTEGER NOT NULL,
        weekDays TEXT,
        targetPerDay INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL,
        isArchived INTEGER DEFAULT 0,
        reminderHour INTEGER DEFAULT 9,
        reminderMinute INTEGER DEFAULT 0,
        reminderEnabled INTEGER DEFAULT 0
      )
    ''');

    // Habit completions table with notes
    await db.execute('''
      CREATE TABLE habit_completions(
        id TEXT PRIMARY KEY,
        habitId TEXT NOT NULL,
        date TEXT NOT NULL,
        count INTEGER DEFAULT 1,
        notes TEXT,
        completedAt TEXT NOT NULL,
        FOREIGN KEY (habitId) REFERENCES habits(id) ON DELETE CASCADE
      )
    ''');

    // Create index for faster queries
    await db.execute('''
      CREATE INDEX idx_completions_date ON habit_completions(date)
    ''');
    await db.execute('''
      CREATE INDEX idx_completions_habit ON habit_completions(habitId)
    ''');
  }

  // ==================== Habit CRUD ====================

  /// Insert a new habit
  Future<void> insertHabit(Habit habit) async {
    final db = await database;
    await db.insert(
      'habits',
      habit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all habits (non-archived)
  Future<List<Habit>> getHabits() async {
    final db = await database;
    final maps = await db.query(
      'habits',
      where: 'isArchived = ?',
      whereArgs: [0],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Habit.fromMap(map)).toList();
  }

  /// Get all habits including archived
  Future<List<Habit>> getAllHabits() async {
    final db = await database;
    final maps = await db.query('habits', orderBy: 'createdAt DESC');
    return maps.map((map) => Habit.fromMap(map)).toList();
  }

  /// Get a single habit by ID
  Future<Habit?> getHabit(String id) async {
    final db = await database;
    final maps = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Habit.fromMap(maps.first);
  }

  /// Update a habit
  Future<void> updateHabit(Habit habit) async {
    final db = await database;
    await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  /// Delete a habit
  Future<void> deleteHabit(String id) async {
    final db = await database;
    await db.delete(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
    // Also delete all completions for this habit
    await db.delete(
      'habit_completions',
      where: 'habitId = ?',
      whereArgs: [id],
    );
  }

  /// Archive a habit
  Future<void> archiveHabit(String id) async {
    final db = await database;
    await db.update(
      'habits',
      {'isArchived': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== Completion CRUD ====================

  /// Add a completion with optional notes
  Future<void> addCompletion(HabitCompletion completion) async {
    final db = await database;
    await db.insert(
      'habit_completions',
      completion.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get completions for a specific date
  Future<List<HabitCompletion>> getCompletionsForDate(DateTime date) async {
    final db = await database;
    final dateStr = _dateOnly(date).toIso8601String();
    final maps = await db.query(
      'habit_completions',
      where: 'date = ?',
      whereArgs: [dateStr],
    );
    return maps.map((map) => HabitCompletion.fromMap(map)).toList();
  }

  /// Get all completions for a habit
  Future<List<HabitCompletion>> getCompletionsForHabit(String habitId) async {
    final db = await database;
    final maps = await db.query(
      'habit_completions',
      where: 'habitId = ?',
      whereArgs: [habitId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => HabitCompletion.fromMap(map)).toList();
  }

  /// Get completion for specific habit and date
  Future<HabitCompletion?> getCompletion(
      String habitId, DateTime date) async {
    final db = await database;
    final dateStr = _dateOnly(date).toIso8601String();
    final maps = await db.query(
      'habit_completions',
      where: 'habitId = ? AND date = ?',
      whereArgs: [habitId, dateStr],
    );
    if (maps.isEmpty) return null;
    return HabitCompletion.fromMap(maps.first);
  }

  /// Update completion notes
  Future<void> updateCompletionNotes(String id, String? notes) async {
    final db = await database;
    await db.update(
      'habit_completions',
      {'notes': notes},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete a completion
  Future<void> deleteCompletion(String id) async {
    final db = await database;
    await db.delete(
      'habit_completions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get completions in date range
  Future<List<HabitCompletion>> getCompletionsInRange(
      DateTime start, DateTime end) async {
    final db = await database;
    final startStr = _dateOnly(start).toIso8601String();
    final endStr = _dateOnly(end).toIso8601String();
    final maps = await db.query(
      'habit_completions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startStr, endStr],
      orderBy: 'date DESC',
    );
    return maps.map((map) => HabitCompletion.fromMap(map)).toList();
  }

  // ==================== Statistics ====================

  /// Get streak for a habit
  Future<int> getStreak(String habitId) async {
    final completions = await getCompletionsForHabit(habitId);
    if (completions.isEmpty) return 0;

    // Sort by date descending
    completions.sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime checkDate = _dateOnly(DateTime.now());

    for (final completion in completions) {
      final completionDate = _dateOnly(completion.date);
      if (completionDate == checkDate ||
          completionDate == checkDate.subtract(const Duration(days: 1))) {
        streak++;
        checkDate = completionDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  /// Get total completions for a habit
  Future<int> getTotalCompletions(String habitId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(count) as total FROM habit_completions WHERE habitId = ?',
      [habitId],
    );
    return (result.first['total'] as int?) ?? 0;
  }

  /// Get completion rate for last N days
  Future<double> getCompletionRate(String habitId, int days) async {
    final habit = await getHabit(habitId);
    if (habit == null) return 0.0;

    final end = _dateOnly(DateTime.now());
    final start = end.subtract(Duration(days: days - 1));

    int expectedDays = 0;
    int completedDays = 0;

    for (int i = 0; i < days; i++) {
      final date = start.add(Duration(days: i));
      if (habit.shouldDoOnDay(date)) {
        expectedDays++;
        final completion = await getCompletion(habitId, date);
        if (completion != null && completion.count >= habit.targetPerDay) {
          completedDays++;
        }
      }
    }

    if (expectedDays == 0) return 0.0;
    return completedDays / expectedDays;
  }

  /// Get dates with completions for a habit (for calendar marking)
  Future<Set<DateTime>> getCompletedDates(String habitId) async {
    final completions = await getCompletionsForHabit(habitId);
    return completions.map((c) => _dateOnly(c.date)).toSet();
  }

  // ==================== Helpers ====================

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
