import 'dart:io';

/// Allows to test [SocketException] more easily for certain errors.
extension EasierTestable on SocketException {
  // For more error codes https://bit.ly/3AUO09I
  static const int argListTooLong = 7; // Thrown when failed to lookup host
  static const int execFormatError = 8; // Thrown when failed to lookup host
  static const int noDataAvailable = 61;
  static const int networkIsUnreachable = 101;
  static const int connectionTimedOut = 110;
  static const int connectionRefused = 111;

  /// True if the reason for the exception was that there was no internet.
  bool get isNoInternet {
    final errorCode = osError?.errorCode;

    return errorCode == networkIsUnreachable ||
        errorCode == argListTooLong ||
        errorCode == execFormatError;
  }

  /// True if the reason for the exception was that the server was offline.
  bool get isServerOffline {
    final errorCode = osError?.errorCode;

    return errorCode == connectionRefused ||
        errorCode == connectionTimedOut ||
        errorCode == noDataAvailable;
  }
}
