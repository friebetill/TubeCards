class UserException implements Exception {
  UserException(this.userMessage);

  /// Message that can be shown to the user.
  final String userMessage;
}
