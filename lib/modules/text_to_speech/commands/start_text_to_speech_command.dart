import 'package:devicelocale/devicelocale.dart';
import 'package:intl/locale.dart';
import 'package:meta/meta.dart';

import '../service/text_to_speech_service.dart';
import '../utils/locales_match_util.dart';
import 'text_to_speech_command.dart';

/// Command to start text-to-speech output for a given text.
///
/// Any ongoing speech will be stopped beforehand.
@immutable
class StartTextToSpeechCommand implements TextToSpeechCommand {
  const StartTextToSpeechCommand({required this.text, required this.locale});

  factory StartTextToSpeechCommand.fromArgumentMap(Map<String, dynamic> args) {
    return StartTextToSpeechCommand(
      text: args['text'] as String,
      locale: (Locale.tryParse(args['locale'] as String? ?? ''))!,
    );
  }

  /// Identifies this command during (de)serialization.
  static const kIdentifier = 'start';

  final String text;
  final Locale locale;

  @override
  Map<String, dynamic> getArgumentMap() {
    return {
      'text': text,
      'locale': locale.toString(),
    };
  }

  @override
  String getIdentifier() => kIdentifier;

  @override
  Future<void> execute(TextToSpeechService tts) async {
    final fallbackLocale = Locale.tryParse((await Devicelocale.currentLocale)!);
    final supportedLocales = await tts.getSupportedLocales();

    final bestLocale = findBestMatchingLocale(
      locale,
      supportedLocales,
      fallbackLocale: fallbackLocale,
    );

    if (bestLocale == null) {
      return;
    }

    tts
      ..stop()
      ..setLocale(bestLocale)
      ..speak(text);
  }
}
