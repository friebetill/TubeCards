import 'dart:isolate';

import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/locale.dart';

import 'commands/noop_text_to_speech_command.dart';
import 'commands/start_markdown_text_to_speech_command.dart';
import 'commands/start_text_to_speech_command.dart';
import 'commands/stop_text_to_speech_command.dart';
import 'commands/text_to_speech_command.dart';
import 'service/on_device_text_to_speech_service.dart';
import 'service/text_to_speech_service.dart';

void textToSpeechRunnerMain(SendPort callerSendPort) {
  // Initialize all the TTS services that might be needed within this isolate.
  final tts = OnDeviceTextToSpeechService();

  // Listen to incoming messages and execute the contained command.
  final receivePort = ReceivePort()
    ..listen((serializedMessage) async {
      final message = _CrossIsolatesMessage.fromMap(
        serializedMessage as Map<String, dynamic>,
      );
      await message.command.execute(tts);
    });

  // Provide the caller with the reference of this isolate's SendPort.
  callerSendPort.send(receivePort.sendPort);
}

/// Runner providing text-to-speech functionality through a dedicated isolate.
///
/// Due to more extensive work like speech synthesis, network requests for
/// high-quality TTS options
///
/// The runner stays alive until explicitly being killed.
@singleton
class TextToSpeechRunner {
  /// The isolate being used to run TTS functionality.
  ///
  /// [FlutterIsolate] is used as opposed to [Isolate] since it supports usage
  /// of flutter plugins like [FlutterTts].
  FlutterIsolate? _isolate;

  /// Port to communicate with the isolate.
  SendPort? _sendPort;

  /// Spawns a new isolate that is managed through this runner.
  Future<void> spawn() async {
    if (_isolate != null) {
      return;
    }

    final receivePort = ReceivePort();

    _isolate = await FlutterIsolate.spawn(
      textToSpeechRunnerMain,
      receivePort.sendPort,
    );

    _sendPort = await receivePort.first as SendPort;
  }

  /// Pauses execution of the runner's isolate.
  void pause() => _isolate?.pause();

  /// Resumes execution of the runner's isolate.
  void resume() => _isolate?.resume();

  /// Kills the isolate of the runner.
  void kill() => _isolate?.kill();

  /// Pronounces the given [text].
  ///
  /// The text will be spoken in the given [locale] if available by the
  /// underlying [TextToSpeechService].
  /// If unavailable, a fallback locale will be used.
  void startSpeech(String text, Locale locale) {
    _sendCommand(StartTextToSpeechCommand(text: text, locale: locale));
  }

  /// Pronounces a plain text version of the given [markdown].
  ///
  /// The resulting plain text will be spoken in the given [locale] if available
  /// by the underlying [TextToSpeechService].
  /// If unavailable, a fallback locale will be used.
  void startSpeechForMarkdown(String markdown, Locale locale) {
    _sendCommand(
      StartMarkdownTextToSpeechCommand(
        markdown: markdown,
        locale: locale,
      ),
    );
  }

  void stopSpeech() {
    _sendCommand(const StopTextToSpeechCommand());
  }

  /// Sends a serialized [TextToSpeechCommand] to the isolate.
  void _sendCommand(TextToSpeechCommand command) {
    final message = _CrossIsolatesMessage(sender: null, command: command);
    _sendPort?.send(message.toMap());
  }
}

/// A message that can be interchanged between isolates.
///
/// From the [SendPort] documentation:
/// The content of message can be: primitive values (null, num, bool, double,
/// String), instances of [SendPort], and lists and maps whose elements are any
/// of these. List and maps are also allowed to be cyclic.
class _CrossIsolatesMessage {
  _CrossIsolatesMessage({required this.sender, required this.command});

  factory _CrossIsolatesMessage.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey(_kSenderKey)) {
      throw ArgumentError('sender key missing from map');
    } else if (!map.containsKey(_kCommandKey)) {
      throw ArgumentError('command key missing from map');
    }

    final commandData = map[_kCommandKey] as Map<String, dynamic>;

    if (!commandData.containsKey(_kCommandIdentifierKey)) {
      throw ArgumentError('identifier key missing from command map');
    } else if (!commandData.containsKey(_kCommandArgumentsKey)) {
      throw ArgumentError('arguments key missing from command map');
    }

    return _CrossIsolatesMessage(
      sender: map[_kSenderKey] as SendPort?,
      command: _getCommand(
        commandData[_kCommandIdentifierKey] as String,
        commandData[_kCommandArgumentsKey] as Map<String, dynamic>,
      ),
    );
  }

  // Keys into parts of the serialized message map.
  static const _kSenderKey = 'sender';
  static const _kCommandKey = 'command';
  static const _kCommandIdentifierKey = 'identifier';
  static const _kCommandArgumentsKey = 'arguments';

  final SendPort? sender;
  final TextToSpeechCommand command;

  Map<String, dynamic> toMap() {
    return {
      _kSenderKey: sender,
      _kCommandKey: _commandToMap(command),
    };
  }

  Map<String, dynamic> _commandToMap(TextToSpeechCommand command) {
    return {
      _kCommandIdentifierKey: command.getIdentifier(),
      _kCommandArgumentsKey: command.getArgumentMap(),
    };
  }
}

/// Factory method for [TextToSpeechCommand] instances.
///
/// In case no matching command can be found, [NoopTextToSpeechCommand] is
/// returned.
TextToSpeechCommand _getCommand(
  String identifier,
  Map<String, dynamic> arguments,
) {
  switch (identifier) {
    case StartTextToSpeechCommand.kIdentifier:
      return StartTextToSpeechCommand.fromArgumentMap(arguments);
    case StartMarkdownTextToSpeechCommand.kIdentifier:
      return StartMarkdownTextToSpeechCommand.fromArgumentMap(arguments);
    case StopTextToSpeechCommand.kIdentifier:
      return StopTextToSpeechCommand.fromArgumentMap(arguments);
    default:
      return const NoopTextToSpeechCommand();
  }
}
