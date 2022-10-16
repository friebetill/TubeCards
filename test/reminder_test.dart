import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';
import 'package:tubecards/data/models/reminder.dart';
import 'package:tubecards/modules/reminder/weekday.dart';

void main() {
  test('parses json to weekly reminder object', () {
    const jsonString = '''
{
  "enabled":true,
  "hour":12,
  "minute":0,
  "Monday":true,
  "Tuesday":true,
  "Wednesday":true,
  "Thursday":true,
  "Friday":true,
  "Saturday":true,
  "Sunday":true
}
''';

    final reminder = Reminder.fromJson(jsonString);
    expect(reminder.enabled, isTrue);
    expect(reminder.weekdayStatus[Weekday.monday], isTrue);
    expect(reminder.weekdayStatus[Weekday.tuesday], isTrue);
    expect(reminder.weekdayStatus[Weekday.wednesday], isTrue);
    expect(reminder.weekdayStatus[Weekday.thursday], isTrue);
    expect(reminder.weekdayStatus[Weekday.friday], isTrue);
    expect(reminder.weekdayStatus[Weekday.saturday], isTrue);
    expect(reminder.weekdayStatus[Weekday.sunday], isTrue);
    expect(reminder.hour, equals(12));
    expect(reminder.minute, equals(0));
  });

  test('parses reminder object to json', () {
    final reminder = Reminder(
      id: 1,
      enabled: true,
      weekdayStatus: BuiltMap({
        Weekday.monday: true,
        Weekday.tuesday: true,
        Weekday.wednesday: true,
        Weekday.thursday: true,
        Weekday.friday: true,
        Weekday.saturday: true,
        Weekday.sunday: true,
      }),
      timeOfDay: const TimeOfDay(hour: 12, minute: 0),
    );

    expect(
      reminder.toJson(),
      equals(
        '''{"id":1,"enabled":true,"hour":12,"minute":0,"Monday":true,"Tuesday":true,"Wednesday":true,"Thursday":true,"Friday":true,"Saturday":true,"Sunday":true}''',
      ),
    );
  });
}
