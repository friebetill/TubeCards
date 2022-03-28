import 'package:flutter/material.dart';

import 'themes/custom_theme.dart';

extension CustomSnackBars on ScaffoldMessengerState {
  /// Displays a snackbar containing a success [text].
  ///
  /// The color of the snack bar indicates a success.
  void showSuccessSnackBar({
    required String text,
    required ThemeData theme,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? snackBarAction,
  }) {
    removeCurrentSnackBar();

    showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: TextStyle(color: theme.snackBarTheme.actionTextColor),
        ),
        action: snackBarAction,
        backgroundColor: theme.custom.successColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Displays a snackbar containing an error [text].
  ///
  /// The color of the snack bar indicates an error.
  void showErrorSnackBar({
    required String text,
    required ThemeData theme,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? snackBarAction,
  }) {
    removeCurrentSnackBar();

    showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: TextStyle(color: theme.snackBarTheme.actionTextColor),
        ),
        action: snackBarAction,
        backgroundColor: theme.colorScheme.error,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
