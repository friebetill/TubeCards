import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../i18n/i18n.dart';

/// The class stores a day of the week.
@immutable
class Weekday {
  const Weekday._(this.value);

  /// Returns a weekday based on the given string weekday.
  factory Weekday.fromString(String str) {
    var value = 0;
    str = str.toLowerCase();
    switch (str) {
      case 'monday':
        value = 1;
        break;
      case 'tuesday':
        value = 2;
        break;
      case 'wednesday':
        value = 3;
        break;
      case 'thursday':
        value = 4;
        break;
      case 'friday':
        value = 5;
        break;
      case 'saturday':
        value = 6;
        break;
      case 'sunday':
        value = 7;
        break;
      default:
        throw ArgumentError('Given string is not a valid weekday.');
    }

    return Weekday._(value);
  }

  /// Returns a weekday based on the passed int weekday.
  ///
  /// The week starts at Monday with 1 and ends on Sunday with 7.
  factory Weekday.fromInt(int value) {
    if (value <= 0 || value > 7) {
      throw ArgumentError('Given value must be in the range from 1 and 7.');
    }

    return Weekday._(value);
  }

  /// Returns the weekday Monday.
  static const Weekday monday = Weekday._(1);

  /// Returns the weekday Tuesday.
  static const Weekday tuesday = Weekday._(2);

  /// Returns the weekday Wednesday.
  static const Weekday wednesday = Weekday._(3);

  /// Returns the weekday Thursday.
  static const Weekday thursday = Weekday._(4);

  /// Returns the weekday Friday.
  static const Weekday friday = Weekday._(5);

  /// Returns the weekday Saturday.
  static const Weekday saturday = Weekday._(6);

  /// Returns the weekday Sunday.
  static const Weekday sunday = Weekday._(7);

  /// Day of the week, where Monday has the value 1.
  ///
  /// In accordance with ISO 8601 a week starts with Monday.
  final int value;

  @override
  String toString() {
    switch (value) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  /// Returns the name of the day depending on the language of the system.
  String toLocaleString(BuildContext context) {
    switch (value) {
      case 1:
        return S.of(context).monday;
      case 2:
        return S.of(context).tuesday;
      case 3:
        return S.of(context).wednesday;
      case 4:
        return S.of(context).thursday;
      case 5:
        return S.of(context).friday;
      case 6:
        return S.of(context).saturday;
      case 7:
        return S.of(context).sunday;
      default:
        return '';
    }
  }

  /// Converts a given weekday to a single character.
  String toChar(BuildContext context) {
    return toLocaleString(context)[0];
  }

  /// Returns the first three letters of the weekday.
  String abbreviation(BuildContext context) {
    return toLocaleString(context).substring(0, 2);
  }

  /// Returns the day representation of the FlutterNotificationsPlugin where
  /// Sunday is represented as a 1.
  Day toNotificationDay() {
    return Day((value % 7) + 1);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Weekday &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
