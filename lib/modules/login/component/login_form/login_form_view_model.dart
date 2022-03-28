import 'package:flutter/foundation.dart';

class LoginFormViewModel {
  LoginFormViewModel({
    required this.isLoading,
    required this.obscurePassword,
    required this.emailErrorText,
    required this.passwordErrorText,
    required this.onToggleObscurePassword,
    required this.onLogInTap,
    required this.onClose,
    required this.onEmailChange,
    required this.onPasswordChange,
    required this.onResetPassword,
    required this.onSignUpTap,
  });

  final bool isLoading;
  final bool obscurePassword;

  final String? emailErrorText;
  final ValueChanged<String> onEmailChange;

  final String? passwordErrorText;
  final ValueChanged<String> onPasswordChange;

  final VoidCallback onClose;
  final VoidCallback onLogInTap;
  final VoidCallback onToggleObscurePassword;
  final VoidCallback onResetPassword;
  final VoidCallback onSignUpTap;
}
