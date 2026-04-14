import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../../features/todo/domain/entities/todo_entity.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // This function is required for handling background notification taps
}

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _canScheduleExactAlarms = false;

  Future<void> init() async {
    try {
      tz.initializeTimeZones();
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notificationsPlugin.initialize(
      settings: const InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      ),
      onDidReceiveNotificationResponse: (details) {},
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'task_flow_v1',
      'Task Reminders',
      description: 'Important task alerts',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
      await androidPlugin.requestNotificationsPermission();

      final exactGranted = await androidPlugin.requestExactAlarmsPermission();
      _canScheduleExactAlarms = exactGranted ?? true;
    }
  }

  bool get canScheduleExactAlarms => _canScheduleExactAlarms;

  Future<void> openExactAlarmSettings() async {
    const intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  Future<void> scheduleNotification(TodoEntity todo) async {
    // CRITICAL: Ensure we are using a TZDateTime in the future
    // We add a 2-second offset to the 'now' comparison to avoid racing conditions
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime.from(todo.dateTime, tz.local);

    if (scheduledDate.isBefore(now)) {
      // If close to past, push it slightly into the future to ensure system accepts it
      scheduledDate = now.add(const Duration(seconds: 5));
    }

    // Try multiple modes if one fails? No, let's use the most compatible one.
    // inexactAllowWhileIdle is the most compatible mode as it requires 0 special permissions.
    // We will try exact if possible, otherwise inexact.
    final scheduleMode = _canScheduleExactAlarms
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    await _notificationsPlugin.zonedSchedule(
      id: todo.notificationId,
      title: 'TaskFlow: ${todo.title}',
      body: todo.description.isNotEmpty
          ? todo.description
          : 'Time to complete your task!',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_flow_v1',
          'Task Reminders',
          importance: Importance.max,
          priority: Priority.max,
          ticker: 'Task Reminder',
          fullScreenIntent: true,
          category: AndroidNotificationCategory.reminder,
          visibility: NotificationVisibility.public,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: scheduleMode,
    );
  }

  Future<void> showInstantNotification(String title, String body) async {
    await _notificationsPlugin.show(
      id: 999,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_flow_v1',
          'Task Reminders',
          importance: Importance.max,
          priority: Priority.max,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }
}
