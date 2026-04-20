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
                        TextFormField(
                          controller: _nameController,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                          decoration: InputDecoration(
                            hintText: 'What needs your attention?',
                            hintStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.outlineVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a task name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildLabel('Description'),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          style: Theme.of(context).textTheme.bodyLarge,
                          decoration: InputDecoration(
                            hintText: 'Add context, notes, or sub-items...',
                            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.outlineVariant,
                                ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(child: _buildCategoryCard(categoriesAsync)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildDeadlineCard()),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildLabel('Priority Level'),
                        _buildPrioritySelector(),
                        const SizedBox(height: 48), 
                      ],
                    ),
                  ),
                ),
              ),
              // Floating Save Button
              const SizedBox(height: 16),
              _buildSaveButton(),
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

  Widget _buildCategoryCard(AsyncValue<List<TaskCategory>> categoriesAsync) {
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

    return InkWell(
      onTap: () => _showCategoryPicker(categoriesAsync),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CATEGORY',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.architecture, size: 16, color: Theme.of(context).colorScheme.onSecondaryContainer),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    categoryName,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                Icon(Icons.unfold_more, size: 20, color: Theme.of(context).colorScheme.outline),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeadlineCard() {
    return InkWell(
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
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DEADLINE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.calendar_month, size: 16, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedDate != null ? DateFormat('MMM d, h:mm a').format(_selectedDate!) : 'Not set',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ['Low', 'Medium', 'High'].map((p) {
          final isSelected = _priority == p;

          Color bgColor = Colors.transparent;
          Color textColor = Theme.of(context).colorScheme.onSurfaceVariant;
          IconData iconData = Icons.horizontal_rule;

          if (p == 'Low') iconData = Icons.keyboard_arrow_down;
          if (p == 'High') iconData = Icons.keyboard_arrow_up;

          if (isSelected) {
            bgColor = Theme.of(context).colorScheme.surface;
            if (p == 'High') {
              bgColor = Colors.orange.shade800;
              textColor = Colors.white;
            } else {
              textColor = Theme.of(context).colorScheme.primary;
            }
          }

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _priority = p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: (isSelected && p == 'High')
                      ? [BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]
                      : (isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))] : []),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(iconData, size: 18, color: textColor),
                    const SizedBox(width: 6),
                    Text(
                      p,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: textColor,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSaveButton() {
    return InkWell(
      onTap: _saveTask,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              AppTheme.primaryColor.withOpacity(0.7),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Save Task',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.check_circle, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Future<void> _showCategoryPicker(AsyncValue<List<TaskCategory>> categoriesAsync) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
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
