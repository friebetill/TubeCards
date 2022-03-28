import 'dart:isolate';

import 'package:meta/meta.dart';

import '../../../graph_ql_client.dart';
import 'graph_ql_command.dart';

/// A command to clear the GraphQL cache and reset the authentication token.
@immutable
class ClearCacheCommand implements GraphQLCommand {
  const ClearCacheCommand();

  factory ClearCacheCommand.fromArgumentMap(Map<String, dynamic> _) {
    return const ClearCacheCommand();
  }

  /// Identifies this command during (de)serialization.
  static const String identifier = 'clear_cache';

  @override
  Map<String, dynamic> getArgumentMap() => {};

  @override
  String getIdentifier() => identifier;

  @override
  Future<void> execute(GraphQLClient graphQLClient, SendPort? sendPort) async {
    graphQLClient
      ..authToken = ''
      ..clear();

    // Send null to signal that the cache has been cleared.
    sendPort!.send(null);
  }

  @override
  bool get isDisposable => false;

  @override
  void dispose() {
    // NO-OP
  }
}
