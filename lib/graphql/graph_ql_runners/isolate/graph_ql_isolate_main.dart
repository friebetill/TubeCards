import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:ferry/ferry.dart';
import 'package:ferry_hive_store/ferry_hive_store.dart';
import 'package:hive/hive.dart';
import 'package:logging/logging.dart';

import '../../../utils/certificate.dart';
import '../../../utils/logging.dart';
import '../../graph_ql_client.dart';
import 'cross_isolates_message.dart';
import 'graph_ql_isolate_runner.dart';

Future<void> graphQLIsolateMain(Map data) async {
  await setupLogging();
  final logger = Logger('graphQLIsolateMain');

  if (Platform.isAndroid) {
    trustLetsEncryptCertificate();
  }

  Hive.init(data[databasePathKey] as String);

  final client = GraphQLClient(Cache(
    store: HiveStore(await Hive.openBox(GraphQLClient.graphQLHiveBoxName)),
    typePolicies: GraphQLClient.typePolicies,
  ));

  // Listen to incoming messages and execute the contained command.
  final receivePort = ReceivePort()
    ..listen(
      (serializedMessage) async {
        final message = CrossIsolatesMessage.fromMap(
          serializedMessage as Map<String, dynamic>,
        );

        // If the command needs to be disposed later, create a port on which
        // a signal can be sent to dispose the command.
        if (message.command.isDisposable) {
          final closePort = ReceivePort();
          message.sender!.send(closePort.sendPort);

          closePort.listen((_) {
            message.command.dispose();
            closePort.close();
          });
        }

        // Catch all exceptions and send them via message.sender. Try-catch
        // and listen to the stream with onError don't catch the exceptions.
        await runZonedGuarded(
          () => message.command.execute(client, message.sender),
          (e, s) => logger.severe('Unexpected exception', e, s),
        );
      },
    );

  // Provide the caller with the reference of this isolate's SendPort.
  (data[portKey] as SendPort).send(receivePort.sendPort);
}
