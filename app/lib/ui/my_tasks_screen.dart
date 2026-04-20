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
        title: const Text('My Tasks'),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryFilters(categoriesAsync),
          Expanded(
            child: _buildTaskList(tasksAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(AsyncValue<List<TaskCategory>> categoriesAsync) {
    return categoriesAsync.when(
      data: (categories) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: const Text('All'),
                  selected: _selectedCategoryId == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategoryId = null;
                    });
                  },
                ),
              ),
              ...categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category.name),
                    selected: _selectedCategoryId == category.id,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategoryId = selected ? category.id : null;
                      });
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, stack) => const SizedBox(),
    );
  }

  Widget _buildTaskList(AsyncValue<List<TaskItem>> tasksAsync) {
    return tasksAsync.when(
      data: (tasks) {
        final filteredTasks = _selectedCategoryId == null
            ? tasks
            : tasks.where((t) => t.categoryId == _selectedCategoryId).toList();

        if (filteredTasks.isEmpty) {
          return const Center(child: Text('No tasks found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12.0),
              child: ListTile(
                leading: Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: task.isCompleted,
                    activeColor: AppTheme.primaryColor,
                    shape: const CircleBorder(),
                    onChanged: (value) {
                      ref.read(taskListProvider.notifier).toggleTaskCompletion(task.id);
                    },
                  ),
                ),
                title: Text(
                  task.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        color: task.isCompleted ? AppTheme.textSecondaryColor : AppTheme.textPrimaryColor,
                      ),
                ),
                subtitle: task.deadline != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          DateFormat('MMM dd, yyyy h:mm a').format(task.deadline!),
                        ),
                      )
                    : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    ref.read(taskListProvider.notifier).deleteTask(task.id);
                  },
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TaskDetailsScreen(task: task),
                  ));
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
