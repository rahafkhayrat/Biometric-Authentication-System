// Stub file for web platform - sqflite doesn't work on web
// This prevents compilation errors when building for web

// Stub types to prevent compilation errors
class Database {
  Database._();
  Future<int> insert(String table, Map<String, dynamic> values, {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) async => 0;
  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<dynamic>? whereArgs, int? limit, String? orderBy}) async => [];
  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs}) async => 0;
  Future<void> execute(String sql, [List<dynamic>? arguments]) async {}
}

class ConflictAlgorithm {
  static final replace = ConflictAlgorithm._();
  ConflictAlgorithm._();
}

Future<String> getDatabasesPath() async => '';
Future<Database> openDatabase(String path, {int? version, Function? onCreate}) async => Database._();
