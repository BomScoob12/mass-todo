import 'package:flutter/material.dart';
import 'package:app/models/task_model.dart';
import 'package:app/ui/widgets/tasks/task_list_item.dart';

class TaskGroupSection extends StatelessWidget {
  final TaskCategory category;
  final List<TaskItem> tasks;

  const TaskGroupSection({
    super.key,
    required this.category,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
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
                  Icon(Icons.folder_open, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
          ...tasks.map((t) => TaskListItem(task: t)),
        ],
      ),
    );
  }
}
