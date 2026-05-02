import 'package:flutter_test/flutter_test.dart';
import 'package:masstodo/utils/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:masstodo/models/task_model.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'notification_service_test.mocks.dart';

@GenerateMocks([FlutterLocalNotificationsPlugin])
void main() {
  late NotificationService notificationService;
  late MockFlutterLocalNotificationsPlugin mockPlugin;

  setUpAll(() {
    tz.initializeTimeZones();
  });

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    notificationService = NotificationService();
    notificationService.flutterLocalNotificationsPlugin = mockPlugin;
  });

  final testTask = TaskItem(
    id: 'test_uuid',
    name: 'Test Task',
    categoryId: 'cat',
    priority: 'High',
    createdAt: DateTime.now(),
    deadline: DateTime.now().add(const Duration(hours: 2)), // 2 hours from now
  );

  test('scheduleTaskNotification schedules correctly', () async {
    when(mockPlugin.zonedSchedule(
      id: anyNamed('id'),
      title: anyNamed('title'),
      body: anyNamed('body'),
      scheduledDate: anyNamed('scheduledDate'),
      notificationDetails: anyNamed('notificationDetails'),
      androidScheduleMode: anyNamed('androidScheduleMode'),
      payload: anyNamed('payload'),
    )).thenAnswer((_) async {});

    await notificationService.scheduleTaskNotification(testTask);

    final expectedTime = testTask.deadline!.subtract(const Duration(minutes: 60));
    final tzExpectedTime = tz.TZDateTime.from(expectedTime, tz.local);

    verify(mockPlugin.zonedSchedule(
      id: testTask.id.hashCode,
      title: 'Upcoming Task: ${testTask.name}',
      body: 'Your task is due in 60 minutes',
      scheduledDate: tzExpectedTime,
      notificationDetails: anyNamed('notificationDetails'),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: testTask.id,
    )).called(1);
  });

  test('scheduleTaskNotification does not schedule if time is in the past', () async {
    final pastTask = testTask.copyWith(deadline: DateTime.now().subtract(const Duration(hours: 1)));
    
    await notificationService.scheduleTaskNotification(pastTask);
    
    verifyNever(mockPlugin.zonedSchedule(
      id: anyNamed('id'),
      title: anyNamed('title'),
      body: anyNamed('body'),
      scheduledDate: anyNamed('scheduledDate'),
      notificationDetails: anyNamed('notificationDetails'),
      androidScheduleMode: anyNamed('androidScheduleMode'),
      payload: anyNamed('payload'),
    ));
  });

  test('cancelTaskNotification cancels correctly', () async {
    when(mockPlugin.cancel(id: anyNamed('id'))).thenAnswer((_) async {});

    await notificationService.cancelTaskNotification(testTask.id);

    verify(mockPlugin.cancel(id: testTask.id.hashCode)).called(1);
  });
}
