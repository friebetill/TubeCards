import 'package:flutter/material.dart';

import '../i18n/i18n.dart';

extension Formatted on Duration {
  /// Returns the count in the most appropriate time unit.
  ///
  /// For example, if the duration is 64 days, it will return 2 for two months.
  int intCount() {
    if (inDays ~/ 360 <= -1) {
      return inDays ~/ 360;
    } else if (inDays ~/ 30 <= -1) {
      return inDays ~/ 30;
    } else if (inDays <= -1) {
      return inDays;
    } else if (inHours <= -1) {
      return inHours;
    } else if (inMinutes <= -1) {
      return inMinutes;
    } else if (inSeconds < 60) {
      return inSeconds;
    } else if (inMinutes < 60) {
      return inMinutes;
    } else if (inHours < 24) {
      return inHours;
    } else if (inDays < 31) {
      return inDays;
    } else if (inDays ~/ 30 < 12) {
      return inDays ~/ 30;
    } else if (inDays ~/ 360 >= 1) {
      return inDays ~/ 360;
    }

    return 0;
  }

  /// Returns the count in the most appropriate time unit.
  ///
  /// For example, if the duration is 64 days, it will return "2" for two
  /// months.
  String count() {
    if (inSeconds < 60) {
      return inSeconds.toString();
    } else if (inMinutes < 60) {
      return inMinutes.toString();
    } else if (inHours < 24) {
      return inHours.toString();
    } else if (inDays < 31) {
      return inDays.toString();
    } else if (inDays ~/ 30 < 12) {
      return (inDays ~/ 30).toString();
    } else if (inDays ~/ 360 >= 1) {
      return (inDays ~/ 360).toString();
    }

    return '';
  }

  /// Returns the count with the most appropriate time unit.
  ///
  /// For example, if the duration is 64 days, it will return "2 month" for two
  /// months.
  String countWithUnit(BuildContext context) {
    if (inDays ~/ 360 <= -1) {
      return S.of(context).years(inDays ~/ 360);
    } else if (inDays ~/ 30 <= -1) {
      return S.of(context).months(inDays ~/ 30);
    } else if (inDays <= -1) {
      return S.of(context).days(inDays);
    } else if (inHours <= -1) {
      return S.of(context).hours(inHours);
    } else if (inMinutes <= -1) {
      return S.of(context).minutes(inMinutes);
    } else if (inSeconds < 60) {
      return S.of(context).seconds(inSeconds);
    } else if (inMinutes < 60) {
      return S.of(context).minutes(inMinutes);
    } else if (inHours < 24) {
      return S.of(context).hours(inHours);
    } else if (inDays < 31) {
      return S.of(context).days(inDays);
    } else if (inDays ~/ 30 < 12) {
      return S.of(context).months(inDays ~/ 30);
    } else if (inDays ~/ 360 >= 1) {
      return S.of(context).years(inDays ~/ 360);
    }

    return '';
  }

  /// Returns the count with the most appropriate and abbreviated time unit.
  ///
  /// For example, if the duration is 64 days, it will return "2m" for two
  /// months.
  String countWithShortedUnit(BuildContext context) {
    if (inDays ~/ 360 <= -1) {
      return '${inDays ~/ 360}${_firstCharacter(S.of(context).year)}';
    } else if (inDays ~/ 30 <= -1) {
      return '${inDays ~/ 30}${_firstCharacter(S.of(context).month)}';
    } else if (inDays <= -1) {
      return '$inDays${_firstCharacter(S.of(context).day)}';
    } else if (inHours <= -1) {
      return '$inHours${_firstCharacter(S.of(context).hour)}';
    } else if (inMinutes <= -1) {
      return '$inMinutes${_firstCharacter(S.of(context).minute)}';
    } else if (inSeconds < 60) {
      return '$inSeconds${_firstCharacter(S.of(context).second)}';
    } else if (inMinutes < 60) {
      return '$inMinutes${_firstCharacter(S.of(context).minute)}';
    } else if (inHours < 24) {
      return '$inHours${_firstCharacter(S.of(context).hour)}';
    } else if (inDays < 31) {
      return '$inDays${_firstCharacter(S.of(context).day)}';
    } else if (inDays ~/ 30 < 12) {
      return '${inDays ~/ 30}${_firstCharacter(S.of(context).month)}';
    } else if (inDays ~/ 360 >= 1) {
      return '${inDays ~/ 360}${_firstCharacter(S.of(context).year)}';
    }

    return '';
  }

  /// Returns the abbreviated unit, e.g. 's' for seconds.
  String shortedUnit(BuildContext context) {
    if (inDays ~/ 360 <= -1) {
      return _firstCharacter(S.of(context).year);
    } else if (inDays ~/ 30 <= -1) {
      return _firstCharacter(S.of(context).month);
    } else if (inDays <= -1) {
      return _firstCharacter(S.of(context).day);
    } else if (inHours <= -1) {
      return _firstCharacter(S.of(context).hour);
    } else if (inMinutes <= -1) {
      return _firstCharacter(S.of(context).minute);
    } else if (inSeconds < 60) {
      return _firstCharacter(S.of(context).second);
    } else if (inMinutes < 60) {
      return _firstCharacter(S.of(context).minute);
    } else if (inHours < 24) {
      return _firstCharacter(S.of(context).hour);
    } else if (inDays < 31) {
      return _firstCharacter(S.of(context).day);
    } else if (inDays ~/ 30 < 12) {
      return _firstCharacter(S.of(context).month);
    } else if (inDays ~/ 360 >= 1) {
      return _firstCharacter(S.of(context).year);
    }

    return '';
  }

  String _firstCharacter(String unit) => unit.toLowerCase().substring(0, 1);

  /// Formats the duration to a human readable string with unit and ago,
  /// e.g. 5 minutes ago.
  String countWithUnitAndAgo(BuildContext context) {
    if (inSeconds.abs() < 60) {
      return S.of(context).aFewSecondsAgo;
    } else if (inMinutes < 60) {
      return S.of(context).minutesAgo(inMinutes);
    } else if (inHours < 24) {
      return S.of(context).hoursAgo(inHours);
    } else if (inDays < 31) {
      return S.of(context).daysAgo(inDays);
    } else if (inDays ~/ 30 < 12) {
      return S.of(context).monthsAgo(inDays ~/ 30);
    } else if (inDays ~/ 360 >= 1) {
      return S.of(context).yearsAgo(inDays ~/ 360);
    }

    return '';
  }
}
