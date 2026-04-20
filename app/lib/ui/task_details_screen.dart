import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/models/task_model.dart';
import 'package:app/providers/task_provider.dart';
import 'package:app/providers/category_provider.dart';
import 'package:intl/intl.dart';

class TaskDetailsScreen extends ConsumerWidget {
  final TaskItem task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryProvider);
    String categoryName = 'Unknown';
    if (categoriesAsync.hasValue) {
      try {
        categoryName = categoriesAsync.value!.firstWhere((c) => c.id == task.categoryId).name;
      } catch (e) {
        categoryName = 'Unknown';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Show confirmation
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Task?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        ref.read(taskListProvider.notifier).deleteTask(task.id);
                        Navigator.pop(ctx); // Close dialog
                        Navigator.pop(context); // Go back
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Transform.scale(
                  scale: 1.5,
                  child: Checkbox(
                    value: task.isCompleted,
                    shape: const CircleBorder(),
                    onChanged: (val) {
                      ref.read(taskListProvider.notifier).toggleTaskCompletion(task.id);
                      Navigator.pop(context); // Go back to update list
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildDetailRow(context, Icons.folder, 'Category', categoryName),
            const Divider(height: 32),
            _buildDetailRow(
              context,
              Icons.calendar_month,
              'Deadline',
              task.deadline != null ? DateFormat('MMMM d, yyyy - h:mm a').format(task.deadline!) : 'No deadline',
            ),
            const Divider(height: 32),
            _buildDetailRow(context, Icons.flag, 'Priority', task.priority),
            const Divider(height: 32),
            if (task.description != null && task.description!.isNotEmpty) ...[
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Text(
                  task.description!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
            const SizedBox(height: 48),
            Text(
              'Created on ${DateFormat('MMM d, yyyy').format(task.createdAt)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ],
    );
  }
}
