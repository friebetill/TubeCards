import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

import '../../data/models/reminder.dart';
import '../../i18n/i18n.dart';

/// The channel's id. Required for Android 8.0+.
const String _channelId = 'ReminderChannelId';

/// The channel's name of the local notifcation. Required for Android 8.0+.
const String _channelName = 'Reminder';

/// The channel's description. Required for Android 8.0.
const String _channelDescription = 'Receive your learn reminders.';

/// Maximum number of notifications that will be scheduled on the OS.
///
/// Such a limit is needed since we have to specify exact points in time when
/// a notification should be scheduled instead of repeating formulas like
/// every Wednesday at 3pm.
///
/// On iOS there exists a specific limit of 64 scheduled notifications, see https://bit.ly/38KunCs.
const int _maxScheduledNotificationCount = 64;

/// Allows management of system-level notifications.
@singleton
class SystemNotificationManager {
  /// Creates an instance of [SystemNotificationManager].
  SystemNotificationManager()
      : _i18nFuture = S.load(ui.window.locale),
        _platformChannelSpecifics = _getPlatformChannelSpecifics(),
        _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// The current ID that is used as when a notification is scheduled.
  var _currentNotificationId = 0;

  /// Allows the i18n of notifications, member variable for testing.
  final Future<S> _i18nFuture;

  /// Allows to display a local notification, member variable for testing.
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin;

  final NotificationDetails _platformChannelSpecifics;

  bool _isInitialized = false;

  /// Initialize the notifications.
  ///
  /// Should only be done once.
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    await _localNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('app_icon'),
        iOS: DarwinInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
        ),
        macOS: DarwinInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
        ),
      ),
    );
    _isInitialized = true;
  }

  static NotificationDetails _getPlatformChannelSpecifics() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );
  }

  /// Synchronizes all user set reminders with the system notifications.
  ///
  /// This function is idempotent.
  Future<void> rescheduleNotifications(List<Reminder> reminders) async {
    await _localNotificationsPlugin.cancelAll();

    if (reminders.isEmpty) {
      return;
    }

    initializeTimeZones();
    final currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    final location = getLocation(currentTimeZone);
    setLocalLocation(location);

    _currentNotificationId = 0;
    final timeBasedReminders = reminders.where((r) => r.enabled!);
    // We optimistically ceil the number of notifications per reminder so that
    // we may overshoot the maximum number of notifications we can schedule in
    // order to still get the maximum amount of reminders scheduled.
    final notificationCountPerReminder =
        (_maxScheduledNotificationCount / reminders.length).ceil();
    for (final r in timeBasedReminders) {
      await _scheduleForTimeBasedReminder(
        r,
        notificationCountPerReminder,
        location,
      );
    }
  }

  /// Schedules [notificationsCount] notifications for the given time-based
  /// [reminder].
  ///
  /// Since time-based reminders can be potentially scheduled indefinitely
  /// into the future, the [notificationsCount] ensures that there is a limit
  /// to the number of dates we schedule the reminder.
  Future<void> _scheduleForTimeBasedReminder(
    Reminder reminder,
    int notificationsCount,
    Location location,
  ) async {
    if (notificationsCount == 0) {
      return;
    }

    final formattedTime = reminder.time;
    final notificationTimes = reminder
        .getNextMatchingDateTimesStartingAt(TZDateTime.now(location))
        .take(notificationsCount);

    for (final time in notificationTimes) {
      await _scheduleNotification(time, formattedTime);
    }
  }

  // /// Schedules an operating system notification at the [scheduledTime].
  Future<void> _scheduleNotification(
    TZDateTime scheduledTime,
    String formattedTime,
  ) async {
    return _localNotificationsPlugin.zonedSchedule(
      _currentNotificationId++,
      (await _i18nFuture).notificationTitleWithTime(formattedTime),
      await _buildSubtitle(),
      scheduledTime,
      _platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Builds the subtitle of the notification.
  ///
  /// The subtitle is usually displayed below the title and in an unobtrusive
  /// color.
  Future<String> _buildSubtitle() async {
    final i18n = await _i18nFuture;
    final subtitles = [
      i18n.notificationSubtitle01,
      i18n.notificationSubtitle02,
      i18n.notificationSubtitle03,
      i18n.notificationSubtitle04,
      i18n.notificationSubtitle05,
      i18n.notificationSubtitle06,
      i18n.notificationSubtitle07,
      i18n.notificationSubtitle08,
      i18n.notificationSubtitle09,
      i18n.notificationSubtitle10,
      i18n.notificationSubtitle11,
      i18n.notificationSubtitle12,
      i18n.notificationSubtitle13,
      i18n.notificationSubtitle14,
      i18n.notificationSubtitle15,
      i18n.notificationSubtitle16,
      i18n.notificationSubtitle17,
      i18n.notificationSubtitle18,
    ];

    return subtitles[Random().nextInt(subtitles.length)];
  }
}
