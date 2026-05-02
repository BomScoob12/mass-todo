import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masstodo/models/task_model.dart';
import 'package:masstodo/providers/task_provider.dart';
import 'package:masstodo/providers/database_providers.dart';
import 'package:masstodo/utils/notification_service.dart';
import 'package:masstodo/repositories/task_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'task_provider_test.mocks.dart';

@GenerateMocks([TaskRepository, NotificationService])
void main() {
  late MockTaskRepository mockTaskRepository;
  late MockNotificationService mockNotificationService;
  late ProviderContainer container;

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    mockNotificationService = MockNotificationService();

    container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(mockTaskRepository),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  final testTaskWithDeadline = TaskItem(
    id: '1',
    name: 'Test Task',
    categoryId: 'cat1',
    priority: 'High',
    createdAt: DateTime.now(),
    deadline: DateTime.now().add(const Duration(days: 1)),
  );

  final testTaskWithoutDeadline = TaskItem(
    id: '2',
    name: 'Test Task No Deadline',
    categoryId: 'cat1',
    priority: 'Low',
    createdAt: DateTime.now(),
  );

  test('addTask schedules notification if deadline exists and not completed', () async {
    when(mockTaskRepository.getAllTasks(includeCompleted: anyNamed('includeCompleted')))
        .thenAnswer((_) async => [testTaskWithDeadline]);
    when(mockTaskRepository.createTask(any)).thenAnswer((_) async => testTaskWithDeadline);
    when(mockTaskRepository.getDashboardStats()).thenAnswer((_) async => {});

    await container.read(taskListProvider.notifier).addTask(testTaskWithDeadline);

    verify(mockTaskRepository.createTask(testTaskWithDeadline)).called(1);
    verify(mockNotificationService.scheduleTaskNotification(testTaskWithDeadline)).called(1);
    verifyNever(mockNotificationService.cancelTaskNotification(any));
  });

  test('addTask does not schedule notification if no deadline', () async {
    when(mockTaskRepository.getAllTasks(includeCompleted: anyNamed('includeCompleted')))
        .thenAnswer((_) async => [testTaskWithoutDeadline]);
    when(mockTaskRepository.createTask(any)).thenAnswer((_) async => testTaskWithoutDeadline);
    when(mockTaskRepository.getDashboardStats()).thenAnswer((_) async => {});

    await container.read(taskListProvider.notifier).addTask(testTaskWithoutDeadline);

    verify(mockTaskRepository.createTask(testTaskWithoutDeadline)).called(1);
    verifyNever(mockNotificationService.scheduleTaskNotification(any));
  });

  test('updateTask cancels notification if completed, else schedules', () async {
    when(mockTaskRepository.getAllTasks(includeCompleted: anyNamed('includeCompleted')))
        .thenAnswer((_) async => [testTaskWithDeadline]);
    when(mockTaskRepository.updateTask(any)).thenAnswer((_) async => 1);
    when(mockTaskRepository.getDashboardStats()).thenAnswer((_) async => {});

    // Ensure state is populated before updating
    await container.read(taskListProvider.future);

    final completedTask = testTaskWithDeadline.copyWith(isCompleted: true);
    await container.read(taskListProvider.notifier).updateTask(completedTask);

    verify(mockNotificationService.cancelTaskNotification(completedTask.id)).called(1);

    final updatedDeadlineTask = testTaskWithDeadline.copyWith(name: 'Updated Name');
    await container.read(taskListProvider.notifier).updateTask(updatedDeadlineTask);

    verify(mockNotificationService.scheduleTaskNotification(updatedDeadlineTask)).called(1);
  });

  test('deleteTask cancels notification', () async {
    when(mockTaskRepository.getAllTasks(includeCompleted: anyNamed('includeCompleted')))
        .thenAnswer((_) async => [testTaskWithDeadline]);
    when(mockTaskRepository.deleteTask(any)).thenAnswer((_) async => 1);
    when(mockTaskRepository.getDashboardStats()).thenAnswer((_) async => {});

    await container.read(taskListProvider.future);

    await container.read(taskListProvider.notifier).deleteTask('1');

    verify(mockNotificationService.cancelTaskNotification('1')).called(1);
  });

  test('toggleTaskCompletion cancels notification if completing', () async {
    when(mockTaskRepository.getAllTasks(includeCompleted: anyNamed('includeCompleted')))
        .thenAnswer((_) async => [testTaskWithDeadline]);
    when(mockTaskRepository.updateTask(any)).thenAnswer((_) async => 1);
    when(mockTaskRepository.getDashboardStats()).thenAnswer((_) async => {});

    await container.read(taskListProvider.future);

    await container.read(taskListProvider.notifier).toggleTaskCompletion('1');

    // It was not completed, so toggling makes it completed
    verify(mockNotificationService.cancelTaskNotification('1')).called(1);
  });
}
