import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/models/task_model.dart';
import 'package:app/providers/task_provider.dart';
import 'package:app/ui/new_task_screen.dart';
import 'package:app/ui/widgets/dashboard/dashboard_header.dart';
import 'package:app/ui/widgets/dashboard/bento_grid_stats.dart';
import 'package:app/ui/widgets/dashboard/next_up_card.dart';
import 'package:app/ui/widgets/dashboard/weekly_progress_bar.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(tasksStatsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const DashboardHeader(),
              const SizedBox(height: 32),

              // Hero Greeting
              Text(
                'Design your day',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'You have ${stats['pending'] ?? 0} tasks requiring attention.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 32),

              // Summary Bento Grid
              BentoGridStats(
                todayTasks: (stats['today'] ?? 0) as int,
                pendingTasks: (stats['pending'] ?? 0) as int,
                completedTasks: (stats['completed'] ?? 0) as int,
              ),
              const SizedBox(height: 32),

              // Next Up
              NextUpCard(task: stats['nextPriority'] as TaskItem?),
              const SizedBox(height: 32),

              // Weekly Progress
              WeeklyProgressBar(rawProgress: stats['weeklyProgress'] as double? ?? 0.0),
              
              // Bottom padding
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NewTaskScreen()),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onTertiary, size: 30),
      ),
    );
  }
}

