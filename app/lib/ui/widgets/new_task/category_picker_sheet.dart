import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masstodo/providers/category_provider.dart';

class CategoryPickerSheet extends ConsumerStatefulWidget {
  final String? initialCategoryId;
  final bool initialIsCreating;
  final Function(String? id, bool isCreating, String newName) onSelected;

  const CategoryPickerSheet({
    super.key,
    this.initialCategoryId,
    this.initialIsCreating = false,
    required this.onSelected,
  });

  @override
  ConsumerState<CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends ConsumerState<CategoryPickerSheet> {
  late bool _isCreating;
  final _newCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isCreating = widget.initialIsCreating;
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 24.0,
        bottom: 24.0 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 16),
          if (categoriesAsync.hasValue)
            ...categoriesAsync.value!.map(
              (c) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  c.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                trailing: widget.initialCategoryId == c.id ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary) : null,
                onTap: () {
                  widget.onSelected(c.id, false, '');
                  Navigator.pop(context);
                },
              ),
            ),
          const Divider(),
          if (!_isCreating)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              title: Text(
                'Create New Category',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              onTap: () {
                setState(() {
                  _isCreating = true;
                });
              },
            ),
          if (_isCreating) ...[
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newCategoryController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Enter category name...',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.check_circle,
                      size: 36,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      if (_newCategoryController.text.isNotEmpty) {
                        widget.onSelected(null, true, _newCategoryController.text);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
