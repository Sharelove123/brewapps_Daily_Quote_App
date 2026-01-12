import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'supabase_quote_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      print('Could not invoke local timezone: $e');
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Handle notification tap
      },
    );

    _isInitialized = true;
  }

  Future<void> requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleDailyQuote(TimeOfDay time) async {
    await initialize();

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    print('Scheduling notification for: $scheduledDate (TZ: ${tz.local.name})');

    // Check if exact alarms are allowed (Android 12+)
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    bool canScheduleExact = true;
    if (androidPlugin != null) {
      canScheduleExact =
          await androidPlugin.canScheduleExactNotifications() ?? false;

      if (!canScheduleExact) {
        // Request exact alarm permission - opens system settings
        await androidPlugin.requestExactAlarmsPermission();
        // Recheck
        canScheduleExact =
            await androidPlugin.canScheduleExactNotifications() ?? false;
      }
    }

    final scheduleMode = canScheduleExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    print(
      'Using schedule mode: $scheduleMode (canScheduleExact: $canScheduleExact)',
    );

    // Fetch current quote for notification content
    String quoteText = 'Time for your daily dose of wisdom!';
    String quoteAuthor = '';
    try {
      final quote = await SupabaseQuoteService().fetchQuoteOfTheDay();
      if (quote != null) {
        quoteText = '"${quote.text}"';
        quoteAuthor = '— ${quote.author}';
      }
    } catch (e) {
      print('Could not fetch quote for notification: $e');
    }

    await _notificationsPlugin.zonedSchedule(
      0,
      '✨ Daily Quote',
      '$quoteText $quoteAuthor',
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_quotes',
          'Daily Quotes',
          channelDescription: 'Daily quote reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: scheduleMode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // Also schedule a test notification for 10 seconds from now
    await scheduleTestIn10Seconds();

    // Show immediate confirmation notification
    await showNow(
      'Notification Scheduled',
      'Test notification coming in 10 seconds + daily at ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
    );
  }

  /// Test method - schedules notification for 10 seconds from now
  Future<void> scheduleTestIn10Seconds() async {
    await initialize();

    final scheduledTime = tz.TZDateTime.now(
      tz.local,
    ).add(const Duration(seconds: 10));
    print('TEST: Scheduling for $scheduledTime');

    await _notificationsPlugin.zonedSchedule(
      99, // Different ID
      'Test Notification',
      'This should appear 10 seconds after enabling!',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_quotes',
          'Daily Quotes',
          channelDescription: 'Test notification',
          importance: Importance.max,
          priority: Priority.max,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Show an immediate notification for testing
  Future<void> showNow(String title, String body) async {
    await initialize();

    await _notificationsPlugin.show(
      1, // Different ID from scheduled one
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_quotes',
          'Daily Quotes',
          channelDescription: 'Daily quote reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelDailyQuote() async {
    await _notificationsPlugin.cancel(0);
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
