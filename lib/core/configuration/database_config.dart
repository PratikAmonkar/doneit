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
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
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
        title TEXT,
        created TEXT,
        updated TEXT,
        FOREIGN KEY(task_id) REFERENCES tasks(id) ON DELETE CASCADE
      );
    """);
  }

  static Future<Database> get database async => await initializeDb();
}
