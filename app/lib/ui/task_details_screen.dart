import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/models/task_model.dart';
import 'package:app/providers/task_provider.dart';
import 'package:app/providers/category_provider.dart';
import 'package:intl/intl.dart';
import 'package:app/ui/new_task_screen.dart';

class TaskDetailsScreen extends ConsumerWidget {
  final TaskItem task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We watch tasks list so that if we edit the task, this screen updates
    final tasksAsync = ref.watch(taskListProvider);
    final categoriesAsync = ref.watch(categoryProvider);

    TaskItem? currentTask = task;
    if (tasksAsync.hasValue) {
      try {
        currentTask = tasksAsync.value!.firstWhere((t) => t.id == task.id);
      } catch (e) {
        // Task might have been deleted locally
      }
    }
    
    if (currentTask == null) {
      return const Scaffold(body: Center(child: Text('Task not found')));
    }

    String categoryName = 'Unknown';
    if (categoriesAsync.hasValue) {
      try {
        categoryName = categoriesAsync.value!.firstWhere((c) => c.id == currentTask!.categoryId).name;
      } catch (e) {
        categoryName = 'Other';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NewTaskScreen(taskToEdit: currentTask),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Task?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        ref.read(taskListProvider.notifier).deleteTask(currentTask!.id);
                        Navigator.pop(ctx); 
                        Navigator.pop(context); 
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentTask.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          decoration: currentTask.isCompleted ? TextDecoration.lineThrough : null,
                          color: currentTask.isCompleted ? Theme.of(context).colorScheme.onSurfaceVariant : Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        _buildDetailRow(context, Icons.category_outlined, 'Category', categoryName),
                        const Divider(height: 32),
                        _buildDetailRow(context, Icons.flag_outlined, 'Priority', currentTask.priority),
                        const Divider(height: 32),
                        _buildDetailRow(
                          context,
                          Icons.schedule,
                          'Deadline',
                          currentTask.deadline != null ? DateFormat('MMMM d, yyyy - h:mm a').format(currentTask.deadline!) : 'Not set',
                        ),
                      ],
                    ),
                  ),
                  if (currentTask.description != null && currentTask.description!.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Text(
                      'Notes',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        currentTask.description!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              height: 1.6,
                            ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 48),
                  Center(
                    child: Text(
                      'Created on ${DateFormat('MMM d, yyyy').format(currentTask.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(taskListProvider.notifier).toggleTaskCompletion(currentTask!.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentTask.isCompleted 
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : Theme.of(context).colorScheme.primary,
                  foregroundColor: currentTask.isCompleted
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Colors.white,
                ),
                child: Text(
                  currentTask.isCompleted ? 'Mark as Incomplete' : 'Complete Task',
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
           padding: const EdgeInsets.all(12),
           decoration: BoxDecoration(
             color: Theme.of(context).colorScheme.surface,
             borderRadius: BorderRadius.circular(12),
           ),
           child: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline)),
            const SizedBox(height: 2),
            Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}
