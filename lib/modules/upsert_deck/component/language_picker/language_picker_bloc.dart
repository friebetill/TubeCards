import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/locale.dart';

import '../../../text_to_speech/service/on_device_text_to_speech_service.dart';
import 'language_picker_view_model.dart';

/// BLoC for the [LanguagePickerComponent].
///
/// Exposes a [LanguagePickerViewModel] for that component to use.
@injectable
class LanguagePickerBloc {
  LanguagePickerBloc(this._tts);

  /// Text-to-speech instance used to obtain supported languages.
  final OnDeviceTextToSpeechService _tts;

  Stream<LanguagePickerViewModel> viewModel(
    Locale? value,
    ValueChanged<Locale> onChanged,
    String hint,
  ) {
    return Stream.fromFuture(
      _createViewModel(
        value,
        onChanged,
        hint,
      ),
    );
  }

  Future<LanguagePickerViewModel> _createViewModel(
    Locale? value,
    Function(Locale) onChanged,
    String hint,
  ) async {
    final locales = await _tts.getSupportedLocales();

    return LanguagePickerViewModel(
      value: locales.contains(value) ? value : null,
      onChanged: onChanged,
      hint: hint,
      locales: locales,
    );
  }
}
