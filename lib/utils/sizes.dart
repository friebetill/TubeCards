import 'dart:io';

/// The minimum height of the window.
const minimumScreenHeight = 640.0;

/// The minimum width of the window.
const minimumScreenWidth = 360.0;

/// The height of the title bar depending on the OS.
final titleBarHeight = Platform.isWindows
    ? 26
    : Platform.isMacOS
        ? 28
        : Platform.isLinux
            ? 26
            : 0;

/// The height of the system bar depending on the OS.
final systemBarHeight = Platform.isAndroid || Platform.isIOS ? 28 : 0;

/// The height of the app bar.
const appBarHeight = 56;

/// The minimum height of a fully extended widget.
///
/// On some OSs, there is a title bar which has to be subtracted from the
/// [minimumScreenHeight].
final minimumWidgetHeight = minimumScreenHeight - titleBarHeight;
