import 'package:flutter/material.dart';

import '../../../utils/themes/custom_theme.dart';
import '../animations/slide_out_animation.dart';
import 'circular_notched_rectangle_shape.dart';

class LabelButton extends StatelessWidget {
  const LabelButton({
    required this.onPressed,
    required this.icon,
    required this.foregroundColor,
    required this.tooltip,
    required this.notchSide,
    this.hide = false,
    this.isEmphasized = false,
    this.animationDuration = shortAnimationDuration,
    Key? key,
  }) : super(key: key);

  final VoidCallback onPressed;

  final bool hide;

  final bool isEmphasized;

  final IconData icon;

  final Color foregroundColor;

  final String tooltip;

  final RectangleNotchSide notchSide;

  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    const notchDiameter = 68.0;
    const notchInset = notchDiameter / 4;
    final iconPadding = notchSide == RectangleNotchSide.left
        ? const EdgeInsets.only(left: notchInset / 2)
        : const EdgeInsets.only(right: notchInset / 2);

    final backgroundColor = Theme.of(context).custom.elevation10DPColor;

    return AnimatedOpacity(
      opacity: hide ? 0 : 1,
      duration: animationDuration,
      child: IgnorePointer(
        ignoring: hide,
        child: Tooltip(
          message: tooltip,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              elevation: 6,
              backgroundColor: isEmphasized ? foregroundColor : backgroundColor,
              shape: CircularNotchedRectangleShape(
                notchSide: notchSide,
                notchDiameter: notchDiameter,
              ),
            ),
            child: Padding(
              padding: iconPadding,
              child: Icon(
                icon,
                color: isEmphasized ? backgroundColor : foregroundColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
