import 'package:flutter/material.dart';

/// Determines the height of the bottom navigation bar.
double getBottomNavigationBarHeight(BuildContext context) {
  return MediaQuery.of(context).padding.bottom;
}
