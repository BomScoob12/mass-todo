import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textNullableType = 'TEXT';
    const integerType = 'INTEGER NOT NULL';
    const integerNullableType = 'INTEGER';

    await db.execute('''
CREATE TABLE categories (
  id $idType,
  name $textType,
  colorHex $textType
)
''');

    await db.execute('''
CREATE TABLE tasks (
  id $idType,
  name $textType,
  description $textNullableType,
  categoryId $textType,
  deadline $integerNullableType,
  priority $textType,
  isCompleted $integerType,
  createdAt $integerType,
  FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE NO ACTION
)
''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
