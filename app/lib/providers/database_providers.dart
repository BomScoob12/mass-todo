import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masstodo/database/database_helper.dart';
import 'package:masstodo/repositories/task_repository.dart';
import 'package:masstodo/repositories/category_repository.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return TaskRepository(dbHelper);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return CategoryRepository(dbHelper);
});
