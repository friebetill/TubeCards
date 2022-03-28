import 'package:flutter/material.dart';

/// Page transitions for each target platform used for all themes.
const PageTransitionsTheme pageTransitionsTheme = PageTransitionsTheme(
  builders: {
    // Android 10 style transition
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    // Default transition on iOS
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
  },
);
