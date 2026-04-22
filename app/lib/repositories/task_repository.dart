import 'package:masstodo/models/task_model.dart';
import 'package:masstodo/database/database_helper.dart';

class TaskRepository {
  final DatabaseHelper dbHelper;

  TaskRepository(this.dbHelper);

  Future<TaskItem> createTask(TaskItem task) async {
    final db = await dbHelper.database;
    await db.insert('tasks', task.toMap());
    return task;
  }

  Future<List<TaskItem>> getAllTasks({bool includeCompleted = false}) async {
    final db = await dbHelper.database;
    final where = includeCompleted ? null : 'isCompleted = 0';
    final result = await db.query('tasks', where: where, orderBy: 'createdAt DESC');
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

  Future<int> updateTaskCompletion(String id, bool isCompleted) async {
    final db = await dbHelper.database;
    return db.update(
      'tasks',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
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

  Future<int> deleteTasksByCategoryId(String categoryId) async {
    final db = await dbHelper.database;
    return await db.delete(
      'tasks',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final db = await dbHelper.database;
    
    final totalResult = await db.rawQuery('SELECT COUNT(*) FROM tasks');
    int total = totalResult.first.values.first as int? ?? 0;
    
    final completedResult = await db.rawQuery('SELECT COUNT(*) FROM tasks WHERE isCompleted = 1');
    int completed = completedResult.first.values.first as int? ?? 0;
    
    int pending = total - completed;
    double completionRate = total > 0 ? completed / total : 0.0;
    
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59).millisecondsSinceEpoch;
    
    final todayCountResult = await db.rawQuery('SELECT COUNT(*) FROM tasks WHERE deadline >= ? AND deadline <= ?', [todayStart, todayEnd]);
    int todayCount = todayCountResult.first.values.first as int? ?? 0;
    
    final int currentWeekday = now.weekday; 
    final DateTime startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: currentWeekday - 1));
    final DateTime endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    
    final startOfWeekMs = startOfWeek.millisecondsSinceEpoch;
    final endOfWeekMs = endOfWeek.millisecondsSinceEpoch;
    
    final weeklyTotalResult = await db.rawQuery('SELECT COUNT(*) FROM tasks WHERE deadline >= ? AND deadline <= ?', [startOfWeekMs, endOfWeekMs]);
    int weeklyTotal = weeklyTotalResult.first.values.first as int? ?? 0;
    
    final weeklyCompletedResult = await db.rawQuery('SELECT COUNT(*) FROM tasks WHERE isCompleted = 1 AND deadline >= ? AND deadline <= ?', [startOfWeekMs, endOfWeekMs]);
    int weeklyCompleted = weeklyCompletedResult.first.values.first as int? ?? 0;
    
    double weeklyProgress = weeklyTotal > 0 ? weeklyCompleted / weeklyTotal : 0.0;
    
    final nextUpResult = await db.query(
      'tasks',
      where: 'isCompleted = 0 AND deadline >= ? AND deadline <= ?',
      whereArgs: [todayStart, todayEnd],
      orderBy: 'deadline ASC',
      limit: 1,
    );
    
    TaskItem? nextPriority = nextUpResult.isNotEmpty ? TaskItem.fromMap(nextUpResult.first) : null;
    
    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'completionRate': completionRate,
      'nextUp': nextPriority,
      'today': todayCount,
      'weeklyProgress': weeklyProgress,
    };
  }
}
