import 'package:flutter/material.dart';

import '../../../utils/themes/custom_theme.dart';
import '../animations/slide_out_animation.dart';

class FlipButton extends StatelessWidget {
  const FlipButton({
    required this.onPressed,
    required this.tooltip,
    this.isEmphasized = false,
    this.animationDuration = shortAnimationDuration,
    Key? key,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String tooltip;
  final bool isEmphasized;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).custom.elevation10DPColor;

    return Tooltip(
      message: tooltip,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 6,
          shape: const CircleBorder(),
          // To remove a 1px lighter color border in dark mode
          backgroundColor: isEmphasized ? foregroundColor : backgroundColor,
        ),
        child: AnimatedContainer(
          height: 56,
          width: 56,
          duration: animationDuration,
          decoration: BoxDecoration(
            color: isEmphasized ? foregroundColor : backgroundColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(
            Icons.threesixty,
            color: isEmphasized ? backgroundColor : foregroundColor,
          ),
        ),
      ),
    );
  }
}
