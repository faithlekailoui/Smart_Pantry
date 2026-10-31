// lib/DATA/database_helper.dart
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:smart_pantry/DATA/ingredients.dart';

/// Why an item leaves the pantry. This is what makes the waste statistics
/// trustworthy: only FINISHED and DISCARDED count towards the diversion rate.
enum RemoveReason { finished, discarded, mistake }

class ActivityLog {
  final int id;
  final String action;
  final String details;
  final String timestamp;
  const ActivityLog(this.id, this.action, this.details, this.timestamp);
}

/// Impact numbers, always derived from the activity log (never hardcoded).
///   LDR (landfill diversion rate) = finished / (finished + discarded)
class PantryStats {
  final int tracked; // items logged as added
  final int finished; // used up before spoiling
  final int discarded; // thrown away
  final double valueRescued; // KES of finished items
  final double valueWasted; // KES of discarded items

  const PantryStats({
    required this.tracked,
    required this.finished,
    required this.discarded,
    required this.valueRescued,
    required this.valueWasted,
  });

  static const empty = PantryStats(
    tracked: 0, finished: 0, discarded: 0, valueRescued: 0, valueWasted: 0,
  );

  int get resolved => finished + discarded;
  double? get diversionRate => resolved == 0 ? null : finished * 100 / resolved;
  double? get wastePercent => resolved == 0 ? null : discarded * 100 / resolved;
}

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _dbName = 'sous_chef_pantry.db';
  static const int _dbVersion = 4;

  Future<Database>? _dbFuture;

  /// One shared open() future, so concurrent callers never open the file twice.
  Future<Database> get database => _dbFuture ??= _open();

  Future<Database> _open() async {
    try {
      final path = join(await getDatabasesPath(), _dbName);
      return await openDatabase(
        path,
        version: _dbVersion,
        onConfigure: _onConfigure,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      _dbFuture = null; // allow a retry instead of caching the failure
      rethrow;
    }
  }

  Future<void> _onConfigure(Database db) async {
    // Write-Ahead Logging. PRAGMA journal_mode returns a row, so it must go
    // through rawQuery (execute() can throw on some Android versions).
    try {
      final r = await db.rawQuery('PRAGMA journal_mode=WAL');
      debugPrint('SQLite journal_mode -> $r');
    } catch (e) {
      debugPrint('Could not enable WAL: $e');
    }
  }

  // ---------------------------------------------------------------- schema

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        expiry_date TEXT NOT NULL,
        risk_level INTEGER NOT NULL DEFAULT 0,
        location TEXT NOT NULL DEFAULT 'Fridge',
        price REAL NOT NULL DEFAULT 0,
        added_at TEXT NOT NULL DEFAULT ''
      )
    ''');
    await db.execute('''
      CREATE TABLE activity_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action TEXT NOT NULL,
        details TEXT NOT NULL,
        item_name TEXT NOT NULL DEFAULT '',
        value REAL NOT NULL DEFAULT 0,
        timestamp TEXT NOT NULL
      )
    ''');
    await _createSupportObjects(db);
  }

  /// Versioned migration: every schema change from v3 onwards lives here, so
  /// existing installs keep their data when the app is updated.
  Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    if (oldV < 4) {
      for (final sql in const [
        "ALTER TABLE ingredients ADD COLUMN location TEXT NOT NULL DEFAULT 'Fridge'",
        'ALTER TABLE ingredients ADD COLUMN price REAL NOT NULL DEFAULT 0',
        "ALTER TABLE ingredients ADD COLUMN added_at TEXT NOT NULL DEFAULT ''",
        "ALTER TABLE activity_logs ADD COLUMN item_name TEXT NOT NULL DEFAULT ''",
        'ALTER TABLE activity_logs ADD COLUMN value REAL NOT NULL DEFAULT 0',
      ]) {
        try {
          await db.execute(sql);
        } catch (_) {
          // column already exists - safe to ignore
        }
      }
      await _createSupportObjects(db);
    }
  }

  Future<void> _createSupportObjects(Database db) async {
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_ingredients_expiry ON ingredients(expiry_date)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_ingredients_location ON ingredients(location)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_logs_action ON activity_logs(action)');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)');
  }

  /// Keeps the stored risk_level column truthful as days pass. Called on
  /// every app start. (The UI also computes risk live from the expiry date.)
  Future<void> refreshRiskLevels() async {
    final db = await database;
    const days = "(julianday(expiry_date) - julianday(date('now','localtime')))";
    await db.execute('''
      UPDATE ingredients SET risk_level = CASE
        WHEN $days <= ${Ingredient.highRiskDays} THEN 2
        WHEN $days <= ${Ingredient.moderateRiskDays} THEN 1
        ELSE 0 END
    ''');
  }

  // ------------------------------------------------------------ ingredients

  Future<List<Ingredient>> getIngredients() async {
    final db = await database;
    final rows = await db.query('ingredients',
        orderBy: 'expiry_date ASC, name COLLATE NOCASE ASC');
    return rows.map(Ingredient.fromMap).toList();
  }

  /// Adds an item. If the same item (name + unit + expiry + location) already
  /// exists, quantities are merged instead of creating a duplicate row.
  Future<Ingredient> addOrMerge(Ingredient item) async {
    final db = await database;
    return db.transaction<Ingredient>((txn) async {
      final existing = await txn.query(
        'ingredients',
        where:
            'LOWER(name) = ? AND LOWER(unit) = ? AND expiry_date = ? AND location = ?',
        whereArgs: [
          item.name.toLowerCase(),
          item.unit.toLowerCase(),
          item.expiryDate,
          item.location,
        ],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        final cur = Ingredient.fromMap(existing.first);
        final merged = cur.copyWith(
          quantity: cur.quantity + item.quantity,
          price: cur.price + item.price,
        );
        await txn.update('ingredients', merged.toMap(),
            where: 'id = ?', whereArgs: [cur.id]);
        await _log(txn, 'ADDED',
            'Added ${Ingredient.formatQty(item.quantity)} ${item.unit} more ${item.name}',
            itemName: item.name);
        return merged;
      }

      final toInsert = item.copyWith(addedAt: _now());
      final id = await txn.insert('ingredients', toInsert.toMap());
      await _log(txn, 'ADDED',
          'Added ${item.quantityLabel} ${item.name} to ${item.location}',
          itemName: item.name);
      return toInsert.copyWith(id: id);
    });
  }

  Future<void> updateIngredient(Ingredient item) async {
    if (item.id == null) {
      throw StateError('Cannot update an ingredient without an id');
    }
    final db = await database;
    await db.transaction((txn) async {
      await txn.update('ingredients', item.toMap(),
          where: 'id = ?', whereArgs: [item.id]);
      await _log(txn, 'EDITED', 'Edited ${item.name}', itemName: item.name);
    });
  }

  /// Uses part of an item. Using everything counts as FINISHED.
  Future<void> useQuantity(Ingredient item, double amount) async {
    final remaining = item.quantity - amount;
    if (remaining <= 0.0001) {
      await removeIngredient(item, RemoveReason.finished);
      return;
    }
    final updated =
        item.copyWith(quantity: double.parse(remaining.toStringAsFixed(2)));
    final db = await database;
    await db.transaction((txn) async {
      await txn.update('ingredients', updated.toMap(),
          where: 'id = ?', whereArgs: [item.id]);
      await _log(txn, 'USED',
          'Used ${Ingredient.formatQty(amount)} ${item.unit} of ${item.name}',
          itemName: item.name);
    });
  }

  Future<void> removeIngredient(Ingredient item, RemoveReason reason) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('ingredients', where: 'id = ?', whereArgs: [item.id]);
      switch (reason) {
        case RemoveReason.finished:
          await _log(txn, 'FINISHED', 'Used up ${item.name}',
              itemName: item.name, value: item.price);
        case RemoveReason.discarded:
          await _log(txn, 'DISCARDED', 'Threw away ${item.name}',
              itemName: item.name, value: item.price);
        case RemoveReason.mistake:
          await _log(txn, 'REMOVED', 'Removed ${item.name} (entered by mistake)',
              itemName: item.name);
      }
    });
  }

  // ------------------------------------------------------------- statistics

  Future<PantryStats> getStats() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT action, COUNT(*) AS c, COALESCE(SUM(value), 0) AS v
      FROM activity_logs
      WHERE action IN ('ADDED', 'FINISHED', 'DISCARDED')
      GROUP BY action
    ''');
    var tracked = 0, finished = 0, discarded = 0;
    var rescued = 0.0, wasted = 0.0;
    for (final r in rows) {
      final c = (r['c'] as num).toInt();
      final v = (r['v'] as num).toDouble();
      switch (r['action'] as String) {
        case 'ADDED':
          tracked = c;
        case 'FINISHED':
          finished = c;
          rescued = v;
        case 'DISCARDED':
          discarded = c;
          wasted = v;
      }
    }
    return PantryStats(
      tracked: tracked,
      finished: finished,
      discarded: discarded,
      valueRescued: rescued,
      valueWasted: wasted,
    );
  }

  Future<List<ActivityLog>> getActivityLogs({int limit = 200}) async {
    final db = await database;
    final rows =
        await db.query('activity_logs', orderBy: 'id DESC', limit: limit);
    return rows
        .map((r) => ActivityLog(r['id'] as int, r['action'] as String,
            r['details'] as String, r['timestamp'] as String))
        .toList();
  }

  // --------------------------------------------------------------- settings

  Future<String?> getSetting(String key) async {
    final db = await database;
    final rows =
        await db.query('settings', where: 'key = ?', whereArgs: [key], limit: 1);
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteSetting(String key) async {
    final db = await database;
    await db.delete('settings', where: 'key = ?', whereArgs: [key]);
  }

  // ---------------------------------------------------------------- helpers

  String _now() => DateTime.now().toIso8601String().split('.').first;

  Future<void> _log(DatabaseExecutor ex, String action, String details,
      {String itemName = '', double value = 0}) async {
    await ex.insert('activity_logs', {
      'action': action,
      'details': details,
      'item_name': itemName,
      'value': value,
      'timestamp': _now(),
    });
  }
}
