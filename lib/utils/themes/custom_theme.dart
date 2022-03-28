import 'package:flutter/material.dart';

/// A custom theme covering the colors and typographic choices that are not
/// covered by [ThemeData].
class CustomThemeData {
  /// Returns a new [CustomThemeData] instance.
  const CustomThemeData({
    required this.successColor,
    required this.elevation4DPColor,
    required this.elevation8DPColor,
    required this.elevation10DPColor,
    required this.elevation24DPColor,
  });

  /// Color representing a successful action or status.
  final Color successColor;

  /// Color for the 4dp height.
  final Color elevation4DPColor;

  /// Color for the 8dp height.
  final Color elevation8DPColor;

  /// Color for the 10dp height.
  final Color elevation10DPColor;

  /// Color for the 24dp height.
  final Color elevation24DPColor;
}

extension ThemeDataExtensions on ThemeData {
  static final _custom = <Brightness, CustomThemeData>{};

  void addCustom(CustomThemeData custom) => _custom[brightness] = custom;

  CustomThemeData get custom => _custom[brightness]!;
}
