import 'package:flutter/material.dart';

import 'bottom_sheet_theme.dart';
import 'custom_theme.dart';
import 'page_transition_theme.dart';

/// The light theme of the app.
final ThemeData lightTheme = ThemeData(
  appBarTheme: AppBarTheme(
    backgroundColor: _surfaceColor,
    foregroundColor: Colors.grey.shade900,
  ),
  applyElevationOverlayColor: false,
  bottomSheetTheme: bottomSheetTheme.copyWith(
    backgroundColor: _surfaceColor,
    modalBackgroundColor: _surfaceColor,
  ),
  bottomAppBarTheme: const BottomAppBarTheme(color: _surfaceColor),
  brightness: Brightness.light,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    background: _surfaceColor,
    onBackground: Colors.black,
    error: const Color(0xFFB00020),
    onError: _surfaceColor,
    primary: _primaryColor,
    primaryContainer: _primaryColor,
    onPrimary: _surfaceColor,
    secondary: _secondaryColor,
    secondaryContainer: _secondaryColor,
    onSecondary: _surfaceColor,
    surface: _surfaceColor,
    onSurface: _onSurfaceColor,
  ),
  dialogTheme: const DialogTheme(
    elevation: 4,
    backgroundColor: _surfaceColor,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: _primaryColor,
  ),
  iconTheme: IconThemeData(color: Colors.grey.shade700),
  indicatorColor: _primaryColor,
  inputDecorationTheme: const InputDecorationTheme(border: InputBorder.none),
  pageTransitionsTheme: pageTransitionsTheme,
  popupMenuTheme: const PopupMenuThemeData(
    color: _surfaceColor,
  ),
  primaryTextTheme: TextTheme(
    bodyText1: TextStyle(color: Colors.grey.shade900),
    subtitle1: TextStyle(color: Colors.grey.shade900),
  ),
  selectedRowColor: const Color(0xFFE8F0FD),
  scaffoldBackgroundColor: _surfaceColor,
  textTheme: TextTheme(
    headline4: TextStyle(color: Colors.grey.shade900),
  ),
  toggleableActiveColor: _primaryColor,
)..addCustom(const CustomThemeData(
    successColor: Color(0xFF2E7B32),
    elevation4DPColor: _surfaceColor,
    elevation8DPColor: _surfaceColor,
    elevation10DPColor: _surfaceColor,
    elevation24DPColor: _surfaceColor,
  ));

final _primaryColor = Colors.blue.shade700;
final _secondaryColor = Colors.blueAccent.shade700;
const _surfaceColor = Colors.white;
const _onSurfaceColor = Colors.black87;
