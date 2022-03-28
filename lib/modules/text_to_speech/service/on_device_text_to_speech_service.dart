import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/locale.dart';

import 'text_to_speech_service.dart';

/// Provide TTS functionality using models available on-device.
///
/// This service might trigger downloads of language models the first time
/// they are being used.
@singleton
class OnDeviceTextToSpeechService implements TextToSpeechService {
  final _tts = Platform.isAndroid || Platform.isIOS ? FlutterTts() : null;

  @override
  void speak(String text) => _tts?.speak(text);

  @override
  void stop() => _tts?.stop();

  @override
  void setLocale(Locale locale) {
    _tts?.setLanguage(locale.toString());
  }

  @override
  Future<List<Locale>> getSupportedLocales() async {
    if (_tts == null) {
      return [];
    }

    final languageStrings = (await _tts!.getLanguages as List).cast<String>();

    return languageStrings.map((t) => Locale.tryParse(t)!).toList();
  }
}
