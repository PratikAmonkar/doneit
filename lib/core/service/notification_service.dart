import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

// TODO:: Create or Update Proguard-rules.pro[android/app] and keep.xml[android/app/src/main/res/raw] this required while building release app [reason: R8]

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidInitializationSettings _androidInitializationSettings =
      const AndroidInitializationSettings("app_logo");

  void initialiseNotifications() async {
    InitializationSettings initializationSettings = InitializationSettings(
      android: _androidInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification({
    required String title,
    required String body,
    required int notificationId,
    required String channelId,
    required String category,
    String iconName = "app_logo",
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          channelId = channelId,
          category = category,
          importance: importance,
          priority: priority,
          icon: iconName,
        );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
    );
  }

  void scheduleNotification({
    required String title,
    required String body,
    required int notificationId,
    required String channelId,
    required String category,
    required DateTime scheduleDateTime,
    String iconName = "app_logo",
    Importance importance = Importance.high,
    Priority priority = Priority.defaultPriority,
  }) async {
    final time = tz.TZDateTime.from(scheduleDateTime, tz.local);

    final now = tz.TZDateTime.now(tz.local);

    if (time.isBefore(now)) {
      return;
    }

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          channelId = channelId,
          category = category,
          importance: importance,
          priority: priority,
          icon: iconName,
        );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      time,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      /*      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,*/
    );
  }

  Future<void> cancelNotification(int notificationId) async {
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<bool> isNotificationScheduled(int notificationId) async {
    final List<PendingNotificationRequest> pending =
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();

    return pending.any((notification) => notification.id == notificationId);
  }
}
