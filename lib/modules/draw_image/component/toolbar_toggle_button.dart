import 'package:flutter/material.dart';

import '../../../utils/themes/custom_theme.dart';

class ToolbarToggleButton extends StatelessWidget {
  const ToolbarToggleButton({
    required this.icon,
    required this.onTap,
    required this.isToggled,
    required this.tooltip,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final VoidCallback? onTap;
  final bool isToggled;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final activeIconColor = theme.colorScheme.primary;
    final inactiveIconColor = theme.iconTheme.color;
    final disabledIconColor = theme.disabledColor;
    final activeIconBackgroundColor = theme.brightness == Brightness.light
        ? const Color(0xFFF4F8FE)
        : const Color(0xFF343D52);
    final inactiveIconBackgroundColor = theme.custom.elevation4DPColor;

    final isEnabled = onTap != null;
    final iconColor = isEnabled
        ? isToggled
            ? activeIconColor
            : inactiveIconColor
        : disabledIconColor;
    final backgroundColor =
        isToggled ? activeIconBackgroundColor : inactiveIconBackgroundColor;

    return SizedBox(
      width: 42,
      height: 42,
      child: Tooltip(
        message: tooltip,
        child: RawMaterialButton(
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          fillColor: backgroundColor,
          hoverElevation: 0,
          elevation: 0,
          highlightElevation: 0,
          onPressed: onTap,
          child: Icon(icon, color: iconColor),
        ),
      ),
    );
  }
}
