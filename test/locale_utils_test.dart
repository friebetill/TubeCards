import 'dart:ui';

import 'package:test/test.dart';
import 'package:tubecards/utils/locale_utils.dart';

void main() {
  const kFirstLocale = Locale('abc', '');
  const kSecondLocale = Locale('def', '');
  const kLocales = <Locale>[kFirstLocale, kSecondLocale];

  test('Returns default locale when preferred locales null', () {
    final locale = getBestMatchingSupportedLocale(null, kLocales);
    expect(locale, equals(defaultLocale));
  });

  test('Returns default locale when preferred locales empty', () {
    final locale = getBestMatchingSupportedLocale([], kLocales);
    expect(locale, equals(defaultLocale));
  });

  test('Returns default locale when supported locales empty', () {
    final locale = getBestMatchingSupportedLocale(kLocales, []);
    expect(locale, equals(defaultLocale));
  });

  test('Returns default locale on no matches', () {
    final locale =
        getBestMatchingSupportedLocale([kFirstLocale], [kSecondLocale]);
    expect(locale, equals(defaultLocale));
  });

  test('Returns first matching locale', () {
    final firstMatchingLocale =
        getBestMatchingSupportedLocale([kFirstLocale], kLocales);
    final secondMatchingLocale =
        getBestMatchingSupportedLocale([kSecondLocale], kLocales);
    expect(firstMatchingLocale, equals(kFirstLocale));
    expect(secondMatchingLocale, equals(kSecondLocale));
  });

  test('Removes country code if it is not supported', () {
    const kFirstLocaleWithCountryCode = Locale('abc', 'COUNTRY_CODE');
    final locale = getBestMatchingSupportedLocale(
      <Locale>[kFirstLocaleWithCountryCode],
      kLocales,
    );
    expect(locale, equals(kFirstLocale));
  });
}
