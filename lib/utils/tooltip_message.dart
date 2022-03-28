import 'dart:io';

import 'package:flutter/widgets.dart';

import '../../../../i18n/i18n.dart';

/// Builds a tooltip message with if necessary a hint to a shortcut.
///
/// Depending on the platform, the message is displayed with the shortcut in
/// brackets. If the respective shortcut is null, only the message is displayed.
///
/// An example how to use the tooltip:
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return Tooltip(
///     message: buildTooltipMessage(
///       windowsShortcut: 'This is a tooltip',
///       macosShortcut: 'Ctrl + t',
///       linuxShortcut: '⌘ + t',
///       linux: 'Ctrl + t',
///     ),
///     child: Button(),
///   );
/// }
String buildTooltipMessage({
  required String message,
  String? windowsShortcut,
  String? macosShortcut,
  String? linuxShortcut,
}) {
  String formatter(String? message, String? shortcut) {
    return "${message != null ? '$message ($shortcut)' : shortcut}";
  }

  if (Platform.isWindows && windowsShortcut != null) {
    return formatter(message, windowsShortcut);
  } else if (Platform.isMacOS && macosShortcut != null) {
    return formatter(message, macosShortcut);
  } else if (Platform.isLinux && linuxShortcut != null) {
    return formatter(message, linuxShortcut);
  } else {
    return message;
  }
}

String backTooltip(BuildContext context) {
  return buildTooltipMessage(
    message: S.of(context).back,
    windowsShortcut: 'Esc',
    macosShortcut: 'Esc',
    linuxShortcut: 'Esc',
  );
}

String closeTooltip(BuildContext context) {
  return buildTooltipMessage(
    message: S.of(context).close,
    windowsShortcut: 'Esc',
    macosShortcut: 'Esc',
    linuxShortcut: 'Esc',
  );
}

String saveTooltip(BuildContext context) {
  return buildTooltipMessage(
    message: S.of(context).saveChanges,
    windowsShortcut: 'Ctrl + Enter',
    macosShortcut: '⌘ + Enter',
    linuxShortcut: 'Ctrl + Enter',
  );
}
