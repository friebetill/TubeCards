import 'dart:isolate';

import 'package:meta/meta.dart';

import '../../../graph_ql_client.dart';
import 'graph_ql_command.dart';

/// A command that does nothing (no-operation).
///
/// It can serve as fallbacks to avoid having to write custom handling logic
/// in case no command is available.
@immutable
class NoopGraphQLCommand implements GraphQLCommand {
  const NoopGraphQLCommand();

  factory NoopGraphQLCommand.fromArgumentMap(Map<String, dynamic> _) {
    return const NoopGraphQLCommand();
  }

  /// Identifies this command during (de)serialization.
  static const String identifier = 'noop';

  @override
  Map<String, dynamic> getArgumentMap() => {};

  @override
  String getIdentifier() => identifier;

  @override
  Future<void> execute(GraphQLClient _, SendPort? __) async {
    // NO-OP
  }

  @override
  bool get isDisposable => false;

  @override
  void dispose() {
    // NO-OP
  }
}
