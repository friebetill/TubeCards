import 'package:flutter/material.dart';

import '../../../data/models/role.dart';
import '../../../i18n/i18n.dart';

@immutable
class AccessRightsTileView extends StatelessWidget {
  const AccessRightsTileView({required this.userRole, Key? key})
      : super(key: key);

  final Role userRole;

  @override
  Widget build(BuildContext context) {
    if (userRole == Role.owner) {
      return Container();
    }

    final darkModeEnabled = Theme.of(context).brightness == Brightness.dark;
    const darkModeBlendColor = Color(0xbb2f2f2f);

    final backgroundColor = darkModeEnabled
        ? Color.alphaBlend(darkModeBlendColor, Colors.green.shade900)
        : Colors.green.shade100;
    final textColor =
        darkModeEnabled ? Colors.greenAccent.shade100 : Colors.green.shade900;

    final text = userRole == Role.viewer
        ? S.of(context).youHaveReadAccess
        : S.of(context).youHaveWriteAccess;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(Icons.info_outline, color: textColor),
              ],
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
