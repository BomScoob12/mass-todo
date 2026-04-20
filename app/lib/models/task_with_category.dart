import 'package:app/models/task_model.dart';

class TaskWithCategory {
  final TaskItem task;
  final TaskCategory? category;

  TaskWithCategory({
    required this.task,
    this.category,
  });
}
