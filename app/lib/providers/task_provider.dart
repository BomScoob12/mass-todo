import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masstodo/models/task_model.dart';
import 'package:masstodo/providers/database_providers.dart';
import 'package:masstodo/providers/tasks_filter_provider.dart';
import 'package:masstodo/utils/notification_service.dart';

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
    state = const AsyncValue.loading();
    try {
      await ref.read(taskRepositoryProvider).createTask(task);
      final showCompleted = ref.read(showCompletedTasksProvider);
      state = AsyncValue.data(await _fetchTasks(showCompleted));
      ref.invalidate(tasksStatsProvider);
      
      if (!task.isCompleted && task.deadline != null) {
        await ref.read(notificationServiceProvider).scheduleTaskNotification(task);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateTask(TaskItem task) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(taskRepositoryProvider).updateTask(task);
      final currentTasks = state.value ?? [];
      state = AsyncValue.data(
        currentTasks.map((t) => t.id == task.id ? task : t).toList(),
      );
      ref.invalidate(tasksStatsProvider);

      if (task.isCompleted || task.deadline == null) {
        await ref.read(notificationServiceProvider).cancelTaskNotification(task.id);
      } else {
        await ref.read(notificationServiceProvider).scheduleTaskNotification(task);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleTaskCompletion(String id) async {
    if (!state.hasValue) return;
    
    try {
      final task = state.value!.firstWhere((t) => t.id == id);
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await ref.read(taskRepositoryProvider).updateTask(updatedTask);
      
      final currentTasks = state.value ?? [];
      state = AsyncValue.data(
        currentTasks.map((t) => t.id == id ? updatedTask : t).toList(),
      );
      ref.invalidate(tasksStatsProvider);

      if (updatedTask.isCompleted) {
        await ref.read(notificationServiceProvider).cancelTaskNotification(updatedTask.id);
      } else if (updatedTask.deadline != null) {
        await ref.read(notificationServiceProvider).scheduleTaskNotification(updatedTask);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteTask(String id) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(taskRepositoryProvider).deleteTask(id);
      final currentTasks = state.value ?? [];
      state = AsyncValue.data(
        currentTasks.where((t) => t.id != id).toList(),
      );
      ref.invalidate(tasksStatsProvider);
      
      await ref.read(notificationServiceProvider).cancelTaskNotification(id);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteTasksByCategoryId(String categoryId) async {
    state = const AsyncValue.loading();
    try {
      final currentTasks = state.value ?? [];
      final tasksToDelete = currentTasks.where((t) => t.categoryId == categoryId).toList();

      await ref
          .read(taskRepositoryProvider)
          .deleteTasksByCategoryId(categoryId);
      final showCompleted = ref.read(showCompletedTasksProvider);
      state = AsyncValue.data(await _fetchTasks(showCompleted));
      ref.invalidate(tasksStatsProvider);

      for (final t in tasksToDelete) {
        await ref.read(notificationServiceProvider).cancelTaskNotification(t.id);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final tasksStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await ref.read(taskRepositoryProvider).getDashboardStats();
});
