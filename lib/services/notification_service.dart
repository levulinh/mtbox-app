import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _channelId = 'mtbox_daily_reminders';
  static const _channelName = 'Daily Reminders';
  static const _channelDesc = 'Daily check-in reminders for your campaigns';

  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  static void Function(String campaignId)? onNotificationTap;

  static void _onNotificationTap(NotificationResponse response) {
    final campaignId = response.payload;
    if (campaignId != null && onNotificationTap != null) {
      onNotificationTap!(campaignId);
    }
  }

  static Future<void> requestPermissions() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
      return;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Schedules a daily notification at [time] for [campaignId] / [campaignName].
  /// [time] is "HH:mm" in 24h format.
  static Future<void> scheduleDaily({
    required String campaignId,
    required String campaignName,
    required String time,
  }) async {
    await initialize();
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 9;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      actions: [
        AndroidNotificationAction('check_in', 'Check In'),
        AndroidNotificationAction('dismiss', 'Dismiss'),
      ],
    );
    const iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'daily_reminder',
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final notifId = campaignId.hashCode.abs() % 2147483647;
    await _plugin.zonedSchedule(
      id: notifId,
      title: 'Time to check in!',
      body: "Don't break your streak on $campaignName. Tap to check in.",
      scheduledDate: scheduled,
      notificationDetails: details,
      payload: campaignId,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Cancels the daily notification for [campaignId].
  static Future<void> cancel(String campaignId) async {
    await initialize();
    final notifId = campaignId.hashCode.abs() % 2147483647;
    await _plugin.cancel(id: notifId);
  }
}
