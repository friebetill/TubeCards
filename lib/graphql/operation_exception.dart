import 'dart:io';

import 'package:ferry/ferry.dart';
import 'package:gql_exec/gql_exec.dart';

import '../services/tubecards/graph_ql_error_code.dart';
import '../utils/socket_exception_extension.dart';

class OperationException implements Exception {
  OperationException({
    this.linkException,
    Iterable<GraphQLError>? graphqlErrors = const [],
  }) : graphqlErrors = graphqlErrors?.toList() ?? [];

  List<GraphQLError> graphqlErrors = [];
  LinkException? linkException;

  bool get isNoInternet {
    final exception = linkException?.originalException;

    if (exception is SocketException) {
      return exception.isNoInternet;
    }

    return false;
  }

  bool get isServerOffline {
    final exception = linkException?.originalException;

    if (exception is FormatException) {
      return exception.message.contains('Unexpected character');
    } else if (exception is SocketException) {
      return exception.isServerOffline;
    }

    return false;
  }

  bool get isIncorrectEmailPassword {
    return graphqlErrors.any(
      (e) => e.extensions!['code'] == GraphQLErrorCode.authenticationError,
    );
  }

  bool get isUserAlreadyMember {
    return graphqlErrors.any(
      (e) => e.extensions!['code'] == GraphQLErrorCode.alreadyMemberError,
    );
  }

  bool get isDeckPublic {
    return graphqlErrors.any(
      (e) => e.extensions!['code'] == GraphQLErrorCode.deckIsPublic,
    );
  }

  bool get isUserInputError {
    return graphqlErrors
        .any((e) => e.extensions!['code'] == GraphQLErrorCode.userInputError);
  }

  bool get doesUserAlreadyExists {
    return graphqlErrors
        .any((e) => e.message.contains('The user with the email'));
  }

  bool get hasInvalidAuthenticationToken {
    return graphqlErrors.any((e) => e.message.contains('Invalid token'));
  }

  void addError(GraphQLError error) => graphqlErrors.add(error);

  @override
  String toString() {
    return [
      if (linkException != null) 'LinkException: $linkException',
      if (graphqlErrors.isNotEmpty) 'GraphQL Errors:',
      ...graphqlErrors.map((e) => e.toString()),
    ].join('\n');
  }
}
