import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // 1. Pantry Inventory Table
    await db.execute('''
      CREATE TABLE pantry_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        purchase_date TEXT NOT NULL,
        expiry_date TEXT NOT NULL,
        is_opened INTEGER DEFAULT 0,
        category TEXT DEFAULT 'Other'
      )
    ''');

    // 2. Saved Recipes Table (Caching Gemini output to save API limits)
    await db.execute('''
      CREATE TABLE saved_recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        ingredients_used TEXT NOT NULL,
        instructions TEXT NOT NULL,
        generated_date TEXT NOT NULL
      )
    ''');
  }

  // --- CRUD OPERATIONS FOR PANTRY ITEMS ---

  Future<int> insertIngredient(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('pantry_items', row);
  }

  Future<List<Map<String, dynamic>>> fetchAllIngredients() async {
    final db = await instance.database;
    return await db.query('pantry_items', orderBy: 'expiry_date ASC');
  }

  // ACADEMIC VALUE ADD: Native SQL evaluation query for expiring items
  Future<List<Map<String, dynamic>>> fetchExpiringSoon() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT *, (julianday(expiry_date) - julianday('date(\'now\')')) AS days_remaining 
      FROM pantry_items 
      WHERE (julianday(expiry_date) - julianday('date(\'now\')')) <= 3 
      AND (julianday(expiry_date) - julianday('date(\'now\')')) >= 0
      ORDER BY expiry_date ASC
    ''');
  }

  Future<int> updateIngredient(Map<String, dynamic> row) async {
    final db = await instance.database;
    int id = row['id'];
    return await db.update('pantry_items', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteIngredient(int id) async {
    final db = await instance.database;
    return await db.delete('pantry_items', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await _database;
    if (db != null) await db.close();
  }
}

