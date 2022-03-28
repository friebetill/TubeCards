import 'package:flutter/material.dart';
import 'package:intl/locale.dart';

import '../../../i18n/i18n.dart';
import '../../../utils/custom_navigator.dart';
import 'language_picker/language_picker_component.dart';

class LanguagePickerDialog extends StatefulWidget {
  const LanguagePickerDialog({
    required this.frontLocale,
    required this.backLocale,
    required this.onSave,
    Key? key,
  }) : super(key: key);

  final Locale? frontLocale;
  final Locale? backLocale;

  final Function(Locale? newFrontLocale, Locale? newBackLocale) onSave;

  @override
  State<StatefulWidget> createState() => _LanguagePickerDialogState();
}

class _LanguagePickerDialogState extends State<LanguagePickerDialog> {
  /// Stores the current value of the locale for the front side of cards.
  late Locale? _frontLocale;

  /// Stores the current value of the locale for the back side of cards.
  late Locale? _backLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // In case the given locales are ever updated, we override the state.
    setState(() {
      _frontLocale = widget.frontLocale;
      _backLocale = widget.backLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).textToSpeechLanguages),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.of(context).textToSpeechDescriptionText),
          const SizedBox(height: 12),
          _buildLanguageTitle(S.of(context).frontSide),
          const SizedBox(height: 4),
          LanguagePickerComponent(
            value: _frontLocale,
            onChanged: _handleFrontLocaleChange,
            hint: S.of(context).language,
          ),
          const SizedBox(height: 12),
          _buildLanguageTitle(S.of(context).backSide),
          const SizedBox(height: 4),
          LanguagePickerComponent(
            value: _backLocale,
            onChanged: _handleBackLocaleChange,
            hint: S.of(context).language,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _handleCancel,
          child: Text(
            S.of(context).cancel.toUpperCase(),
            style: Theme.of(context).textTheme.button,
          ),
        ),
        TextButton(
          onPressed: _handleSave,
          child: Text(S.of(context).ok.toUpperCase()),
        ),
      ],
    );
  }

  Widget _buildLanguageTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _handleSave() => widget.onSave(_frontLocale, _backLocale);

  void _handleCancel() => CustomNavigator.getInstance().pop();

  void _handleFrontLocaleChange(Locale newLocale) {
    setState(() => _frontLocale = newLocale);
  }

  void _handleBackLocaleChange(Locale newLocale) {
    setState(() => _backLocale = newLocale);
  }
}
