import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'maizeguard.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE scans(id INTEGER PRIMARY KEY AUTOINCREMENT, disease TEXT, confidence REAL, health_index INTEGER, image_path TEXT, timestamp TEXT, symptoms TEXT, recommendations TEXT)',
        );
      },
    );
  }

  Future<void> insertScan(Map<String, dynamic> scan) async {
    final db = await database;
    await db.insert('scans', scan, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getScans() async {
    final db = await database;
    return await db.query('scans', orderBy: 'timestamp DESC');
  }
}
