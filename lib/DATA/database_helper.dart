import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smart_pantry.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE activity_logs (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              action TEXT NOT NULL,
              details TEXT NOT NULL,
              timestamp TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        expiryDate TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE activity_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action TEXT NOT NULL,
        details TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  // Ingredient Operations
  Future<int> insertIngredient(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = await db.insert('ingredients', row);
    await logActivity('ADDED', 'Added item: ${row['name']} (${row['quantity']} ${row['unit']})');
    return id;
  }

  Future<List<Map<String, dynamic>>> fetchAllIngredients() async {
    final db = await instance.database;
    return await db.query('ingredients');
  }

  Future<int> updateIngredient(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'];
    final result = await db.update('ingredients', row, where: 'id = ?', whereArgs: [id]);
    await logActivity('EDITED', 'Updated item: ${row['name']}');
    return result;
  }

  Future<int> deleteIngredient(int id) async {
    final db = await instance.database;
    final result = await db.delete('ingredients', where: 'id = ?', whereArgs: [id]);
    await logActivity('DELETED', 'Removed item ID: $id');
    return result;
  }

  // Audit Logging
  Future<void> logActivity(String action, String details) async {
    try {
      final db = await instance.database;
      await db.insert('activity_logs', {
        'action': action,
        'details': details,
        'timestamp': DateTime.now().toIso8601String().split('.').first,
      });
    } catch (e) {
      // Ignored for web fallback state
    }
  }

  Future<List<Map<String, dynamic>>> fetchActivityLogs() async {
    try {
      final db = await instance.database;
      return await db.query('activity_logs', orderBy: 'id DESC');
    } catch (e) {
      return [];
    }
  }
}
