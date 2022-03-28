import 'dart:isolate';

import 'package:ferry/ferry.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../graph_ql_runner.dart';
import 'commands/clear_cache_command.dart';
import 'commands/is_logged_in_command.dart';
import 'commands/request_command.dart';
import 'commands/set_graph_ql_token_command.dart';
import 'cross_isolates_message.dart';
import 'graph_ql_isolate_main.dart';

const String databasePathKey = 'database_path';
const String portKey = 'port';

@Environment('graphql_isolate')
@Singleton(as: GraphQLRunner)
class GraphQLIsolateRunner implements GraphQLRunner {
  Isolate? _isolate;

  /// Port to communicate with the isolate.
  late SendPort _sendPort;

  final _logger = Logger((GraphQLIsolateRunner).toString());

  @override
  Future<void> spawn() async {
    if (_isolate != null) {
      return;
    }

    final receivePort = ReceivePort();
    final errorPort = ReceivePort();

    _isolate = await Isolate.spawn(
      graphQLIsolateMain,
      {
        databasePathKey: (await getApplicationDocumentsDirectory()).path,
        portKey: receivePort.sendPort,
      },
      onError: errorPort.sendPort,
    );

    errorPort.listen((e) => _logger.severe('Unexpected exception', e));
    _sendPort = await receivePort.first as SendPort;
  }

  @override
  Stream<OperationResponse<TData, TVars>> request<TData, TVars>(
    OperationRequest<TData, TVars> request,
  ) {
    final receivePort = ReceivePort();
    final message = CrossIsolatesMessage(
      sender: receivePort.sendPort,
      command: RequestCommand(
        requestJson: (request as dynamic).toJson() as Map<String, dynamic>,
      ),
    );
    _sendPort.send(message.toMap());

    // closePort is needed to close the request streams on the isolate after
    // the returned stream on the UI thread is closed.
    SendPort? closePort;

    return receivePort
        .skipWhile((event) {
          if (event is SendPort) {
            closePort = event;

            return true;
          }

          return false;
        })
        .whereType<OperationResponse<TData, TVars>>()
        // As soon as this stream is canceled, close the corresponding stream
        // on the isolate.
        .doOnCancel(() => closePort?.send(''));
  }

  @override
  Future<void> clear() async {
    final receivePort = ReceivePort();
    final message = CrossIsolatesMessage(
      sender: receivePort.sendPort,
      command: const ClearCacheCommand(),
    );
    _sendPort.send(message.toMap());

    await receivePort.first;
  }

  @override
  Future<void> setAuthToken(String token) async {
    final receivePort = ReceivePort();
    final message = CrossIsolatesMessage(
      sender: receivePort.sendPort,
      command: SetGraphQLTokenCommand(token: token),
    );
    _sendPort.send(message.toMap());

    await receivePort.first;
  }

  @override
  Future<bool> isLoggedIn() async {
    final receivePort = ReceivePort();
    final message = CrossIsolatesMessage(
      sender: receivePort.sendPort,
      command: const IsLoggedInCommand(),
    );
    _sendPort.send(message.toMap());

    return await receivePort.first as bool;
  }
}
