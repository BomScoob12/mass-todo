import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/models/task_model.dart';
import 'package:app/models/task_with_category.dart';
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

// Derived providers
final tasksWithCategoryProvider = Provider<AsyncValue<List<TaskWithCategory>>>((ref) {
  final tasksAsync = ref.watch(taskListProvider);
  final categoriesAsync = ref.watch(categoryProvider);

  return tasksAsync.whenData((tasks) {
    return categoriesAsync.maybeWhen(
      data: (categories) => tasks.map((task) {
        final category = categories.firstWhere(
          (c) => c.id == task.categoryId,
          orElse: () => TaskCategory(id: 'unknown', name: 'Other', colorHex: '#9E9E9E'),
        );
        return TaskWithCategory(task: task, category: category);
      }).toList(),
      orElse: () => tasks.map((task) => TaskWithCategory(task: task)).toList(),
    );
  });
});

final tasksStatsProvider = Provider((ref) {
  final tasksWithCategoryAsync = ref.watch(tasksWithCategoryProvider);
  
  return tasksWithCategoryAsync.when(
    data: (tasksWithCat) {
      final tasks = tasksWithCat.map((twc) => twc.task).toList();
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
      
      final pendingTasksWithCat = tasksWithCat.where((twc) => !twc.task.isCompleted).toList();
      pendingTasksWithCat.sort((a, b) {
        final taskA = a.task;
        final taskB = b.task;
        if (taskA.deadline == null && taskB.deadline == null) return _comparePriority(taskA.priority, taskB.priority);
        if (taskA.deadline == null) return 1;
        if (taskB.deadline == null) return -1;
        final dateCompare = taskA.deadline!.compareTo(taskB.deadline!);
        if (dateCompare == 0) {
          return _comparePriority(taskA.priority, taskB.priority);
        }
        return dateCompare;
      });
      
      final nextPriority = pendingTasksWithCat.isNotEmpty ? pendingTasksWithCat.first : null;

      return {
        'total': total,
        'completed': completed,
        'pending': pending,
        'completionRate': completionRate,
        'nextPriority': nextPriority,
        'today': todayCount,
        'weeklyProgress': weeklyProgress,
      };
    },
    loading: () => {
      'total': 0, 'completed': 0, 'pending': 0, 'completionRate': 0.0, 'nextPriority': null, 'today': 0, 'weeklyProgress': 0.0
    },
    error: (error, stack) => {
      'total': 0, 'completed': 0, 'pending': 0, 'completionRate': 0.0, 'nextPriority': null, 'today': 0, 'weeklyProgress': 0.0
    },
  );
});

int _comparePriority(String a, String b) {
  const priorityMap = {'high': 3, 'medium': 2, 'low': 1};
  final aVal = priorityMap[a.toLowerCase()] ?? 0;
  final bVal = priorityMap[b.toLowerCase()] ?? 0;
  return bVal.compareTo(aVal); // Descending (High first)
}
