import 'package:flutter/material.dart';

/// A widget that represents a rounded [TextField], similar in shape to a
/// aerial view of a stadium.
class StadiumTextField extends StatefulWidget {
  /// Returns an instance of [StadiumTextField].
  const StadiumTextField({
    required this.controller,
    this.onFieldSubmitted,
    this.focusNode,
    this.textInputAction,
    this.validator,
    this.errorText,
    this.onChanged,
    this.autofillHints,
    this.obscureText = false,
    this.placeholder,
    this.keyboardType,
    this.hasFloatingPlaceholder = true,
    this.autoValidateMode = AutovalidateMode.disabled,
    this.autoFocus = false,
    this.prefixIcon,
    this.suffixIcon,
    this.textCapitalization = TextCapitalization.none,
    Key? key,
  }) : super(key: key);

  /// Controls the text being edited.
  final TextEditingController controller;

  /// If the user indicates that they are done typing in the field (e.g., by
  /// pressing a button on the soft keyboard), the text field calls the
  /// [onFieldSubmitted] callback.
  final ValueChanged<String>? onFieldSubmitted;

  /// Defines the keyboard focus for this widget.
  ///
  /// The [focusNode] is a long-lived object that's typically managed by a
  /// [StatefulWidget] parent. See [FocusNode] for more information.
  ///
  /// To give the keyboard focus to this widget, provide a [focusNode] and then
  /// use the current [FocusScope] to request the focus:
  final FocusNode? focusNode;

  /// The type of action button to use for the keyboard.
  ///
  /// Defaults to [TextInputAction.newline] if [keyboardType] is
  /// [TextInputType.multiline] and [TextInputAction.done] otherwise.
  final TextInputAction? textInputAction;

  /// An optional method that validates an input. Returns an error string to
  /// display if the input is invalid, or null otherwise.
  final FormFieldValidator<String>? validator;

  /// Text that appears below the input and the border.
  ///
  /// This is overridden by the value returned from [validator], if that is
  /// not null.
  final String? errorText;

  final void Function(String)? onChanged;

  /// A list of strings that helps the autofill service identify the type of
  /// this text input.
  final Iterable<String>? autofillHints;

  /// Decides if the text should be displayed obscured, especially useful for
  /// password fields.
  final bool obscureText;

  /// Text that describes the input field.
  ///
  /// When the input field is empty and unfocused, the label is displayed on
  /// top of the input field (i.e., at the same location on the screen where
  /// text may be entered in the input field). When the input field receives
  /// focus (or if the field is non-empty), the label moves above (i.e.,
  /// vertically adjacent to) the input field.
  final String? placeholder;

  /// The type of information for which to optimize the text input control.
  ///
  /// Can be text, multiline, number, phone, datetime, emailAddress and url.
  final TextInputType? keyboardType;

  /// Whether the label floats on focus.
  ///
  /// If this is false, the placeholder disappears when the input has focus or
  /// inputted text.
  /// If this is true, the placeholder will rise to the top of the input when
  /// the input has focus or inputted text.
  ///
  /// Defaults to true.
  final bool hasFloatingPlaceholder;

  /// Used to configure the auto validation.
  final AutovalidateMode autoValidateMode;

  /// Whether or not the TextField is focused on start.
  final bool autoFocus;

  final Widget? prefixIcon;

  final Widget? suffixIcon;

  /// Configures how the platform keyboard will select an uppercase or
  /// lowercase keyboard.
  final TextCapitalization textCapitalization;

  @override
  StadiumTextFieldState createState() => StadiumTextFieldState();
}

class StadiumTextFieldState extends State<StadiumTextField> {
  /// Whether the text field currently has focus.
  bool _hasFocus = false;

  /// Focus node used to determine whether the text field has focus.
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    if (widget.autoFocus) {
      setState(() {
        _hasFocus = true;
      });
    }

    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fillColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2A2E35)
        : Colors.grey.shade100;

    return TextFormField(
      controller: widget.controller,
      textInputAction: widget.textInputAction,
      focusNode: widget.focusNode,
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: widget.validator,
      onChanged: widget.onChanged,
      autofillHints: widget.autofillHints,
      keyboardType: widget.keyboardType,
      autovalidateMode: widget.autoValidateMode,
      autofocus: widget.autoFocus,
      textCapitalization: widget.textCapitalization,
      decoration: InputDecoration(
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        labelText: widget.placeholder,
        errorText: widget.errorText,
        floatingLabelBehavior: widget.hasFloatingPlaceholder
            ? FloatingLabelBehavior.auto
            : FloatingLabelBehavior.never,
        labelStyle: _hasFocus
            ? TextStyle(color: Theme.of(context).colorScheme.primary)
            : null,
        filled: !_hasFocus && widget.controller.text.isEmpty,
        fillColor: fillColor,
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(widget.controller.text.isEmpty ? 28 : 26),
          borderSide: BorderSide(
            width: 2,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.grey.shade200
                : Theme.of(context).hintColor.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: BorderSide(
            width: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: BorderSide(
            width: 2,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: BorderSide(
            width: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
      obscureText: widget.obscureText,
    );
  }
}
