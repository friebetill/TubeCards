import 'dart:async';

import 'package:ferry/ferry.dart';
import 'package:injectable/injectable.dart';

import '../../graphql/operation_exception.dart';
import '../../services/tubecards/user_service.dart';
import '../models/auth_result.dart';
import '../models/average_learning_state.dart';
import '../models/user.dart';

/// Manages data handling for users.
///
/// The repository tries to retrieve fresh data from the server if possible. In
/// case there is a network issue, data from the device is used instead.
///
/// The local device data is always kept up-to-date with any new fresh data from
/// the server.
@singleton
class UserRepository {
  UserRepository(this._service);

  final UserService _service;

  /// Returns the currently logged in user, also known as viewer.
  ///
  /// Returns null if the user is not logged in.
  Stream<User?> viewer({FetchPolicy? fetchPolicy}) {
    return _service.viewer(fetchPolicy: fetchPolicy);
  }

  Stream<AverageLearningState> getLearningState({FetchPolicy? fetchPolicy}) {
    return _service.learningState(fetchPolicy: fetchPolicy);
  }

  /// Updates the currently logged in user with the given parameters.
  ///
  /// Throws an [OperationException] or an [TimeoutException] if it was not
  /// successful.
  Future<User> updateCurrentUser({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    bool? isAnonymous,
  }) =>
      _service.updateUser(
        firstName,
        lastName,
        email,
        password,
        isAnonymous: isAnonymous,
      );

  /// Performs a log in operation and returns the [AuthResult].
  ///
  /// In case it is a [dryRun], the underlying offline store will not be updated
  /// with the obtained log in data and the obtained auth token is not used for
  /// subsequent API requests.
  ///
  /// Throws an [OperationException] or an [TimeoutException] if it was not
  /// successful.
  Future<AuthResult> logIn({
    required String email,
    required String password,
    required bool dryRun,
  }) async {
    final authResult = await _service.logIn(email, password);

    if (!dryRun) {
      await _service.setAuthToken(authResult.token!);
    }

    return authResult;
  }

  /// Signs up a new user with the given data and uses the created user as the
  /// current user.
  ///
  /// In case of success, the user will be locally logged in and the user data
  /// is also stored.
  ///
  /// Throws an [OperationException] or an [TimeoutException] if it was not
  /// successful.
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final authResult =
        await _service.signUp(email, password, firstName, lastName);

    await _service.setAuthToken(authResult.token!);

    return authResult;
  }

  /// Creates an anonymous user and uses the created user as the current user.
  ///
  /// In case of success, the user will be locally logged in and the user data
  /// is also stored.
  ///
  /// Throws an [OperationException] or an [TimeoutException] if it was not
  /// successful.
  Future<AuthResult> createAnonymousUser() async {
    final authResult = await _service.createAnonymousUser();

    await _service.setAuthToken(authResult.token!);

    return authResult;
  }

  /// Sends an email at [emailAddress] with instructions to reset the password.
  Future<void> triggerPasswordReset(String emailAddress) {
    return _service.triggerPasswordReset(emailAddress);
  }

  /// Removes all stored user-data as well as the authentication token.
  Future<void> clear() async => _service.clear();

  /// Writes the API authentication token to local storage.
  Future<void> setAuthToken(String authToken) {
    return _service.setAuthToken(authToken);
  }

  /// Permanently deletes the currently logged in user.
  ///
  /// This removes the user from the server. In case of success, all local user
  /// data is removed as well.
  ///
  /// Throws an [OperationException] if the user was not successfully deleted.
  Future<void> deleteCurrentUser() async {
    await _service.deleteUser();
    await _service.clear();
  }

  Future<void> sendFeedback(String feedback) async {
    await _service.sendFeedback(feedback);
  }
}
