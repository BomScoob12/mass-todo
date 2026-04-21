import 'package:flutter_riverpod/flutter_riverpod.dart';

final showCompletedTasksProvider = NotifierProvider<ShowCompletedTasksNotifier, bool>(() {
  return ShowCompletedTasksNotifier();
});

class ShowCompletedTasksNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}

