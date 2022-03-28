import 'package:flutter/foundation.dart';
import 'package:intl/locale.dart';

/// View model used for the [LanguagePickerComponent].
class LanguagePickerViewModel {
  LanguagePickerViewModel({
    required this.value,
    required this.locales,
    required this.onChanged,
    required this.hint,
  });

  final Locale? value;

  final ValueChanged<Locale> onChanged;

  final List<Locale> locales;

  final String hint;
}
