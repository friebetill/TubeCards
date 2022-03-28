import 'package:flutter/foundation.dart';

class AppBarViewModel {
  AppBarViewModel({
    required this.title,
    required this.progress,
    required this.isTextToSpeechEnabled,
    required this.onEditTap,
    required this.onTextToSpeechToggleTap,
    required this.onBackTap,
  });

  final String title;
  final double progress;
  final bool isTextToSpeechEnabled;
  final VoidCallback? onEditTap;
  final VoidCallback? onTextToSpeechToggleTap;
  final VoidCallback onBackTap;
}
