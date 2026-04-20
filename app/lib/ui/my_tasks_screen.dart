import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/providers/task_provider.dart';
import 'package:app/providers/category_provider.dart';
import 'package:app/ui/app_theme.dart';
import 'package:app/models/task_model.dart';
import 'package:intl/intl.dart';
import 'package:app/ui/new_task_screen.dart';
import 'package:app/ui/task_details_screen.dart';

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
      appBar: AppBar(
        title: const Text('Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor),
            iconSize: 32,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const NewTaskScreen(),
              ));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
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
        
        return _buildTaskGroup(context, category, categoryTasks);
      },
    );
  }

  Widget _buildTaskGroup(BuildContext context, TaskCategory category, List<TaskItem> tasks) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(32.0),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.category_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${tasks.where((t) => !t.isCompleted).length} Active',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          ...tasks.map((t) => _buildTaskItem(context, t)),
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, TaskItem task) {
    Color priorityColor;
    switch (task.priority) {
      case 'High':
        priorityColor = Theme.of(context).colorScheme.error;
        break;
      case 'Medium':
        priorityColor = Colors.orange; 
        break;
      default:
        priorityColor = Theme.of(context).colorScheme.outlineVariant;
    }

    final isCompleted = task.isCompleted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Dismissible(
        key: Key(task.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onErrorContainer),
        ),
        onDismissed: (_) {
          ref.read(taskListProvider.notifier).deleteTask(task.id);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isCompleted ? Theme.of(context).colorScheme.surface.withOpacity(0.5) : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: isCompleted ? Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.2)) : null,
            boxShadow: isCompleted ? [] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TaskDetailsScreen(task: task),
              ));
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => ref.read(taskListProvider.notifier).toggleTaskCompletion(task.id),
                    child: Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(top: 2, right: 16),
                      decoration: BoxDecoration(
                        color: isCompleted ? Theme.of(context).colorScheme.primary : Colors.transparent,
                        border: Border.all(
                          color: isCompleted ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: isCompleted ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                    ),
                  ),
                  Expanded(
                    child: Opacity(
                      opacity: isCompleted ? 0.6 : 1.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                ),
                          ),
                          if (task.deadline != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.schedule, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('MMM dd, yyyy h:mm a').format(task.deadline!),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: priorityColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
