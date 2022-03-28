import 'dart:isolate';

import 'commands/clear_cache_command.dart';
import 'commands/graph_ql_command.dart';
import 'commands/is_logged_in_command.dart';
import 'commands/noop_graph_ql_command.dart';
import 'commands/request_command.dart';
import 'commands/set_graph_ql_token_command.dart';

/// A message that can be interchanged between isolates.
///
/// From the [SendPort] documentation:
/// The content of message can be: primitive values (null, num, bool, double,
/// String), instances of [SendPort], and lists and maps whose elements are any
/// of these. List and maps are also allowed to be cyclic.
class CrossIsolatesMessage {
  CrossIsolatesMessage({required this.sender, required this.command});

  factory CrossIsolatesMessage.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey(_senderKey)) {
      throw ArgumentError('sender key missing from map');
    } else if (!map.containsKey(_commandKey)) {
      throw ArgumentError('command key missing from map');
    }

    final commandData = map[_commandKey] as Map<String, dynamic>;

    if (!commandData.containsKey(_commandIdentifierKey)) {
      throw ArgumentError('identifier key missing from command map');
    } else if (!commandData.containsKey(_commandArgumentsKey)) {
      throw ArgumentError('arguments key missing from command map');
    }

    return CrossIsolatesMessage(
      sender: map[_senderKey] as SendPort?,
      command: _getCommand(
        commandData[_commandIdentifierKey] as String,
        commandData[_commandArgumentsKey] as Map<String, dynamic>,
      ),
    );
  }

  // Keys into parts of the serialized message map.
  static const _senderKey = 'sender';
  static const _commandKey = 'command';
  static const _commandIdentifierKey = 'identifier';
  static const _commandArgumentsKey = 'arguments';

  final SendPort? sender;
  final GraphQLCommand command;

  Map<String, dynamic> toMap() {
    return {
      _senderKey: sender,
      _commandKey: _commandToMap(command),
    };
  }

  Map<String, dynamic> _commandToMap(GraphQLCommand command) {
    return {
      _commandIdentifierKey: command.getIdentifier(),
      _commandArgumentsKey: command.getArgumentMap(),
    };
  }
}

/// Factory method for [GraphQLCommand] instances.
///
/// In case no matching command can be found, [NoopGraphQLCommand] is
/// returned.
GraphQLCommand _getCommand(
  String identifier,
  Map<String, dynamic> arguments,
) {
  switch (identifier) {
    case RequestCommand.identifier:
      return RequestCommand.fromArgumentMap(arguments);
    case IsLoggedInCommand.identifier:
      return const IsLoggedInCommand();
    case SetGraphQLTokenCommand.identifier:
      return SetGraphQLTokenCommand.fromArgumentMap(arguments);
    case ClearCacheCommand.identifier:
      return const ClearCacheCommand();
    default:
      return const NoopGraphQLCommand();
  }
}
