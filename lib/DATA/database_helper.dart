// lib/DATA/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sous_chef_pantry.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onConfigure: (db) async {
        await db.execute('PRAGMA journal_mode = WAL');
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
        expiry_date TEXT NOT NULL,
        risk_level INTEGER NOT NULL DEFAULT 0,
        location TEXT NOT NULL DEFAULT 'Fridge'
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

  Future<int> insertIngredient(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = await db.insert('ingredients', row);
    await logActivity('ADDED', 'Added: ${row['name']} to ${row['location']}');
    return id;
  }

  Future<List<Map<String, dynamic>>> fetchAllIngredients() async {
    final db = await instance.database;
    return await db.query('ingredients', orderBy: 'expiry_date ASC');
  }

  Future<int> updateIngredient(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'];
    return await db.update('ingredients', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteIngredient(int id) async {
    final db = await instance.database;
    return await db.delete('ingredients', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> logActivity(String action, String details) async {
    try {
      final db = await instance.database;
      await db.insert('activity_logs', {
        'action': action,
        'details': details,
        'timestamp': DateTime.now().toIso8601String().split('.').first,
      });
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> fetchActivityLogs() async {
    try {
      final db = await instance.database;
      return await db.query('activity_logs', orderBy: 'id DESC');
    } catch (_) {
      return [];
    }
  }
}
