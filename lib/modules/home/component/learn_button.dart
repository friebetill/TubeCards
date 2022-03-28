import 'package:flutter/material.dart';

import '../../../i18n/i18n.dart';

class LearnButton extends StatelessWidget {
  const LearnButton({
    required this.strength,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  final double strength;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: S.of(context).learnDueCards,
      child: TextButton(
        style: ButtonStyle(
          foregroundColor: _foregroundColor(context),
          backgroundColor: _backgroundColor(context),
          padding: MaterialStateProperty.all(
            const EdgeInsets.fromLTRB(12, 4, 16, 4),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.whatshot, size: 20),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(S.of(context).learn.toUpperCase()),
                // To center the text on the button
                const SizedBox(height: 2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  MaterialStateProperty<Color> _foregroundColor(BuildContext context) {
    return MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.disabled)) {
        return Theme.of(context).disabledColor;
      } else if (strength < 0.25) {
        return Theme.of(context).colorScheme.onPrimary;
      } else if (strength < 0.75) {
        return Theme.of(context).brightness == Brightness.light
            ? Theme.of(context).colorScheme.onBackground
            : Theme.of(context).colorScheme.onPrimary;
      } else {
        return Theme.of(context).colorScheme.onPrimary;
      }
    });
  }

  MaterialStateProperty<Color> _backgroundColor(BuildContext context) {
    return MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.disabled)) {
        return Theme.of(context).brightness == Brightness.light
            ? Colors.grey.shade100
            : const Color(0xFF2A2E35);
      } else if (strength < 0.25) {
        return Theme.of(context).colorScheme.error;
      } else if (strength < 0.75) {
        return Theme.of(context).brightness == Brightness.light
            ? const Color(0xFFFFDB5C)
            : Colors.yellowAccent.shade100;
      } else {
        return Theme.of(context).colorScheme.primary;
      }
    });
  }
}
