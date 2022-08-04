import 'package:flutter/material.dart';

import '../../../i18n/i18n.dart';
import '../../../widgets/stadium_text_field.dart';

class PasswordField extends StatefulWidget {
  const PasswordField(
    this.onChanged,
    this.errorText,
    this.passwordFocus,
    this.onSubmitted,
    this.onObscureToggle, {
    required this.obscurePassword,
    Key? key,
  }) : super(key: key);

  final VoidCallback onSubmitted;
  final bool obscurePassword;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final FocusNode passwordFocus;
  final VoidCallback onObscureToggle;

  @override
  PasswordFieldState createState() => PasswordFieldState();
}

class PasswordFieldState extends State<PasswordField> {
  final _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StadiumTextField(
      key: const ValueKey('password-field'),
      controller: _textEditingController,
      placeholder: S.of(context).password,
      textInputAction: TextInputAction.done,
      focusNode: widget.passwordFocus,
      onFieldSubmitted: (term) {
        widget.passwordFocus.unfocus();
        widget.onSubmitted();
      },
      suffixIcon: _buildSuffixIcon(context),
      obscureText: widget.obscurePassword,
      errorText: widget.errorText,
      onChanged: widget.onChanged,
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Widget _buildSuffixIcon(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 12),
      child: IconButton(
        icon: Icon(
          widget.obscurePassword ? Icons.visibility_off : Icons.visibility,
          color: Theme.of(context).iconTheme.color,
        ),
        onPressed: widget.onObscureToggle,
        tooltip: widget.obscurePassword
            ? S.of(context).showPassword
            : S.of(context).passwordHide,
      ),
    );
  }
}
