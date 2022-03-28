import 'dart:ui';

/// The default locale to be used in case we could not find a matching locale
/// that is supported.
const defaultLocale = Locale('en', '');

/// Returns the best matching supported locale.
///
/// Currently, the most fitting locale is only determined on the basis of the
/// LanguageCodes. See basicLocaleListResolution in app.dart for a better
/// algorithm. If no match is found, fallback to English locale.
Locale getBestMatchingSupportedLocale(
  Iterable<Locale>? preferredLocales,
  Iterable<Locale> supportedLocales,
) {
  if (preferredLocales == null) {
    return defaultLocale;
  }

  final preferredLanguageCodes = preferredLocales.map((p) => p.languageCode);
  final supportedLanguageCodes = supportedLocales.map((s) => s.languageCode);
  final resolvedLanguageCode = preferredLanguageCodes.firstWhere(
    supportedLanguageCodes.contains,
    orElse: () => defaultLocale.languageCode,
  );

  return Locale(resolvedLanguageCode, '');
}
