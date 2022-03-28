import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart';
import 'package:uuid/uuid.dart';

import '../../modules/reminder/weekday.dart';

part 'reminder.g.dart';

/// The class stores a reminder for the user which is repeated weekly.
///
/// The weekly reminder always takes place at the same time, but can take
/// place on several days.
@CopyWith()
@immutable
class Reminder {
  /// Returns an instance of [Reminder].
  Reminder({
    required this.weekdayStatus,
    required this.timeOfDay,
    required this.enabled,
    int? id,
  }) : id = id ?? const Uuid().v4().hashCode;

  factory Reminder.initial() {
    return Reminder(
      enabled: true,
      timeOfDay: TimeOfDay.now(),
      weekdayStatus: BuiltMap({
        Weekday.monday: true,
        Weekday.tuesday: true,
        Weekday.wednesday: true,
        Weekday.thursday: true,
        Weekday.friday: true,
        Weekday.saturday: true,
        Weekday.sunday: true,
      }),
    );
  }

  /// Converts the Json String into a Reminder object.
  factory Reminder.fromJson(String jsonString) {
    final parsed = jsonDecode(jsonString) as Map<String, dynamic>;

    return Reminder(
      id: parsed['id'] as int?,
      enabled: parsed['enabled'] as bool?,
      weekdayStatus: BuiltMap({
        Weekday.monday: parsed['Monday'] as bool?,
        Weekday.tuesday: parsed['Tuesday'] as bool?,
        Weekday.wednesday: parsed['Wednesday'] as bool?,
        Weekday.thursday: parsed['Thursday'] as bool?,
        Weekday.friday: parsed['Friday'] as bool?,
        Weekday.saturday: parsed['Saturday'] as bool?,
        Weekday.sunday: parsed['Sunday'] as bool?,
      }),
      timeOfDay: TimeOfDay(
        hour: parsed['hour'] as int,
        minute: parsed['minute'] as int,
      ),
    );
  }

  /// Unique ID of the weekly reminder.
  final int id;

  /// Whether the reminder will fire at the specified weekday time.
  final bool? enabled;

  /// Day of the week.
  final BuiltMap<Weekday, bool> weekdayStatus;

  /// Time in the day, specifying hour and minute.
  final TimeOfDay timeOfDay;

  @override
  bool operator ==(Object other) => other is Reminder && id == other.id;

  @override
  int get hashCode => id;

  /// Converts the Reminder object into a json string.
  String toJson() {
    final map = {
      'id': id,
      'enabled': enabled,
      'hour': timeOfDay.hour,
      'minute': timeOfDay.minute,
      Weekday.monday.toString(): weekdayStatus[Weekday.monday],
      Weekday.tuesday.toString(): weekdayStatus[Weekday.tuesday],
      Weekday.wednesday.toString(): weekdayStatus[Weekday.wednesday],
      Weekday.thursday.toString(): weekdayStatus[Weekday.thursday],
      Weekday.friday.toString(): weekdayStatus[Weekday.friday],
      Weekday.saturday.toString(): weekdayStatus[Weekday.saturday],
      Weekday.sunday.toString(): weekdayStatus[Weekday.sunday],
    };

    return jsonEncode(map);
  }

  /// Returns the configured hour of the weekly reminder.
  int get hour {
    return timeOfDay.hour;
  }

  /// Returns the configured minute of the weekly reminder.
  int get minute {
    return timeOfDay.minute;
  }

  /// Returns the time of the reminder as a formatted string, e.g. '12:00'.
  String get time {
    return '${_twoDigits(timeOfDay.hour)}:${_twoDigits(timeOfDay.minute)}';
  }

  String _twoDigits(int val) {
    return val.toString().padLeft(2, '0');
  }

  Iterable<TZDateTime> getNextMatchingDateTimesStartingAt(
    TZDateTime from,
  ) sync* {
    if (!weekdayStatus.containsValue(true)) {
      // No matching times since the reminder is disabled for each weekday.
      return;
    }

    var nextMatchingDateTime = _getNextMatchingDateTimeStartingAt(from);
    while (true) {
      yield nextMatchingDateTime;
      nextMatchingDateTime =
          _getNextMatchingDateTimeStartingAt(nextMatchingDateTime);
    }
  }

  /// Returns the next time where the time-based reminder would be triggered
  /// assuming the card threshold is hit.
  ///
  /// The reminder is triggered at a specific DateTime in case the weekday,
  /// hour, and minute of the DateTime match with the values of the reminder.
  ///
  /// In case the [from] time is already matching, the next matching time after
  /// [from] is returned.
  TZDateTime _getNextMatchingDateTimeStartingAt(TZDateTime from) {
    final fromTimeWeekday = Weekday.fromInt(from.weekday);

    // Check whether the next matching time is later on the given day.
    if (weekdayStatus[fromTimeWeekday]! &&
        (from.hour < timeOfDay.hour ||
            (from.hour == timeOfDay.hour && from.minute < timeOfDay.minute))) {
      return TZDateTime.local(
        from.year,
        from.month,
        from.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );
    }

    var nextDate = from.add(const Duration(days: 1));
    while (!weekdayStatus[Weekday.fromInt(nextDate.weekday)]!) {
      nextDate = nextDate.add(const Duration(days: 1));
    }

    return TZDateTime.local(
      nextDate.year,
      nextDate.month,
      nextDate.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
  }
}
