import 'package:flutter/material.dart';

/// A widget that represents a rounded button, similar in shape to a aerial
/// view of a stadium.
class StadiumButton extends StatelessWidget {
  /// Creates an instance of a [StadiumButton].
  const StadiumButton({
    required this.text,
    required this.onPressed,
    Key? key,
    this.textColor,
    this.fontSize = 14,
    this.boldText = false,
    this.backgroundColor,
    this.gradient,
    this.borderColor,
    this.elevation = 4,
    this.isLoading = false,
    this.padding,
  }) : super(key: key);

  /// Text to be displayed on the button.
  final String text;

  /// Function called after pressing the button.
  final VoidCallback? onPressed;

  /// Color of the text.
  final Color? textColor;

  /// Font size of the button text
  final double fontSize;

  /// Whether the button text should be bold
  final bool boldText;

  /// Color of the button.
  final Color? backgroundColor;

  /// Gradient that is placed on the background of the button.
  final RadialGradient? gradient;

  /// Color of the border of the button
  final Color? borderColor;

  /// Elevation of the button and therefore controls how much shadow the button
  /// casts.
  final double elevation;

  /// Displays a load animation instead of the text if [isLoading] is true.
  final bool isLoading;

  final EdgeInsetsGeometry? padding;

  Widget _buildLoadingIndicator(Color foregroundColor) {
    return SizedBox(
      height: fontSize * 1.2,
      width: fontSize * 1.2,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildText(Color foregroundColor) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: foregroundColor,
        fontWeight: boldText ? FontWeight.w500 : FontWeight.w400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final foregroundColor =
        textColor ?? Theme.of(context).buttonTheme.colorScheme!.primary;

    return TextButton(
      style: TextButton.styleFrom(
        shape: const StadiumBorder(),
        elevation: elevation,
        padding: padding,
        side: BorderSide(
          width: 2,
          color: borderColor ?? Colors.transparent,
        ),
        backgroundColor: backgroundColor,
      ),
      onPressed: onPressed,
      child: isLoading
          ? _buildLoadingIndicator(foregroundColor)
          : _buildText(foregroundColor),
    );
  }
}

/// [StadiumButton] with an icon in front of the text.
class IconStadiumButton extends StatelessWidget {
  /// Creates an instance of a [StadiumButton].
  const IconStadiumButton({
    required this.text,
    required this.icon,
    required this.onPressed,
    Key? key,
    this.textColor,
    this.fontSize = 14,
    this.boldText = false,
    this.tooltip = '',
    this.backgroundColor,
    this.borderColor,
    this.elevation = 4,
    this.isLoading = false,
  }) : super(key: key);

  /// Text to be displayed on the button.
  final String text;

  /// Icon to be displayed as a prefix.
  final Icon icon;

  /// Function called after pressing the button.
  final VoidCallback? onPressed;

  /// Color of the text.
  final Color? textColor;

  /// Font size of the button text
  final double fontSize;

  /// Whether the button text should be bold
  final bool boldText;

  /// Text that describes the action that will occur when the button is pressed.
  final String tooltip;

  /// Color of the button.
  final Color? backgroundColor;

  /// Color of the border of the button
  final Color? borderColor;

  /// Elevation of the button and therefore controls how much shadow the button
  /// casts.
  final double elevation;

  /// Displays a load animation instead of the text if [isLoading] is true.
  final bool isLoading;

  Widget _buildLoadingIndicator(Color foregroundColor) {
    return SizedBox(
      height: fontSize * 1.2,
      width: fontSize * 1.2,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildText(Color foregroundColor) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: foregroundColor,
        fontWeight: boldText ? FontWeight.w500 : FontWeight.w400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final foregroundColor =
        textColor ?? Theme.of(context).buttonTheme.colorScheme!.primary;

    return Tooltip(
      message: tooltip,
      child: TextButton.icon(
        icon: icon,
        style: TextButton.styleFrom(
          shape: const StadiumBorder(),
          elevation: elevation,
          side: BorderSide(
            width: 2,
            color: borderColor ?? Colors.transparent,
          ),
          backgroundColor: backgroundColor,
        ),
        onPressed: onPressed,
        label: isLoading
            ? _buildLoadingIndicator(foregroundColor)
            : _buildText(foregroundColor),
      ),
    );
  }
}
