import 'dart:isolate';

import 'package:meta/meta.dart';

import '../../../graph_ql_client.dart';
import 'graph_ql_command.dart';

/// A command to set the GraphQL token.
@immutable
class SetGraphQLTokenCommand implements GraphQLCommand {
  const SetGraphQLTokenCommand({required this.token});

  factory SetGraphQLTokenCommand.fromArgumentMap(Map<String, dynamic> args) {
    return SetGraphQLTokenCommand(token: args['token'] as String);
  }

  /// Identifies this command during (de)serialization.
  static const String identifier = 'set_token';

  final String token;

  @override
  Map<String, dynamic> getArgumentMap() => {'token': token};

  @override
  String getIdentifier() => identifier;

  @override
  Future<void> execute(GraphQLClient graphQLClient, SendPort? sendPort) async {
    graphQLClient.authToken = token;

    // Send null to signal that the token has been written.
    sendPort!.send(null);
  }

  @override
  bool get isDisposable => false;

  @override
  void dispose() {
    // NO-OP
  }
}
