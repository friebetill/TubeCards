import 'package:flutter/foundation.dart';

class FeedbackViewModel {
  FeedbackViewModel({
    required this.feedbackErrorText,
    required this.emailErrorText,
    required this.isSending,
    required this.isUserAnonymous,
    required this.onSendEmailTap,
    required this.onFeedbackTextChange,
    required this.onEmailTextChange,
  });

  final String? feedbackErrorText;
  final String? emailErrorText;
  final bool isUserAnonymous;
  final bool isSending;

  final VoidCallback onSendEmailTap;
  final ValueChanged<String> onFeedbackTextChange;
  final ValueChanged<String> onEmailTextChange;
}
