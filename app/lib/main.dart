import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/ui/app_theme.dart';
import 'package:app/ui/main_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: TodoApp()));
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline First Todo',
      theme: AppTheme.lightTheme,
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}
