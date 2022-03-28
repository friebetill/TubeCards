import '../service/text_to_speech_service.dart';

/// Command to execute an operation on a [TextToSpeechService].
///
/// The arguments of the command can be (de)serialized using [fromArgumentMap]
/// and [getArgumentMap].
abstract class TextToSpeechCommand {
  TextToSpeechCommand.fromArgumentMap(Map<String, dynamic> _);

  /// Returns a string which uniquely identifies the type of the command.
  String getIdentifier();

  /// Returns a map of arguments of this command.
  Map<String, dynamic> getArgumentMap();

  /// Execute an operation on the given [tts] instance.
  Future<void> execute(TextToSpeechService tts);
}
