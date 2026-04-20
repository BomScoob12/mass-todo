import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/models/task_model.dart';
import 'package:app/providers/task_provider.dart';
import 'package:app/providers/category_provider.dart';
import 'package:app/ui/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:app/ui/widgets/new_task/priority_selector.dart';
import 'package:app/ui/widgets/new_task/gradient_save_button.dart';
import 'package:app/ui/widgets/new_task/metadata_selector_card.dart';
import 'package:app/ui/widgets/new_task/custom_text_field.dart';

class NewTaskScreen extends ConsumerStatefulWidget {
  final TaskItem? taskToEdit;
  
  const NewTaskScreen({super.key, this.taskToEdit});

  @override
  ConsumerState<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends ConsumerState<NewTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime? _selectedDate;
  String _priority = 'Low';
  String? _selectedCategory;
  bool _isCreatingCategory = false;
  final _newCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _nameController.text = widget.taskToEdit!.name;
      if (widget.taskToEdit!.description != null) {
        _descriptionController.text = widget.taskToEdit!.description!;
      }
      _selectedDate = widget.taskToEdit!.deadline;
      _priority = widget.taskToEdit!.priority;
      _selectedCategory = widget.taskToEdit!.categoryId;
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null && !_isCreatingCategory) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select or create a category')));
        return;
      }

      final uuid = const Uuid().v4();
      String finalCategoryId = _selectedCategory ?? '';
      
      if (_isCreatingCategory && _newCategoryController.text.isNotEmpty) {
        finalCategoryId = const Uuid().v4();
        ref.read(categoryProvider.notifier).addCategory(
          TaskCategory(
            id: finalCategoryId,
            name: _newCategoryController.text.trim(),
          ),
        );
      }

      if (widget.taskToEdit != null) {
        final updatedTask = widget.taskToEdit!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          categoryId: finalCategoryId,
          deadline: _selectedDate,
          priority: _priority,
        );
        ref.read(taskListProvider.notifier).updateTask(updatedTask);
      } else {
        final task = TaskItem(
          id: uuid,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          categoryId: finalCategoryId,
          deadline: _selectedDate,
          priority: _priority,
          createdAt: DateTime.now(),
        );
        ref.read(taskListProvider.notifier).addTask(task);
      }
      
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryProvider);

    String categoryName = 'Select';
    if (_isCreatingCategory) {
      categoryName = 'New: ${_newCategoryController.text}';
    } else if (_selectedCategory != null && categoriesAsync.hasValue) {
      try {
        categoryName = categoriesAsync.value!.firstWhere((c) => c.id == _selectedCategory).name;
      } catch (e) {
        categoryName = 'Unknown';
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Custom Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.taskToEdit == null ? 'New Task' : 'Edit Task',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 32),
              // Form Body
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Task Name'),
                        CustomTextField(
                          controller: _nameController,
                          hintText: 'What needs your attention?',
                          isTitle: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a task name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildLabel('Description'),
                        CustomTextField(
                          controller: _descriptionController,
                          hintText: 'Add context, notes, or sub-items...',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: MetadataSelectorCard(
                                onTap: () => _showCategoryPicker(categoriesAsync),
                                label: 'Category',
                                valueText: categoryName,
                                iconView: Icons.architecture,
                                iconBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                iconColor: Theme.of(context).colorScheme.onSecondaryContainer,
                                hasTrailingIcon: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: MetadataSelectorCard(
                                onTap: _pickDeadline,
                                label: 'Deadline',
                                valueText: _selectedDate != null ? DateFormat('MMM d, h:mm a').format(_selectedDate!) : 'Not set',
                                iconView: Icons.calendar_month,
                                iconBackgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                                iconColor: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildLabel('Priority Level'),
                        PrioritySelector(
                          currentPriority: _priority,
                          onChanged: (val) => setState(() => _priority = val),
                        ),
                        const SizedBox(height: 48), 
                      ],
                    ),
                  ),
                ),
              ),
              // Floating Save Button
              const SizedBox(height: 16),
              GradientSaveButton(onPressed: _saveTask),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 10.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    );
    if (date != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _showCategoryPicker(AsyncValue<List<TaskCategory>> categoriesAsync) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                  Text('Categories', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  if (categoriesAsync.hasValue)
                    ...categoriesAsync.value!.map((c) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(c.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          onTap: () {
                            setState(() {
                              _selectedCategory = c.id;
                              _isCreatingCategory = false;
                            });
                            Navigator.pop(context);
                          },
                        )),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                       width: 36, height: 36, 
                       decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, shape: BoxShape.circle),
                       child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimaryContainer, size: 20)
                    ),
                    title: Text('Create New Category', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
                    onTap: () {
                      setSheetState(() {
                        _isCreatingCategory = true;
                      });
                    },
                  ),
                  if (_isCreatingCategory) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _newCategoryController,
                              decoration: InputDecoration(
                                hintText: 'Enter category name...',
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              ),
                              onChanged: (_) {
                                setState(() {});
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.check_circle, size: 36, color: Theme.of(context).colorScheme.primary),
                            onPressed: () {
                              if (_newCategoryController.text.isNotEmpty) {
                                setState(() {
                                  _selectedCategory = null;
                                  _isCreatingCategory = true;
                                });
                                Navigator.pop(context);
                              }
                            },
                          )
                        ],
                      ),
                    )
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      },
    );
  }
}
