import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/locale.dart';

import '../../../../utils/themes/custom_theme.dart';
import '../../../../widgets/component/component.dart';
import '../../../text_to_speech/utils/locales_match_util.dart';
import 'language_picker_bloc.dart';
import 'language_picker_view_model.dart';

/// A controlled component allowing the user to pick from a list of locales.
///
/// A locale consists of a language code as well as a country code. The country
/// code might be missing.
///
/// In case there is only a single menu entry for a given language code, the
/// country will not be displayed as part of the language name. It will only be
/// visible as part of the flag next to the language name.
class LanguagePickerComponent extends StatelessWidget {
  const LanguagePickerComponent({
    required this.value,
    required this.onChanged,
    required this.hint,
    Key? key,
  }) : super(key: key);

  final Locale? value;

  final ValueChanged<Locale> onChanged;

  final String hint;

  @override
  Widget build(BuildContext context) {
    return Component<LanguagePickerBloc>(
      // This is a no-op
      createViewModel: (bloc) {},
      builder: (context, bloc) {
        return StreamBuilder<LanguagePickerViewModel>(
          stream: bloc.viewModel(value, onChanged, hint),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              // ignore: only_throw_errors
              throw snapshot.error!;
            }
            if (!snapshot.hasData) {
              return Container();
            }

            return _LanguagePickerView(viewModel: snapshot.data!);
          },
        );
      },
    );
  }
}

@immutable
class _LanguagePickerView extends StatefulWidget {
  const _LanguagePickerView({required this.viewModel, Key? key})
      : super(key: key);

  final LanguagePickerViewModel viewModel;

  @override
  _LanguagePickerViewState createState() => _LanguagePickerViewState();
}

class _LanguagePickerViewState extends State<_LanguagePickerView> {
  late LocalizedTtsLanguages _ttsLanguages;

  @override
  void didChangeDependencies() {
    _ttsLanguages = LocalizedTtsLanguages(context, widget.viewModel.locales);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.grey.shade100
            : Theme.of(context).custom.elevation24DPColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButton(
        dropdownColor: Theme.of(context).custom.elevation24DPColor,
        hint: Text(widget.viewModel.hint),
        isExpanded: true,
        onChanged: (v) {
          if (v == null) {
            return;
          }
          widget.viewModel.onChanged(Locale.parse(v as String));
        },
        value: widget.viewModel.value?.toLanguageTag(),
        underline: Container(),
        items: _buildMenuItems(),
      ),
    );
  }

  /// Returns a list of dropdown entries that are supported for card content.
  ///
  /// The entries are already sorted in the way they should be displayed.
  List<_DropdownMenuEntry> _getAvailableMenuEntries() {
    final menuEntries = <_DropdownMenuEntry>[];

    _ttsLanguages.displayNames.forEach((locale, languageName) => menuEntries
        .add(_DropdownMenuEntry(locale: locale, languageName: languageName)));

    // Sorts by translated language name in ascending order.
    menuEntries.sort();

    return menuEntries;
  }

  List<DropdownMenuItem<String>> _buildMenuItems() {
    return _getAvailableMenuEntries()
        .map((e) => DropdownMenuItem(
              value: e.locale.toLanguageTag(),
              child: Row(
                children: [
                  _buildFlagIcon(e.locale),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      e.languageName,
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  Widget _buildFlagIcon(Locale locale) {
    // Used in case a matching country cannot be obtained.
    // The corresponding flag for this country code shows a grey question mark.
    const kUnknownCountryCode = 'XX';

    // These language codes are known to miss country codes. Matching countries
    // are determined on a best-effort basis and should be revisited.
    const kCountryCodeOverrides = {
      'hr': 'HR', // Croatian -> Croatia
      'sr': 'RS', // Serbian -> Serbia
      'cy': 'GB-WLS', // Welsh -> Wales
      'bs': 'BS', // Bosnian -> Bosnia & Herzegovina
      'ca': 'AD', // Catalan -> Andorra
      'sq': 'AL', // Albanian -> Albania
      'sw': 'TZ', // Swahili -> Tanzania (debatable)
      'ta': 'SG', // Tamil -> Singapore (debatable)
    };
    const kFlagIconSize = 20.0;

    final countryCode = locale.countryCode ??
        kCountryCodeOverrides[locale.languageCode] ??
        kUnknownCountryCode;

    return SvgPicture.asset(
      'assets/images/flags/${countryCode.toLowerCase()}.svg',
      width: kFlagIconSize,
      height: kFlagIconSize,
    );
  }
}

/// Represents the data used for a single language picker dropdown menu item.
@immutable
class _DropdownMenuEntry extends Comparable<_DropdownMenuEntry> {
  _DropdownMenuEntry({required this.locale, required this.languageName});

  /// Locale the menu entry is representing.
  final Locale locale;

  /// Translated language name.
  ///
  /// This might not include the country name of the locale.
  final String languageName;

  @override
  int compareTo(_DropdownMenuEntry other) {
    return languageName.compareTo(other.languageName);
  }
}
