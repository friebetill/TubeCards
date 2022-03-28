import 'dart:isolate';

import 'package:meta/meta.dart';

import '../../../graph_ql_client.dart';
import 'graph_ql_command.dart';

/// A command to find out if the user is logged in.
@immutable
class IsLoggedInCommand implements GraphQLCommand {
  const IsLoggedInCommand();

  factory IsLoggedInCommand.fromArgumentMap(Map<String, dynamic> _) {
    return const IsLoggedInCommand();
  }

  /// Identifies this command during (de)serialization.
  static const String identifier = 'is_logged_in';

  @override
  Map<String, dynamic> getArgumentMap() => {};

  @override
  String getIdentifier() => identifier;

  @override
  Future<void> execute(GraphQLClient graphQLClient, SendPort? sendPort) async {
    sendPort!.send(graphQLClient.authToken != '');
  }

  @override
  bool get isDisposable => false;

  @override
  void dispose() {
    // NO-OP
  }
}
