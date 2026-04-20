import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/models/task_model.dart';
import 'package:app/providers/database_providers.dart';

final categoryProvider = AsyncNotifierProvider<CategoryNotifier, List<TaskCategory>>(() {
  return CategoryNotifier();
});

class CategoryNotifier extends AsyncNotifier<List<TaskCategory>> {
  @override
  FutureOr<List<TaskCategory>> build() async {
    return _fetchCategories();
  }

  Future<List<TaskCategory>> _fetchCategories() async {
    final repository = ref.read(categoryRepositoryProvider);
    final categories = await repository.getAllCategories();
    if (categories.isEmpty) {
      final defCat = TaskCategory(id: 'cat_default', name: 'General', colorHex: '#9E9E9E');
      await repository.createCategory(defCat);
      return [defCat];
    }
    return categories;
  }

  Future<void> addCategory(TaskCategory category) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(categoryRepositoryProvider).createCategory(category);
      final categories = await _fetchCategories();
      state = AsyncValue.data(categories);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteCategory(String id) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(categoryRepositoryProvider).deleteCategory(id);
      final categories = await _fetchCategories();
      state = AsyncValue.data(categories);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
