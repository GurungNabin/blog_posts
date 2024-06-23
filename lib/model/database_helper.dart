import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Future<Database> initializeDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'favorites_database.db'),
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE favorites(id INTEGER PRIMARY KEY, title TEXT, body TEXT)',
        );
      },
      version: 1,
    );
  }
}
