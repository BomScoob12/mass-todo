import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masstodo/models/task_model.dart';
import 'package:masstodo/providers/task_provider.dart';
import 'package:masstodo/providers/category_provider.dart';
import 'package:masstodo/providers/task_form_provider.dart';
import 'package:masstodo/utils/date_extensions.dart';
import 'package:uuid/uuid.dart';

import 'package:masstodo/ui/widgets/new_task/priority_selector.dart';
import 'package:masstodo/ui/widgets/common/gradient_save_button.dart';
import 'package:masstodo/ui/widgets/new_task/metadata_selector_card.dart';
import 'package:masstodo/ui/widgets/common/custom_text_field.dart';
import 'package:masstodo/ui/widgets/new_task/category_picker_sheet.dart';

class NewTaskScreen extends ConsumerStatefulWidget {
  final TaskItem? taskToEdit;

  const NewTaskScreen({super.key, this.taskToEdit});

  @override
  ConsumerState<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends ConsumerState<NewTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.taskToEdit?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.taskToEdit?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTask(TaskFormState formState) async {
    if (_formKey.currentState!.validate()) {
      if (formState.categoryId == null && !formState.isCreatingCategory) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select or create a category')),
        );
        return;
      }

      String finalCategoryId = formState.categoryId ?? '';

      if (formState.isCreatingCategory && formState.newCategoryName.isNotEmpty) {
        finalCategoryId = const Uuid().v4();
        await ref.read(categoryProvider.notifier).addCategory(
              TaskCategory(
                id: finalCategoryId,
                name: formState.newCategoryName.trim(),
              ),
            );
      }

      if (widget.taskToEdit != null) {
        final updatedTask = widget.taskToEdit!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          categoryId: finalCategoryId,
          deadline: formState.deadline,
          priority: formState.priority,
        );
        await ref.read(taskListProvider.notifier).updateTask(updatedTask);
      } else {
        final task = TaskItem(
          id: const Uuid().v4(),
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          categoryId: finalCategoryId,
          deadline: formState.deadline,
          priority: formState.priority,
          createdAt: DateTime.now(),
        );
        await ref.read(taskListProvider.notifier).addTask(task);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(taskFormProvider(widget.taskToEdit));
    final formNotifier = ref.read(taskFormProvider(widget.taskToEdit).notifier);
    final categoriesAsync = ref.watch(categoryProvider);

    String categoryName = 'Select';
    if (formState.isCreatingCategory) {
      categoryName = 'New: ${formState.newCategoryName}';
    } else if (formState.categoryId != null && categoriesAsync.hasValue) {
      try {
        categoryName = categoriesAsync.value!
            .firstWhere((c) => c.id == formState.categoryId)
            .name;
      } catch (e) {
        categoryName = 'Unknown';
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: AppSpacing.xl),
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
                        const SizedBox(height: AppSpacing.l),
                        _buildLabel('Description'),
                        CustomTextField(
                          controller: _descriptionController,
                          hintText: 'Add context, notes, or sub-items...',
                          maxLines: 3,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _buildMetadataSection(
                            context, formState, formNotifier, categoryName),
                        const SizedBox(height: AppSpacing.xl),
                        _buildLabel('Priority Level'),
                        PrioritySelector(
                          currentPriority: formState.priority,
                          onChanged: formNotifier.updatePriority,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              GradientSaveButton(onPressed: () => _saveTask(formState)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
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
          borderRadius: AppRadius.radiusXL,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataSection(BuildContext context, TaskFormState state,
      TaskFormNotifier notifier, String categoryName) {
    return Row(
      children: [
        Expanded(
          child: MetadataSelectorCard(
            onTap: () => _showCategoryPicker(state, notifier),
            label: 'Category',
            valueText: categoryName,
            iconView: Icons.architecture,
            iconBackgroundColor:
                Theme.of(context).colorScheme.secondaryContainer,
            iconColor: Theme.of(context).colorScheme.onSecondaryContainer,
            hasTrailingIcon: true,
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: MetadataSelectorCard(
            onTap: () => _pickDeadline(state, notifier),
            label: 'Deadline',
            valueText: state.deadline?.formatShort ?? 'Not set',
            iconView: Icons.calendar_month,
            iconBackgroundColor: Theme.of(context)
                .colorScheme
                .primaryContainer
                .withValues(alpha: 0.4),
            iconColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
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

  Future<void> _pickDeadline(TaskFormState state, TaskFormNotifier notifier) async {
    final date = await showDatePicker(
      context: context,
      initialDate: state.deadline ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2050),
    );
    if (date != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(state.deadline ?? DateTime.now()),
      );
      if (time != null) {
        notifier.updateDeadline(DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        ));
      }
    }
  }

  void _showCategoryPicker(TaskFormState state, TaskFormNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => CategoryPickerSheet(
        initialCategoryId: state.categoryId,
        initialIsCreating: state.isCreatingCategory,
        onSelected: (id, isCreating, newName) {
          if (isCreating) {
            notifier.updateNewCategoryName(newName);
            notifier.setCreatingCategory(true);
          } else {
            notifier.updateCategory(id);
          }
        },
      ),
    );
  }
}
