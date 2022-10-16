import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:tubecards/i18n/i18n.dart';
import 'package:tubecards/utils/themes/dark_theme.dart';
import 'package:tubecards/utils/themes/light_theme.dart';

// Wraps the widget under test in a MaterialApp that uses our light theme.
WidgetWrapper lightThemeWrapper = materialAppWrapper(
  theme: lightTheme,
  localizations: const [S.delegate],
);

// Wraps the widget under test in a MaterialApp that uses our dark theme.
WidgetWrapper darkThemeWrapper = materialAppWrapper(
  theme: darkTheme,
  localizations: const [S.delegate],
);
