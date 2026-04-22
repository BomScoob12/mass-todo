import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masstodo/models/task_model.dart';
import 'package:masstodo/providers/database_providers.dart';
import 'package:masstodo/providers/tasks_filter_provider.dart';

final taskListProvider =
    AsyncNotifierProvider<TaskListNotifier, List<TaskItem>>(() {
      return TaskListNotifier();
    });

class TaskListNotifier extends AsyncNotifier<List<TaskItem>> {
  @override
  FutureOr<List<TaskItem>> build() async {
    final showCompleted = ref.watch(showCompletedTasksProvider);
    return _fetchTasks(showCompleted);
  }

  Future<List<TaskItem>> _fetchTasks(bool includeCompleted) async {
    return await ref
        .read(taskRepositoryProvider)
        .getAllTasks(includeCompleted: includeCompleted);
  }

  Future<void> addTask(TaskItem task) async {
    state = AsyncLoading<List<TaskItem>>().copyWithPrevious(state);
    try {
      await ref.read(taskRepositoryProvider).createTask(task);
      final showCompleted = ref.read(showCompletedTasksProvider);
      state = AsyncValue.data(await _fetchTasks(showCompleted));
      ref.invalidate(tasksStatsProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateTask(TaskItem task) async {
    state = AsyncLoading<List<TaskItem>>().copyWithPrevious(state);
    try {
      await ref.read(taskRepositoryProvider).updateTask(task);
      final showCompleted = ref.read(showCompletedTasksProvider);
      state = AsyncValue.data(await _fetchTasks(showCompleted));
      ref.invalidate(tasksStatsProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleTaskCompletion(String id) async {
    // We don't return early if state is loading, as long as it has a value
    if (!state.hasValue) return;
    
    try {
      final task = state.value!.firstWhere((t) => t.id == id);
      final newCompletionStatus = !task.isCompleted;
      
      // Atomic update in DB
      await ref.read(taskRepositoryProvider).updateTaskCompletion(id, newCompletionStatus);
      
      // Refresh state
      final showCompleted = ref.read(showCompletedTasksProvider);
      state = AsyncValue.data(await _fetchTasks(showCompleted));
      ref.invalidate(tasksStatsProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteTask(String id) async {
    state = AsyncLoading<List<TaskItem>>().copyWithPrevious(state);
    try {
      await ref.read(taskRepositoryProvider).deleteTask(id);
      final showCompleted = ref.read(showCompletedTasksProvider);
      state = AsyncValue.data(await _fetchTasks(showCompleted));
      ref.invalidate(tasksStatsProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteTasksByCategoryId(String categoryId) async {
    state = AsyncLoading<List<TaskItem>>().copyWithPrevious(state);
    try {
      await ref
          .read(taskRepositoryProvider)
          .deleteTasksByCategoryId(categoryId);
      final showCompleted = ref.read(showCompletedTasksProvider);
      state = AsyncValue.data(await _fetchTasks(showCompleted));
      ref.invalidate(tasksStatsProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final tasksStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await ref.read(taskRepositoryProvider).getDashboardStats();
});
