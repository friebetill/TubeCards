import 'package:intl/locale.dart';

/// Provides text-to-speech capabilities.
///
/// This might involve network operations.
abstract class TextToSpeechService {
  /// Output a spoken representation of the given [text].
  void speak(String text);

  /// Stop any ongoing pronounciation.
  void stop();

  /// Sets the preferred locale to be used for the language model.
  ///
  /// This has an impact on how words are pronounced. There are also variations
  /// available based on country. 'en_US' will have a different pronounciation
  /// compared to 'en_IN' for example.
  ///
  /// The locale needs to be supported. Call [getSupportedLocales] to get the
  /// list of supported locales.
  void setLocale(Locale locale);

  /// Returns the list of locales that are supported by this service.
  Future<List<Locale>> getSupportedLocales();
}
