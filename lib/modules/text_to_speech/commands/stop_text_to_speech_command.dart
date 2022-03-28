import 'package:meta/meta.dart';

import '../service/text_to_speech_service.dart';
import 'text_to_speech_command.dart';

/// Command to stop any ongoing text-to-speech output.
@immutable
class StopTextToSpeechCommand implements TextToSpeechCommand {
  const StopTextToSpeechCommand();

  factory StopTextToSpeechCommand.fromArgumentMap(Map<String, dynamic> _) {
    return const StopTextToSpeechCommand();
  }

  /// Identifies this command during (de)serialization.
  static const String kIdentifier = 'stop';

  @override
  String getIdentifier() => kIdentifier;

  @override
  Map<String, dynamic> getArgumentMap() => {};

  @override
  Future<void> execute(TextToSpeechService tts) async => tts.stop();
}
