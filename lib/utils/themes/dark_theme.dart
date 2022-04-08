import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'bottom_sheet_theme.dart';
import 'custom_theme.dart';
import 'page_transition_theme.dart';

/// The dark theme of the app
final ThemeData darkTheme = ThemeData(
  appBarTheme: const AppBarTheme(
    backgroundColor: _surfaceColor,
    foregroundColor: _onSurfaceColor,
  ),
  applyElevationOverlayColor: true,
  bottomSheetTheme: bottomSheetTheme.copyWith(
    backgroundColor: _surfaceColor,
    modalBackgroundColor: _surfaceColor,
  ),
  bottomAppBarTheme: const BottomAppBarTheme(color: _surfaceColor),
  brightness: Brightness.dark,
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    background: _surfaceColor,
    onBackground: _onSurfaceColor,
    error: const Color(0xFFCF6679),
    onError: _surfaceColor,
    primary: _primaryColor,
    primaryContainer: _primaryColor,
    onPrimary: _surfaceColor,
    secondary: _secondaryColor,
    secondaryContainer: _secondaryColor,
    onSecondary: _surfaceColor,
    surface: _surfaceColor,
    onSurface: _primaryColor,
  ),
  dialogTheme: const DialogTheme(
    elevation: 4,
    backgroundColor: _surfaceColor,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: _primaryColor,
  ),
  focusColor: const Color(0xFF394456),
  // Use a transparent color to make the splash color visible, because the
  // highlight color is drawn over the splash color, https://bit.ly/32fEBgr.
  highlightColor: const Color(0xAA394456),
  iconTheme: const IconThemeData(color: _onSurfaceColor),
  indicatorColor: _primaryColor,
  inputDecorationTheme: const InputDecorationTheme(border: InputBorder.none),
  pageTransitionsTheme: pageTransitionsTheme,
  popupMenuTheme: const PopupMenuThemeData(
    color: _surfaceColor,
  ),
  primaryTextTheme: const TextTheme(
    bodyText1: TextStyle(color: _onSurfaceColor),
  ),
  splashColor: const Color(0xFF394456),
  scaffoldBackgroundColor: _surfaceColor,
  selectedRowColor: const Color(0xFF394456),
  textTheme: const TextTheme(
    headline1: TextStyle(color: _onSurfaceColor),
    headline2: TextStyle(color: _onSurfaceColor),
    headline3: TextStyle(color: _onSurfaceColor),
    headline4: TextStyle(color: _onSurfaceColor),
    headline5: TextStyle(color: _onSurfaceColor),
    headline6: TextStyle(color: _onSurfaceColor),
    subtitle1: TextStyle(color: _onSurfaceColor),
    subtitle2: TextStyle(color: _onSurfaceColor),
    bodyText1: TextStyle(color: _onSurfaceColor),
    bodyText2: TextStyle(color: _onSurfaceColor),
    button: TextStyle(color: _onSurfaceColor),
    overline: TextStyle(color: _onSurfaceColor),
  ),
  toggleableActiveColor: _primaryColor,
)..addCustom(CustomThemeData(
    successColor: const Color(0xFF81AF84),
    elevation4DPColor: _elevationColor(_surfaceColor, 4),
    elevation8DPColor: _elevationColor(_surfaceColor, 8),
    elevation10DPColor: _elevationColor(_surfaceColor, 10),
    elevation24DPColor: _elevationColor(_surfaceColor, 24),
  ));

final _primaryColor = Colors.blueAccent.shade100;
final _secondaryColor = Colors.blueAccent.shade200;
const _surfaceColor = Color(0xFF1F2027);
const _onSurfaceColor = Colors.white;

/// Computes the elevation color for the given [color] and [elevation].
///
/// The computation is based on the material design, https://bit.ly/3yLRNFv.
Color _elevationColor(Color color, double elevation) {
  if (elevation > 0.0 && color.withOpacity(1) == _surfaceColor.withOpacity(1)) {
    final opacity = (4.5 * math.log(elevation + 1) + 2) / 100.0;

    return Color.alphaBlend(_primaryColor.withOpacity(opacity), color);
  }
  return color;
}
