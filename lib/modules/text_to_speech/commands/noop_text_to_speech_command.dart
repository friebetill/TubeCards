import 'package:meta/meta.dart';

import '../service/text_to_speech_service.dart';
import 'text_to_speech_command.dart';

/// A command that does nothing (no-operation).
///
/// It can serve as fallbacks to avoid having to write custom handling logic
/// in case no command is available.
@immutable
class NoopTextToSpeechCommand implements TextToSpeechCommand {
  const NoopTextToSpeechCommand();

  factory NoopTextToSpeechCommand.fromArgumentMap(Map<String, dynamic> _) {
    return const NoopTextToSpeechCommand();
  }

  /// Identifies this command during (de)serialization.
  static const String kIdentifier = 'noop';

  @override
  Map<String, dynamic> getArgumentMap() => {};

  @override
  String getIdentifier() => kIdentifier;

  @override
  Future<void> execute(TextToSpeechService tts) async {}
}
