import 'package:flutter/foundation.dart';

class SignUpFormViewModel {
  SignUpFormViewModel({
    required this.onFirstNameChanged,
    required this.onLastNameChanged,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.firstNameErrorText,
    required this.lastNameErrorText,
    required this.emailErrorText,
    required this.passwordErrorText,
    required this.obscurePassword,
    required this.onObscureTap,
    required this.onSignUpTap,
    required this.isLoading,
  });

  final ValueChanged<String> onFirstNameChanged;
  final ValueChanged<String> onLastNameChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;

  final String? firstNameErrorText;
  final String? lastNameErrorText;
  final String? emailErrorText;
  final String? passwordErrorText;

  final VoidCallback onObscureTap;
  final VoidCallback onSignUpTap;

  /// Whether we are currently waiting for a server response.
  final bool isLoading;

  /// Whether the password should be obscured or visible as plain text.
  final bool obscurePassword;
}
