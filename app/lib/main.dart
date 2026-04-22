import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masstodo/ui/app_theme.dart';
import 'package:masstodo/ui/main_navigation.dart';
import 'package:masstodo/utils/messenger_utils.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: TodoApp()));
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MassTodo',
      theme: AppTheme.lightTheme,
      scaffoldMessengerKey: Messenger.scaffoldMessengerKey,
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}
