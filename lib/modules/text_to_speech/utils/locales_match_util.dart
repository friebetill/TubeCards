import 'package:flutter/widgets.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:intl/intl.dart';
import 'package:intl/locale.dart';

/// Returns the best matching locale from [supportedLocales] for [locale].
///
/// Returns null] if no match could be found.
Locale? findBestMatchingLocale(
  Locale? locale,
  List<Locale>? availableLocales, {
  required Locale? fallbackLocale,
}) {
  if (availableLocales == null || availableLocales.isEmpty || locale == null) {
    return null;
  }

  final availableLocalesSet = availableLocales.toSet();
  if (availableLocalesSet.contains(locale)) {
    return locale;
  }

  // If the given locale contains a country code, we now need to ignore it.
  // This is the case because the language takes precedence over the country.
  // As an example, if there is no match for 'en_IN', we would rather return
  // 'en_US' as opposed to 'in_IN'.
  final preferredLocale = _getPreferredLocaleForLanguageCode(
    locale.languageCode,
    availableLocalesSet,
  );
  if (preferredLocale != null) {
    return preferredLocale;
  }

  if (fallbackLocale == null) {
    return null;
  }

  // In case the app locale is different from the locale we just checked, we can
  // try and resolve a supported locale for the fallback locale.
  // This will not be an endless loop since fallbackLocale == locale is true in
  // the recursive call.
  if (fallbackLocale != locale) {
    return findBestMatchingLocale(
      fallbackLocale,
      availableLocales,
      fallbackLocale: fallbackLocale,
    );
  }

  // If we just checked the fallback locale, there is just no way except to
  // either pick a random language or to surrender. We surrender.
  return null;
}

/// Returns the preferred locale from [locales] for the given [languageCode].
///
/// In case no preferred locale could be found, null is returned.
Locale? _getPreferredLocaleForLanguageCode(
  String languageCode,
  Set<Locale> locales,
) {
  final languageCodeToLocale = _buildLanguageCodeLookup(locales);

  if (languageCodeToLocale.containsKey(languageCode)) {
    final candidates = languageCodeToLocale[languageCode];

    final countryCode = _getPreferredCountryCode(
      languageCode,
      candidates!.map((l) => l.countryCode!).toSet(),
    );

    return candidates.singleWhere((l) => l.countryCode == countryCode);
  }

  return null;
}

/// Returns the preferred country code for the given [languageCode].
///
/// Only country codes within [countryCodes] are considered. In case the given
/// set of country codes is empty, null is returned.
String? _getPreferredCountryCode(
  String languageCode,
  Set<String>? countryCodes,
) {
  if (countryCodes == null || countryCodes.isEmpty) {
    return null;
  }

  const kPreferredCountryCodes = {'en': 'US'};
  if (kPreferredCountryCodes.containsKey(languageCode)) {
    return kPreferredCountryCodes[languageCode];
  }

  // Prefer locales that are of the form 'xx_XX' as opposed to 'xx_YY'.
  //
  // The idea here is to prefer the locale with the "main" country using the
  // language.
  // So we would pick 'fr_FR' in favor of 'fr_CA'. This does not work all
  // the time though (e.g. 'en_EN' does not exist).
  if (countryCodes.contains(languageCode.toUpperCase())) {
    return languageCode.toUpperCase();
  }

  // Just return any country code within the non-empty set.
  return countryCodes.first;
}

/// Returns a map from language code to all locales using that language code.
Map<String, Set<Locale>> _buildLanguageCodeLookup(Iterable<Locale> locales) {
  final lookup = <String, Set<Locale>>{};

  for (final l in locales) {
    if (lookup.containsKey(l.languageCode)) {
      lookup[l.languageCode]!.add(l);
    } else {
      lookup[l.languageCode] = {l};
    }
  }

  return lookup;
}

/// Helper class to return localized names for supported text-to-speech locales.
@immutable
class LocalizedTtsLanguages {
  LocalizedTtsLanguages(this._context, List<Locale> ttsLocales)
      : _displayNames = _buildDisplayNames(_context, ttsLocales);

  final BuildContext _context;

  final Map<Locale, String> _displayNames;
  Map<Locale, String> get displayNames => _displayNames;

  /// Returns the display name of a given [locale].
  ///
  /// The display name will be the most compact string still uniquely
  /// representing the given [locale] in the context of all supported
  /// text-to-speech locales.
  String? getDisplayName(Locale? locale) => _displayNames[locale];

  /// Returns the full name of a locale.
  ///
  /// As an example, this would always return 'French (France)' even if there is
  /// only a single locale with language code 'fr' and thus 'French' could be
  /// used.
  String? getLongDisplayName(Locale locale) {
    return LocaleNames.of(_context)!.nameOf(_localeToNameKey(locale));
  }

  // Helper method to convert a locale to a key that can be used to lookup the
  // translated language name.
  static String _localeToNameKey(Locale locale) {
    return Intl.canonicalizedLocale(locale.toLanguageTag());
  }

  static Map<Locale, String> _buildDisplayNames(
    BuildContext context,
    List<Locale> ttsLocales,
  ) {
    final namedLocaleIdentifiers = LocaleNames.of(context)!.data.keys;

    final availableLocales = ttsLocales
        .where((l) => namedLocaleIdentifiers.contains(_localeToNameKey(l)));
    final availableLanguageCodes = availableLocales.map((l) => l.languageCode);

    final foundLanguageCodes = <String>{};
    final duplicateLanguageCodes = <String>{};

    // By default, each language name will contain the country name if present
    // in the locale string (e.g. de-DE).
    //
    // Here we check whether a language is only present once. If so, then the
    // country should not be part of the language name to keep it cleaner.
    // "German (Germany)" would then just turn into "German".
    for (final languageCode in availableLanguageCodes) {
      if (foundLanguageCodes.contains(languageCode)) {
        duplicateLanguageCodes.add(languageCode);
      } else {
        foundLanguageCodes.add(languageCode);
      }
    }

    final displayNames = <Locale, String>{};

    for (final locale in availableLocales) {
      String? languageName;

      // Check whether the country name is needed for differentiation.
      // In case there are multiple entries for the same language code, e.g.
      // "en-GB" and "en-US", we keep the country name for differentiation.
      // Otherwise, only the language name will be used without the country.
      languageName = duplicateLanguageCodes.contains(locale.languageCode)
          ? LocaleNames.of(context)!.nameOf(_localeToNameKey(locale))
          : LocaleNames.of(context)!.nameOf(locale.languageCode);

      displayNames[locale] = languageName!;
    }

    return displayNames;
  }
}
