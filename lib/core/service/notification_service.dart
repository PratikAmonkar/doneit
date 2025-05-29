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
    required String scheduleDateTime,
    String iconName = "logo_no_title",
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    final scheduledTime = tz.TZDateTime.from(
      // CommonUtils().getDateTimeFromIso(date: scheduleDateTime),
      DateTime.now().add(const Duration(minutes: 10)),
      tz.local,
    );
    final now = tz.TZDateTime.now(tz.local);

    if (scheduledTime.isBefore(now)) {
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
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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
}
