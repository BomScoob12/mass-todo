import 'package:flutter/material.dart';
import 'package:masstodo/models/task_model.dart';
import 'package:masstodo/providers/task_provider.dart';
import 'package:masstodo/ui/task_details_screen.dart';
import 'package:masstodo/utils/date_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskListItem extends ConsumerWidget {
  final TaskItem task;

  const TaskListItem({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            color: isCompleted ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.5) : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: isCompleted ? Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.2)) : null,
            boxShadow: isCompleted ? [] : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
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
                    onTap: () async {
                      final wasCompleted = task.isCompleted;
                      await ref
                          .read(taskListProvider.notifier)
                          .toggleTaskCompletion(task.id);

                      if (!mounted) return;
                      if (!wasCompleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Task "${task.name}" completed!'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            action: SnackBarAction(
                              label: 'Dismiss',
                              textColor: Colors.white,
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                              },
                            ),
                          ),
                        );
                      }
                    },
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
                                Icon(Icons.schedule,
                                    size: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(
                                  task.deadline!.formatFull,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
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
