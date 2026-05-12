import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // In-memory fallback for Web
  final List<Map<String, dynamic>> _webMemoryDb = [];

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    debugPrint('Initializing database...');
    String path;
    try {
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.linux ||
              defaultTargetPlatform == TargetPlatform.macOS)) {
        final dbFolder = await getApplicationDocumentsDirectory();
        debugPrint('DB Folder path: ${dbFolder.path}');
        if (!await dbFolder.exists()) {
          debugPrint('Creating DB folder...');
          await dbFolder.create(recursive: true);
        }
        path = join(dbFolder.path, 'maizeguard.db');
      } else {
        path = join(await getDatabasesPath(), 'maizeguard.db');
      }
      debugPrint('Opening database at: $path');
      final db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) {
          debugPrint('Creating scans table...');
          return db.execute(
            'CREATE TABLE scans(id INTEGER PRIMARY KEY AUTOINCREMENT, disease TEXT, confidence REAL, health_index INTEGER, image_path TEXT, timestamp TEXT, symptoms TEXT, recommendations TEXT)',
          );
        },
      );
      debugPrint('Database initialized successfully.');
      return db;
    } catch (e) {
      debugPrint('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> insertScan(Map<String, dynamic> scan) async {
    if (kIsWeb) {
      _webMemoryDb.add(Map.from(scan));
      return;
    }
    final db = await database;
    if (db != null) {
      await db.insert('scans', scan,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<Map<String, dynamic>>> getScans() async {
    if (kIsWeb) {
      return List.from(_webMemoryDb.reversed);
    }
    final db = await database;
    if (db == null) return [];
    return await db.query('scans', orderBy: 'timestamp DESC');
  }
}
