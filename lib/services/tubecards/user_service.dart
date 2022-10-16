import 'dart:async';

import 'package:ferry/ferry.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/auth_result.dart';
import '../../data/models/average_learning_state.dart';
import '../../data/models/user.dart';
import '../../graphql/graph_ql_runner.dart';
import '../../graphql/mutations/__generated__/create_anonymous_user.req.gql.dart';
import '../../graphql/mutations/__generated__/delete_user.req.gql.dart';
import '../../graphql/mutations/__generated__/log_in.req.gql.dart';
import '../../graphql/mutations/__generated__/sendFeedback.req.gql.dart';
import '../../graphql/mutations/__generated__/sign_up.req.gql.dart';
import '../../graphql/mutations/__generated__/trigger_password_reset.req.gql.dart';
import '../../graphql/mutations/__generated__/update_user.req.gql.dart';
import '../../graphql/operation_exception.dart';
import '../../graphql/queries/__generated__/user_learning_state.req.gql.dart';
import '../../graphql/queries/__generated__/viewer.req.gql.dart';
import '../../graphql/update_cache_handlers/create_anonymous_handler.dart';
import '../../graphql/update_cache_handlers/login_handler.dart';
import '../../graphql/update_cache_handlers/sign_up_handler.dart';
import '../../graphql/update_cache_handlers/update_user_handler.dart';

const timeOutDuration = Duration(seconds: 15);

@singleton
class UserService {
  UserService(this._graphQLRunner);

  final GraphQLRunner _graphQLRunner;

  /// Returns a [User] for the logged in user.
  ///
  /// Returns null if the user is not logged in.
  Stream<User?> viewer({FetchPolicy? fetchPolicy}) {
    return _graphQLRunner
        .request(GViewerReq(
      (b) => b
        ..requestId = 'viewer'
        ..fetchPolicy = fetchPolicy,
    ))
        .map((r) {
      if (r.data == null && r.hasErrors) {
        final exception = OperationException(
          linkException: r.linkException,
          graphqlErrors: r.graphqlErrors,
        );
        if (exception.hasInvalidAuthenticationToken) {
          return null;
        }
        throw exception;
      }
      if (r.data == null) {
        return null;
      }

      return User.fromJson(r.data!.viewer.toJson());
    });
  }

  Stream<AverageLearningState> learningState({FetchPolicy? fetchPolicy}) {
    AverageLearningState? learningState;

    return _graphQLRunner
        .request(GUserLearningStateReq((b) => b.fetchPolicy = fetchPolicy))
        .distinct()
        .map((response) {
      if (response.data != null) {
        learningState = AverageLearningState.fromJson(
          response.data!.viewer.learningState.toJson(),
        );
      }
      if (learningState == null && response.hasErrors) {
        throw OperationException(
          linkException: response.linkException,
          graphqlErrors: response.graphqlErrors,
        );
      }

      return learningState!;
    });
  }

  /// Returns true if the user was successfully deleted, false otherwise.
  Future<void> deleteUser() {
    return _graphQLRunner
        .request(GDeleteUserReq(
      (b) => b..fetchPolicy = FetchPolicy.NoCache,
    ))
        .map((r) {
      if (r.hasErrors) {
        throw OperationException(
          linkException: r.linkException,
          graphqlErrors: r.graphqlErrors,
        );
      }

      return true;
    }).first;
  }

  /// Returns an [AuthResult] after the successful creation of an anonymous
  /// account.
  ///
  /// Throws an [OperationException] or an [TimeoutException] if it was not
  /// successful.
  Future<AuthResult> createAnonymousUser() {
    return _graphQLRunner
        .request(GCreateAnonymousUserReq(
          (b) => b
            ..fetchPolicy = FetchPolicy.NoCache
            ..updateCacheHandlerKey = createAnonymousUserHandlerKey,
        ))
        .map((r) {
          if (r.hasErrors) {
            throw OperationException(
              linkException: r.linkException,
              graphqlErrors: r.graphqlErrors,
            );
          }

          return AuthResult.fromJson(r.data!.createAnonymousUser.toJson());
        })
        .timeout(timeOutDuration)
        .first;
  }

  /// Returns an [AuthResult] after a successful login.
  ///
  /// Throws an [OperationException] or an [TimeoutException] if it was not
  /// successful.
  Future<AuthResult> logIn(String email, String password) async {
    return _graphQLRunner
        .request(GLogInReq(
          (b) => b
            ..vars.email = email
            ..vars.password = password
            ..fetchPolicy = FetchPolicy.NoCache
            ..updateCacheHandlerKey = logInHandlerKey,
        ))
        .map((r) {
          if (r.hasErrors) {
            throw OperationException(
              linkException: r.linkException,
              graphqlErrors: r.graphqlErrors,
            );
          }

          return AuthResult.fromJson(r.data!.login.toJson());
        })
        .timeout(timeOutDuration)
        .first;
  }

  /// Returns an [AuthResult] after a successful sign up.
  ///
  /// Throws an [OperationException] or an [TimeoutException] if it was not
  /// successful.
  Future<AuthResult> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    return _graphQLRunner
        .request(GSignUpReq(
          (b) => b
            ..vars.email = email
            ..vars.password = password
            ..vars.firstName = firstName
            ..vars.lastName = lastName
            ..fetchPolicy = FetchPolicy.NoCache
            ..updateCacheHandlerKey = signUpHandlerKey,
        ))
        .map((r) {
          if (r.hasErrors) {
            throw OperationException(
              linkException: r.linkException,
              graphqlErrors: r.graphqlErrors,
            );
          }

          return AuthResult.fromJson(r.data!.signUp.toJson());
        })
        .timeout(timeOutDuration)
        .first;
  }

  /// Returns on success the updated [User] otherwise null.
  Future<User> updateUser(
    String? firstName,
    String? lastName,
    String? email,
    String? password, {
    bool? isAnonymous,
  }) {
    return _graphQLRunner
        .request(GUpdateUserReq((b) => b
          ..fetchPolicy = FetchPolicy.NoCache
          ..vars.email = email
          ..vars.password = password
          ..vars.firstName = firstName
          ..vars.lastName = lastName
          ..vars.isAnonymous = isAnonymous
          ..updateCacheHandlerKey = updateUserHandlerKey))
        .map((r) {
      if (r.hasErrors) {
        throw OperationException(
          linkException: r.linkException,
          graphqlErrors: r.graphqlErrors,
        );
      }

      return User.fromJson(r.data!.updateUser.toJson());
    }).first;
  }

  Future<void> triggerPasswordReset(String emailAddress) {
    return _graphQLRunner
        .request(GTriggerPasswordResetReq((b) => b
          ..fetchPolicy = FetchPolicy.NoCache
          ..vars.emailAddress = emailAddress))
        .map((r) {
      if (r.hasErrors) {
        throw OperationException(
          linkException: r.linkException,
          graphqlErrors: r.graphqlErrors,
        );
      }
    }).first;
  }

  Future<void> sendFeedback(String feedback) async {
    return _graphQLRunner
        .request(GSendFeedbackReq((b) => b
          ..fetchPolicy = FetchPolicy.NoCache
          ..vars.feedback = feedback))
        .map((r) {
      if (r.hasErrors) {
        throw OperationException(
          linkException: r.linkException,
          graphqlErrors: r.graphqlErrors,
        );
      }
    }).first;
  }

  Future<void> setAuthToken(String authToken) async {
    await _graphQLRunner.setAuthToken(authToken);
  }

  Future<void> clear() async {
    await _graphQLRunner.clear();
  }
}
