import 'package:app/models/task_model.dart';
import 'package:app/database/database_helper.dart';

class TaskRepository {
  final DatabaseHelper dbHelper;

  TaskRepository(this.dbHelper);

  Future<TaskItem> createTask(TaskItem task) async {
    final db = await dbHelper.database;
    await db.insert('tasks', task.toMap());
    return task;
  }

  Future<List<TaskItem>> getAllTasks() async {
    final db = await dbHelper.database;
    final result = await db.query('tasks', orderBy: 'createdAt DESC');
    return result.map((json) => TaskItem.fromMap(json)).toList();
  }

  Future<TaskItem?> getTaskById(String id) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return TaskItem.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateTask(TaskItem task) async {
    final db = await dbHelper.database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(String id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
