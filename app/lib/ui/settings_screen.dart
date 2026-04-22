import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masstodo/providers/category_provider.dart';
import 'package:masstodo/providers/task_provider.dart';
import 'package:masstodo/models/task_model.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: categoriesAsync.when(
        data: (categories) {
          return ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: categories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    'Category Management',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                );
              }
              final category = categories[index - 1];
              final isDefault = category.id == 'cat_default';

              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                elevation: 0,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  title: Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  trailing: isDefault 
                    ? const Tooltip(
                        message: "The default category cannot be modified.",
                        child: Icon(Icons.lock_outline, size: 24, color: Colors.grey),
                      ) 
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            color: Theme.of(context).colorScheme.primary,
                            onPressed: () => _showEditDialog(context, ref, category),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Theme.of(context).colorScheme.error,
                            onPressed: () => _showDeleteConfirmDialog(context, ref, category),
                          ),
                        ],
                      ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, TaskCategory category) {
    final controller = TextEditingController(text: category.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Category'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Category Name',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != category.name) {
                final updatedCategory = TaskCategory(
                  id: category.id,
                  name: newName,
                  colorHex: category.colorHex,
                );
                ref.read(categoryProvider.notifier).updateCategory(updatedCategory);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, TaskCategory category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Text(
          'All tasks within "${category.name}" will be permanently deleted. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(taskListProvider.notifier).deleteTasksByCategoryId(category.id);
              await ref.read(categoryProvider.notifier).deleteCategory(category.id);
            },
            child: Text('Delete All', style: TextStyle(color: Theme.of(context).colorScheme.onError)),
          ),
        ],
      ),
    );
  }
}
