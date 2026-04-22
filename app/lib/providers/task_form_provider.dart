import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masstodo/models/task_model.dart';

class TaskFormState {
  final String name;
  final String description;
  final DateTime? deadline;
  final String priority;
  final String? categoryId;
  final bool isCreatingCategory;
  final String newCategoryName;

  TaskFormState({
    this.name = '',
    this.description = '',
    this.deadline,
    this.priority = 'Low',
    this.categoryId,
    this.isCreatingCategory = false,
    this.newCategoryName = '',
  });

  TaskFormState copyWith({
    String? name,
    String? description,
    DateTime? deadline,
    String? priority,
    String? categoryId,
    bool? isCreatingCategory,
    String? newCategoryName,
  }) {
    return TaskFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      isCreatingCategory: isCreatingCategory ?? this.isCreatingCategory,
      newCategoryName: newCategoryName ?? this.newCategoryName,
    );
  }

  factory TaskFormState.fromTask(TaskItem task) {
    return TaskFormState(
      name: task.name,
      description: task.description ?? '',
      deadline: task.deadline,
      priority: task.priority,
      categoryId: task.categoryId,
      isCreatingCategory: false,
      newCategoryName: '',
    );
  }
}

class TaskFormNotifier extends Notifier<TaskFormState> {
  @override
  TaskFormState build() => TaskFormState();

  void initWithTask(TaskItem? task) {
    if (task != null) {
      state = TaskFormState.fromTask(task);
    } else {
      state = TaskFormState();
    }
  }

  void updateName(String name) => state = state.copyWith(name: name);
  void updateDescription(String description) =>
      state = state.copyWith(description: description);
  void updateDeadline(DateTime? deadline) =>
      state = state.copyWith(deadline: deadline);
  void updatePriority(String priority) =>
      state = state.copyWith(priority: priority);
  void updateCategory(String? categoryId) => state = state.copyWith(
        categoryId: categoryId,
        isCreatingCategory: false,
      );
  void setCreatingCategory(bool value) =>
      state = state.copyWith(isCreatingCategory: value);
  void updateNewCategoryName(String name) =>
      state = state.copyWith(newCategoryName: name);
}

final taskFormProvider =
    NotifierProvider<TaskFormNotifier, TaskFormState>(
  TaskFormNotifier.new,
);
