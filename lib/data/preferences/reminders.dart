import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import '../../modules/reminder/system_notification_manager.dart';
import '../models/reminder.dart';
import 'utils/secure_json_preference_adapter.dart';

const String _remindersKey = 'reminders';
const List<Reminder> _remindersDefaultValue = [];

/// Persistable representation of all reminders of the current user.
@singleton
class Reminders {
  Reminders(StreamingSharedPreferences preferences, this._notificationManager)
      : _reminders = preferences.getCustomValue<List<Reminder>>(
          _remindersKey,
          defaultValue: [],
          adapter: SecureJsonPreferenceAdapter(
            serializer: (r) => r.map((r) => r.toJson()).toList(),
            deserializer: (r) => (r as List<dynamic>)
                .map((r) => Reminder.fromJson(r as String))
                .toList(),
            onTypeError: (e, s) {
              Logger((Reminders).toString()).severe(
                'TypeError during deserialization of Reminders',
                e,
                s,
              );

              final encodedDefaultValue = jsonEncode(_remindersDefaultValue);
              preferences.setString(_remindersKey, encodedDefaultValue);

              return _remindersDefaultValue;
            },
          ),
        );

  /// Manager for system-level notifications.
  final SystemNotificationManager _notificationManager;

  final Preference<List<Reminder>> _reminders;

  /// Recurring reminders of the current user.
  Stream<List<Reminder>> get() => _reminders;

  void upsert(Reminder reminder) {
    final reminders = _reminders.getValue()
      ..removeWhere((r) => r.id == reminder.id)
      ..add(reminder);
    _reminders.setValue(reminders);
    _notificationManager.rescheduleNotifications(reminders);
  }

  void delete(Reminder reminder) {
    final reminders = _reminders.getValue()
      ..removeWhere((r) => r.id == reminder.id);
    _reminders.setValue(reminders);
    _notificationManager.rescheduleNotifications(reminders);
  }

  Future<void> clear() async {
    await _reminders.setValue(_reminders.defaultValue);
    await _notificationManager.rescheduleNotifications(_reminders.defaultValue);
  }
}
