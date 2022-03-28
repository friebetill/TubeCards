import 'package:flutter/material.dart';

import '../../../utils/themes/custom_theme.dart';

class ToolbarIconButton extends StatelessWidget {
  const ToolbarIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor = theme.custom.elevation4DPColor;
    final iconColor =
        onTap == null ? theme.disabledColor : theme.iconTheme.color;

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
