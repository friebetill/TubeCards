import 'dart:async';

import 'package:ferry/ferry.dart';
import 'package:gql_error_link/gql_error_link.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql_http_link/gql_http_link.dart';
import 'package:gql_transform_link/gql_transform_link.dart';

class HttpAuthLink extends Link {
  HttpAuthLink({required this.token, required this.graphQLEndpoint}) {
    _link = Link.from([
      TransformLink(requestTransformer: transformRequest),
      ErrorLink(onException: handleException),
      HttpLink(graphQLEndpoint),
    ]);
  }

  final String graphQLEndpoint;
  late Link _link;
  String token;

  /// HTTP response code indicating that the request could not be authenticated.
  static const _unauthorizedErrorCode = 401;

  Stream<Response> handleException(
    Request request,
    NextLink forward,
    LinkException exception,
  ) async* {
    if (exception is HttpLinkServerException &&
        exception.response.statusCode == _unauthorizedErrorCode) {
      yield* forward(request);

      return;
    }

    final message = exception is HttpLinkServerException
        ? exception.response.reasonPhrase!
        : exception.toString();

    Zone.current.handleUncaughtError(message, StackTrace.fromString(''));

    throw exception;
  }

  Request transformRequest(Request request) {
    return request.updateContextEntry<HttpLinkHeaders>(
      (headers) => HttpLinkHeaders(
        headers: <String, String>{
          ...headers?.headers ?? <String, String>{},
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  @override
  Stream<Response> request(
    Request request, [
    Stream<Response> Function(Request)? forward,
  ]) async* {
    yield* _link.request(request, forward);
  }
}
