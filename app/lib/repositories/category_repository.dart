import 'package:masstodo/models/task_model.dart';
import 'package:masstodo/database/database_helper.dart';

class CategoryRepository {
  final DatabaseHelper dbHelper;

  CategoryRepository(this.dbHelper);

  Future<TaskCategory> createCategory(TaskCategory category) async {
    final db = await dbHelper.database;
    await db.insert('categories', category.toMap());
    return category;
  }

  Future<List<TaskCategory>> getAllCategories() async {
    final db = await dbHelper.database;
    final result = await db.query('categories');
    return result.map((json) => TaskCategory.fromMap(json)).toList();
  }

  Future<int> updateCategory(TaskCategory category) async {
    final db = await dbHelper.database;
    return db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(String id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
