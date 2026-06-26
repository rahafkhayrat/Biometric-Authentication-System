import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
// Conditional import - sqflite only works on mobile
import 'package:sqflite/sqflite.dart'
    if (dart.library.html) 'db_helper_stub.dart';

class DBHelper {
  static Database? _db;
  static bool _initialized = false;

  // Initialize database (only on mobile, sqflite doesn't work on web)
  static Future<void> init() async {
    if (kIsWeb) {
      // sqflite doesn't work on web - skip initialization
      return;
    }

    if (_initialized) return;

    try {
      _db = await initDatabase();
      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Database initialization error: $e');
      }
      rethrow;
    }
  }

  static Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('Local database not supported on web platform');
    }

    if (_db != null) return _db!;
    await init();
    return _db!;
  }

  static Future<Database> initDatabase() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'face_users.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL UNIQUE,
            uid TEXT,
            embedding TEXT NOT NULL,
            created_at INTEGER DEFAULT (strftime('%s', 'now'))
          )
        ''');

        // Create index for faster email lookups
        await db.execute('CREATE INDEX idx_email ON users(email)');
      },
    );
  }

  // Insert user with embedding (local cache)
  static Future<int> insertUser(
    String email,
    List<double> embedding, {
    String? uid,
  }) async {
    if (kIsWeb) {
      // On web, just return success (no local storage)
      return 1;
    }

    try {
      final db = await database;

      return await db.insert('users', {
        'email': email,
        'uid': uid,
        'embedding': jsonEncode(embedding),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      if (kDebugMode) {
        print('Database insert error: $e');
      }
      return 0;
    }
  }

  // Get user embedding by email (from local cache)
  static Future<List<double>?> getUserEmbedding(String email) async {
    if (kIsWeb) {
      return null; // No local database on web
    }

    try {
      final db = await database;

      final result = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
      );

      if (result.isEmpty) return null;

      final jsonStr = result.first['embedding'] as String;
      final List<dynamic> decoded = jsonDecode(jsonStr);

      // Convert to List<double>
      return decoded.map((e) => (e as num).toDouble()).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Database query error: $e');
      }
      return null;
    }
  }

  // Get user embedding by UID
  static Future<List<double>?> getUserEmbeddingByUid(String uid) async {
    if (kIsWeb) {
      return null;
    }

    try {
      final db = await database;

      final result = await db.query(
        'users',
        where: 'uid = ?',
        whereArgs: [uid],
        limit: 1,
      );

      if (result.isEmpty) return null;

      final jsonStr = result.first['embedding'] as String;
      final List<dynamic> decoded = jsonDecode(jsonStr);
      

      return decoded.map((e) => (e as num).toDouble()).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Database query error: $e');
      }
      return null;
    }
  }

  // Get all users
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    if (kIsWeb) {
      return [];
    }

    try {
      final db = await database;
      return await db.query('users', orderBy: 'created_at DESC');
    } catch (e) {
      if (kDebugMode) {
        print('Database query error: $e');
      }
      return [];
    }
  }

  // Delete user by email
  static Future<int> deleteUser(String email) async {
    if (kIsWeb) {
      return 0;
    }

    try {
      final db = await database;
      return await db.delete('users', where: 'email = ?', whereArgs: [email]);
    } catch (e) {
      if (kDebugMode) {
        print('Database delete error: $e');
      }
      return 0;
    }
  }

  // Clear all users
  static Future<void> clearAll() async {
    if (kIsWeb) {
      return;
    }

    try {
      final db = await database;
      await db.delete('users');
    } catch (e) {
      if (kDebugMode) {
        print('Database clear error: $e');
      }
    }
  }
}
