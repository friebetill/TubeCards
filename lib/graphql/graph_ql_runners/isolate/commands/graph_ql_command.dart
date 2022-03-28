import 'dart:isolate';

import '../../../graph_ql_client.dart';

/// Command to execute an operation on a [GraphQLClient].
///
/// The arguments of the command can be (de)serialized using [fromArgumentMap]
/// and [getArgumentMap].
abstract class GraphQLCommand {
  GraphQLCommand.fromArgumentMap(Map<String, dynamic> _);

  /// Returns a string which uniquely identifies the type of the command.
  String getIdentifier();

  /// Returns a map of arguments of this command.
  Map<String, dynamic> getArgumentMap();

  /// Execute an operation on the given [graphQLClient] instance and send the
  /// result through [sendPort].
  Future<void> execute(
    GraphQLClient graphQLClient,
    SendPort? sendPort,
  );

  bool get isDisposable;

  void dispose();
}
