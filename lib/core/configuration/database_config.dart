/*
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseConfig {
  static final DatabaseConfig _instance = DatabaseConfig._internal();
  static Database? _database;

  DatabaseConfig._internal();

  factory DatabaseConfig() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'tasks.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE tasks (
      id TEXT PRIMARY KEY,
      title TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE todos (
      id TEXT PRIMARY KEY,
      task_id TEXT,
      description TEXT,
      is_done INTEGER,
      FOREIGN KEY(task_id) REFERENCES tasks(id) ON DELETE CASCADE
    )
  ''');
  }
}
*/

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseConfig {
  static const String databaseName = "tasks.db";
  static Database? _db;

  static Future<Database> initializeDb() async {
    if (_db != null) return _db!;

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, databaseName);

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await _createTables(db);
      },
    );

    return _db!;
  }

  static Future<void> _createTables(Database db) async {
    await db.execute("""
      CREATE TABLE IF NOT EXISTS tasks (
        id TEXT PRIMARY KEY,
        title TEXT,
        priority TEXT,
        created TEXT,
        updated TEXT
      );
    """);

    await db.execute("""
      CREATE TABLE IF NOT EXISTS todos (
        id TEXT PRIMARY KEY,
        task_id TEXT,
        is_done INTEGER,
        FOREIGN KEY(task_id) REFERENCES tasks(id) ON DELETE CASCADE,
        created TEXT,
        updated TEXT
      );
    """);
  }

  static Future<Database> get database async => await initializeDb();
}
