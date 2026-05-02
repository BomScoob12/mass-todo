import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:masstodo/models/task_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  @visibleForTesting
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    _isInitialized = true;
  }

  Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();

    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> scheduleTaskNotification(TaskItem task) async {
    if (task.deadline == null || task.isCompleted) return;

    // Schedule 60 minutes before by default
    final scheduledTime = task.deadline!.subtract(const Duration(minutes: 60));

    // Only schedule if the time is in the future
    if (scheduledTime.isBefore(DateTime.now())) return;

    final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'task_deadlines_channel',
      'Task Deadlines',
      channelDescription: 'Notifications for upcoming task deadlines',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    // Create a deterministic int ID from the string UUID
    final int notificationId = task.id.hashCode;

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: notificationId,
        title: 'Upcoming Task: ${task.name}',
        body: 'Your task is due in 60 minutes',
        scheduledDate: tzScheduledTime,
        notificationDetails: platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: task.id,
      );
      debugPrint('Scheduled notification for task ${task.id} at $scheduledTime');
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
    }
  }

  Future<void> cancelTaskNotification(String taskId) async {
    try {
      final int notificationId = taskId.hashCode;
      await flutterLocalNotificationsPlugin.cancel(id: notificationId);
      debugPrint('Cancelled notification for task $taskId');
    } catch (e) {
      debugPrint('Failed to cancel notification: $e');
    }
  }
}
