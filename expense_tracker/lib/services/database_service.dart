import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/category.dart';
import '../models/transaction.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expense_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        name_ar TEXT NOT NULL,
        icon INTEGER NOT NULL,
        color INTEGER NOT NULL,
        is_income INTEGER NOT NULL DEFAULT 0,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        note TEXT,
        attachment_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
  }

  Future<void> _insertDefaultCategories(Database db) async {
    // Insert default expense categories
    for (final category in Category.defaultExpenseCategories) {
      await db.insert('categories', category.toMap());
    }

    // Insert default income categories
    for (final category in Category.defaultIncomeCategories) {
      await db.insert('categories', category.toMap());
    }
  }

  // ==================== Categories ====================

  Future<List<Category>> getCategories({bool? isIncome}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;

    if (isIncome != null) {
      maps = await db.query(
        'categories',
        where: 'is_income = ?',
        whereArgs: [isIncome ? 1 : 0],
      );
    } else {
      maps = await db.query('categories');
    }

    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<Category?> getCategoryById(int id) async {
    final db = await database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== Transactions ====================

  Future<List<Transaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    int? categoryId,
    int? limit,
    int? offset,
  }) async {
    final db = await database;

    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (startDate != null) {
      whereClause += ' AND date >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClause += ' AND date <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    if (type != null) {
      whereClause += ' AND type = ?';
      whereArgs.add(type == TransactionType.income ? 'income' : 'expense');
    }

    if (categoryId != null) {
      whereClause += ' AND category_id = ?';
      whereArgs.add(categoryId);
    }

    final maps = await db.query(
      'transactions',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
      limit: limit,
      offset: offset,
    );

    List<Transaction> transactions = [];
    for (final map in maps) {
      final transaction = Transaction.fromMap(map);
      transaction.category = await getCategoryById(transaction.categoryId);
      transactions.add(transaction);
    }

    return transactions;
  }

  Future<Transaction?> getTransactionById(int id) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final transaction = Transaction.fromMap(maps.first);
      transaction.category = await getCategoryById(transaction.categoryId);
      return transaction;
    }
    return null;
  }

  Future<int> insertTransaction(Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== Statistics ====================

  Future<double> getTotalExpenses({DateTime? startDate, DateTime? endDate}) async {
    final db = await database;

    String whereClause = "type = 'expense'";
    List<dynamic> whereArgs = [];

    if (startDate != null) {
      whereClause += ' AND date >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClause += ' AND date <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE $whereClause',
      whereArgs,
    );

    return result.first['total'] as double? ?? 0.0;
  }

  Future<double> getTotalIncome({DateTime? startDate, DateTime? endDate}) async {
    final db = await database;

    String whereClause = "type = 'income'";
    List<dynamic> whereArgs = [];

    if (startDate != null) {
      whereClause += ' AND date >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClause += ' AND date <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE $whereClause',
      whereArgs,
    );

    return result.first['total'] as double? ?? 0.0;
  }

  Future<Map<int, double>> getExpensesByCategory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;

    String whereClause = "type = 'expense'";
    List<dynamic> whereArgs = [];

    if (startDate != null) {
      whereClause += ' AND date >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClause += ' AND date <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final result = await db.rawQuery(
      '''
      SELECT category_id, SUM(amount) as total
      FROM transactions
      WHERE $whereClause
      GROUP BY category_id
      ''',
      whereArgs,
    );

    Map<int, double> expensesByCategory = {};
    for (final row in result) {
      expensesByCategory[row['category_id'] as int] =
          row['total'] as double? ?? 0.0;
    }

    return expensesByCategory;
  }

  Future<List<Map<String, dynamic>>> getDailyTotals({
    required DateTime startDate,
    required DateTime endDate,
    TransactionType? type,
  }) async {
    final db = await database;

    String whereClause = 'date >= ? AND date <= ?';
    List<dynamic> whereArgs = [
      startDate.toIso8601String(),
      endDate.toIso8601String(),
    ];

    if (type != null) {
      whereClause += ' AND type = ?';
      whereArgs.add(type == TransactionType.income ? 'income' : 'expense');
    }

    final result = await db.rawQuery(
      '''
      SELECT DATE(date) as day, SUM(amount) as total, type
      FROM transactions
      WHERE $whereClause
      GROUP BY DATE(date), type
      ORDER BY day
      ''',
      whereArgs,
    );

    return result;
  }

  // ==================== Utility ====================

  Future<void> close() async {
    final db = await database;
    db.close();
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('categories');
    await _insertDefaultCategories(db);
  }
}
