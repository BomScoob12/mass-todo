import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/models/task_model.dart';

import 'package:app/providers/database_providers.dart';
import 'package:app/providers/category_provider.dart';

final taskListProvider = AsyncNotifierProvider<TaskListNotifier, List<TaskItem>>(() {
  return TaskListNotifier();
});

class TaskListNotifier extends AsyncNotifier<List<TaskItem>> {
  @override
  FutureOr<List<TaskItem>> build() async {
    return _fetchTasks();
  }

  Future<List<TaskItem>> _fetchTasks() async {
    return await ref.read(taskRepositoryProvider).getAllTasks();
  }

  Future<void> addTask(TaskItem task) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(taskRepositoryProvider).createTask(task);
      state = AsyncValue.data(await _fetchTasks());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateTask(TaskItem task) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(taskRepositoryProvider).updateTask(task);
      state = AsyncValue.data(await _fetchTasks());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleTaskCompletion(String id) async {
    if (state.value == null) return;
    try {
      final task = state.value!.firstWhere((t) => t.id == id);
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await ref.read(taskRepositoryProvider).updateTask(updatedTask);
      state = AsyncValue.data(await _fetchTasks());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteTask(String id) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(taskRepositoryProvider).deleteTask(id);
      state = AsyncValue.data(await _fetchTasks());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final tasksStatsProvider = Provider((ref) {
  final tasksAsync = ref.watch(taskListProvider);
  
  return tasksAsync.when(
    data: (tasks) {
      final total = tasks.length;
      final completed = tasks.where((t) => t.isCompleted).length;
      final pending = total - completed;
      final completionRate = total > 0 ? completed / total : 0.0;
      
      final now = DateTime.now();
      final todayCount = tasks.where((t) {
        if (t.deadline == null) return false;
        return t.deadline!.year == now.year &&
               t.deadline!.month == now.month &&
               t.deadline!.day == now.day;
      }).length;
      
      final int currentWeekday = now.weekday; 
      final DateTime startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: currentWeekday - 1));
      final DateTime endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
      
      int weeklyTotal = 0;
      int weeklyCompleted = 0;
      for (final t in tasks) {
         if (t.deadline != null && t.deadline!.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) && t.deadline!.isBefore(endOfWeek.add(const Duration(seconds: 1)))) {
             weeklyTotal++;
             if (t.isCompleted) weeklyCompleted++;
         }
      }
      final double weeklyProgress = weeklyTotal > 0 ? weeklyCompleted / weeklyTotal : 0.0;
      
      final pendingTodayTasks = tasks.where((t) {
        if (t.isCompleted || t.deadline == null) return false;
        return t.deadline!.year == now.year &&
               t.deadline!.month == now.month &&
               t.deadline!.day == now.day;
      }).toList();
      
      pendingTodayTasks.sort((a, b) {
        return a.deadline!.compareTo(b.deadline!);
      });
      
      final nextPriority = pendingTodayTasks.isNotEmpty ? pendingTodayTasks.first : null;

      return {
        'total': total,
        'completed': completed,
        'pending': pending,
        'completionRate': completionRate,
        'nextUp': nextPriority,
        'today': todayCount,
        'weeklyProgress': weeklyProgress,
      };
    },
    loading: () => {
      'total': 0, 'completed': 0, 'pending': 0, 'completionRate': 0.0, 'nextUp': null, 'today': 0, 'weeklyProgress': 0.0
    },
    error: (error, stack) => {
      'total': 0, 'completed': 0, 'pending': 0, 'completionRate': 0.0, 'nextUp': null, 'today': 0, 'weeklyProgress': 0.0
    },
  );
});
