import 'package:devicelocale/devicelocale.dart';
import 'package:intl/locale.dart';
import 'package:meta/meta.dart';

import '../service/text_to_speech_service.dart';
import '../utils/locales_match_util.dart';
import '../utils/markdown_plain_text_encoder.dart';
import 'text_to_speech_command.dart';

/// Command to start text-to-speech output for a given Markdown string.
///
/// Any ongoing speech will be stopped beforehand.
@immutable
class StartMarkdownTextToSpeechCommand implements TextToSpeechCommand {
  const StartMarkdownTextToSpeechCommand({
    required this.markdown,
    required this.locale,
  });

  factory StartMarkdownTextToSpeechCommand.fromArgumentMap(
    Map<String, dynamic> args,
  ) {
    return StartMarkdownTextToSpeechCommand(
      markdown: args['markdown'] as String,
      locale: (Locale.tryParse(args['locale'] as String? ?? ''))!,
    );
  }

  /// Identifies this command during (de)serialization.
  static const String kIdentifier = 'start_markdown';

  final String markdown;
  final Locale locale;

  @override
  Map<String, dynamic> getArgumentMap() {
    return {
      'markdown': markdown,
      'locale': locale.toString(),
    };
  }

  @override
  String getIdentifier() => kIdentifier;

  @override
  Future<void> execute(TextToSpeechService tts) async {
    final text = const MarkdownPlainTextEncoder().convert(markdown);

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
