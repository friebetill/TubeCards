import 'package:flutter/foundation.dart';

class ResetPasswordFormViewModel {
  ResetPasswordFormViewModel({
    required this.isLoading,
    required this.emailErrorText,
    required this.onEmailChange,
    required this.onSendInstructionsTap,
  });

  final bool isLoading;

  final String? emailErrorText;
  final ValueChanged<String> onEmailChange;
  final VoidCallback onSendInstructionsTap;
}
