import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'config.dart';

final _logDateFormat = DateFormat('MM-dd HH:mm:ss.SSS', 'en_US');

Future<void> setupLogging() async {
  Logger.root.level = Level.FINEST;
  Logger.root.onRecord.listen((record) {
    final message = _createLogFromRecord(record);

    if (isProduction) {
      if (record.level == Level.SEVERE) {
        Sentry.captureException(
          record.error,
          stackTrace: record.stackTrace,
          hint: message,
        );
      } else {
        Sentry.captureMessage(message);
      }
      // Use debugPrint so we don't lose logs on Android.
      debugPrint(message);
    } else {
      // ignore: avoid_print
      print(message);
    }
  });
}

String _createLogFromRecord(LogRecord record) {
  final timestamp = _logDateFormat.format(record.time);

  // Combine the log level, log time, and message on one line.
  // Then add the error and stack trace on new lines, if they exist.
  //
  // Every line is prefixed with the app name from [prefixLines].
  return prefixLines(
    [
      '${record.level.name}: $timestamp: ${record.message}',
      record.error,
      record.stackTrace,
    ].where((line) => line != null).join('\n'),
    '[${record.loggerName}] ',
  );
}

/// Prefixes all lines in [message] with [prefix].
///
/// This lets our logs stand apart from native/other app logs.
String prefixLines(String message, String prefix) {
  if (message.isEmpty) {
    return prefix;
  }

  return LineSplitter.split(message).map((line) => '$prefix$line').join('\n');
}
