import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/providers/task_provider.dart';
import 'package:app/providers/category_provider.dart';
import 'package:app/ui/app_theme.dart';
import 'package:app/models/task_model.dart';
import 'package:intl/intl.dart';
import 'package:app/ui/new_task_screen.dart';
import 'package:app/ui/widgets/tasks/task_group_section.dart';

class MyTasksScreen extends ConsumerStatefulWidget {
  const MyTasksScreen({super.key});

  @override
  ConsumerState<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends ConsumerState<MyTasksScreen> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskListProvider);
    final categoriesAsync = ref.watch(categoryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Curated Inventory',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Focus on what matters next.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          _buildCategoryFilters(categoriesAsync),
          Expanded(
            child: _buildBody(tasksAsync, categoriesAsync),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NewTaskScreen()),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onTertiary, size: 30),
      ),
    );
  }

  Widget _buildCategoryFilters(AsyncValue<List<TaskCategory>> categoriesAsync) {
    return categoriesAsync.when(
      data: (categories) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Row(
            children: [
              _buildFilterChip('All Tasks', _selectedCategoryId == null, () {
                setState(() => _selectedCategoryId = null);
              }),
              ...categories.map((category) {
                return _buildFilterChip(category.name, _selectedCategoryId == category.id, () {
                  setState(() => _selectedCategoryId = _selectedCategoryId == category.id ? null : category.id);
                });
              }),
            ],
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, stack) => const SizedBox(),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  letterSpacing: 0.5,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AsyncValue<List<TaskItem>> tasksAsync, AsyncValue<List<TaskCategory>> categoriesAsync) {
    return tasksAsync.when(
      data: (tasks) {
        return categoriesAsync.when(
          data: (categories) => _buildGroupedList(tasks, categories),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildGroupedList(List<TaskItem> tasks, List<TaskCategory> categories) {
    final groups = <TaskCategory, List<TaskItem>>{};

    for (final task in tasks) {
      if (_selectedCategoryId != null && task.categoryId != _selectedCategoryId) {
        continue;
      }
      final category = categories.firstWhere(
        (c) => c.id == task.categoryId,
        orElse: () => TaskCategory(id: 'unknown', name: 'Other', colorHex: '#9E9E9E'),
      );
      groups.putIfAbsent(category, () => []).add(task);
    }

    if (groups.isEmpty) {
      return Center(
        child: Text(
          'No tasks found',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    final sortedCategories = groups.keys.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final category = sortedCategories[index];
        final categoryTasks = groups[category]!;
        // Sort category tasks: incomplete first, then by priority/deadline if desired. 
        // For now, simpler: incomplete first.
        categoryTasks.sort((a, b) {
          if (a.isCompleted == b.isCompleted) {
            return (a.deadline ?? DateTime.now()).compareTo(b.deadline ?? DateTime.now());
          }
          return a.isCompleted ? 1 : -1;
        });
        
        return TaskGroupSection(category: category, tasks: categoryTasks);
      },
    );
  }
}
