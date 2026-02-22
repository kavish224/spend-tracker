import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static const String _dbName = 'expenses.db';
  static const int _dbVersion = 1;
  static Database? _database;

  static Future<Database> initDB() async {
    if (_database != null) return _database!;

    final path = join(await getDatabasesPath(), _dbName);
    _database = await openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL NOT NULL DEFAULT 0,
            category TEXT NOT NULL DEFAULT 'Other',
            paymentMethod TEXT NOT NULL DEFAULT 'Unknown',
            date TEXT NOT NULL,
            note TEXT
          )
        ''');
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(date)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Add migrations here when bumping _dbVersion.
        // Example: if (oldVersion < 2) { await db.execute('ALTER TABLE ...'); }
      },
    );
    return _database!;
  }

  static Future<int> update(int id, Map<String, dynamic> map) async {
    final db = await initDB();
    return db.update(
      'expenses',
      map,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> delete(int id) async {
    final db = await initDB();
    return db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> closeDB() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
