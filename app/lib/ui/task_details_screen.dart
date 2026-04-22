import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masstodo/models/task_model.dart';
import 'package:masstodo/providers/task_provider.dart';
import 'package:masstodo/providers/category_provider.dart';
import 'package:masstodo/utils/date_extensions.dart';
import 'package:masstodo/utils/messenger_utils.dart';
import 'package:masstodo/ui/new_task_screen.dart';
import 'package:masstodo/ui/app_styles.dart';

class TaskDetailsScreen extends ConsumerWidget {
  final TaskItem task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskListProvider);
    final categoriesAsync = ref.watch(categoryProvider);

    // Try to find the latest version of the task from the provider
    final currentTask = tasksAsync.maybeWhen(
      data: (tasks) => tasks.cast<TaskItem?>().firstWhere(
            (t) => t?.id == task.id,
            orElse: () => task,
          ),
      orElse: () => task,
    );

    if (currentTask == null) {
      return const Scaffold(body: Center(child: Text('Task not found')));
    }

    final categoryName = categoriesAsync.maybeWhen(
      data: (categories) => categories
          .cast<TaskCategory?>()
          .firstWhere((c) => c?.id == currentTask.categoryId, orElse: () => null)
          ?.name ?? 'Other',
      orElse: () => 'Loading...',
    );

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
            onPressed: () => _confirmDelete(context, ref, currentTask.id),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(context, currentTask),
                  SizedBox(height: AppSpacing.xl),
                  _buildInfoCard(context, currentTask, categoryName),
                  if (currentTask.description?.isNotEmpty ?? false) ...[
                    SizedBox(height: AppSpacing.xl),
                    _buildNotesSection(context, currentTask.description!),
                  ],
                  SizedBox(height: AppSpacing.xxl),
                  _buildCreationDate(context, currentTask.createdAt),
                ],
              ),
            ),
          ),
          _buildCompletionButton(context, ref, currentTask),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, TaskItem task) {
    return Text(
      task.name,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : Theme.of(context).colorScheme.onSurface,
          ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, TaskItem task, String categoryName) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.4),
        borderRadius: AppRadius.radiusXL,
      ),
      padding: AppSpacing.cardPadding,
      child: Column(
        children: [
          _buildDetailRow(
              context, Icons.category_outlined, 'Category', categoryName),
          const Divider(height: AppSpacing.xl),
          _buildDetailRow(
              context, Icons.flag_outlined, 'Priority', task.priority),
          const Divider(height: AppSpacing.xl),
          _buildDetailRow(
            context,
            Icons.schedule,
            'Deadline',
            task.deadline?.formatDetails ?? 'Not set',
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context, String notes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.m),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.2),
            borderRadius: AppRadius.radiusL,
            border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.2)),
          ),
          child: Text(
            notes,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreationDate(BuildContext context, DateTime createdAt) {
    return Center(
      child: Text(
        'Created on ${createdAt.formatMDY}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildCompletionButton(BuildContext context, WidgetRef ref, TaskItem task) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () async {
            final wasCompleted = task.isCompleted;
            await ref.read(taskListProvider.notifier).toggleTaskCompletion(task.id);
            
            if (!context.mounted) return;
            if (!wasCompleted) {
              Messenger.showSnackbar('Task "${task.name}" completed!', isSuccess: true);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: task.isCompleted
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Theme.of(context).colorScheme.primary,
            foregroundColor: task.isCompleted ? Theme.of(context).colorScheme.onSurfaceVariant : Colors.white,
          ),
          child: Text(task.isCompleted ? 'Mark as Incomplete' : 'Complete Task'),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String taskId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(taskListProvider.notifier).deleteTask(taskId);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
            Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline)),
            const SizedBox(height: 2),
            Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}
