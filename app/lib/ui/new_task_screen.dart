import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/models/task_model.dart';
import 'package:app/providers/task_provider.dart';
import 'package:app/providers/category_provider.dart';
import 'package:app/ui/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskToEdit == null ? 'New Task' : 'Edit Task'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Task Name', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'What needs your attention?',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text('Description', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Add context, notes, or sub-items...',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildCategorySelector(categoriesAsync)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDeadlinePicker()),
                ],
              ),
              const SizedBox(height: 24),
              Text('Priority Level', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              _buildPriorityToggle(),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveTask,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Save Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(AsyncValue<List<TaskCategory>> categoriesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            _showCategoryPicker(categoriesAsync);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFF6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _isCreatingCategory
                        ? 'New: ${_newCategoryController.text}'
                        : (_selectedCategory != null
                            ? categoriesAsync.value?.firstWhere((c) => c.id == _selectedCategory).name ?? 'Unknown'
                            : 'Select Category'),
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Icon(Icons.unfold_more, color: AppTheme.textSecondaryColor),
              ],
            ),
          ),
        )
      ],
    );
  }

  Future<void> _showCategoryPicker(AsyncValue<List<TaskCategory>> categoriesAsync) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Category', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  if (categoriesAsync.hasValue)
                    ...categoriesAsync.value!.map((c) => ListTile(
                          title: Text(c.name),
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
                    leading: const Icon(Icons.add),
                    title: const Text('Create New Category'),
                    onTap: () {
                      setSheetState(() {
                        _isCreatingCategory = true;
                      });
                    },
                  ),
                  if (_isCreatingCategory) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _newCategoryController,
                              decoration: const InputDecoration(hintText: 'Enter category name'),
                              onChanged: (_) {
                                // refresh top state so the display text updates
                                setState(() {});
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check),
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
                  ]
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildDeadlinePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Deadline', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2050),
            );
            if (date != null) {
              if (!context.mounted) return;
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
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFF6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('MMM d, h:mm a').format(_selectedDate!)
                        : 'Not set',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFF6),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ['Low', 'Medium', 'High'].map((p) {
          final isSelected = _priority == p;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _priority = p;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? (p == 'High' ? Colors.orange[800] : AppTheme.primaryColor) : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    p,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
                        ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
