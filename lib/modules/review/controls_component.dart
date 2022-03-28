import 'dart:io';

import 'package:flutter/material.dart';

import '../../i18n/i18n.dart';
import '../../utils/themes/custom_theme.dart';
import 'component/circular_notched_rectangle_shape.dart';
import 'component/flip_button.dart';
import 'component/label_button.dart';

/// Height of the control buttons area.
const _controlButtonsHeight = 70.0;

class ControlsComponent extends StatelessWidget {
  const ControlsComponent({
    required this.isFrontSide,
    required this.emphasizeKnownCardLabelButton,
    required this.emphasizeUnknownCardLabelButton,
    required this.onFlipTap,
    required this.onCardKnownTap,
    required this.onCardNotKnownTap,
    Key? key,
  }) : super(key: key);

  final bool isFrontSide;
  final bool emphasizeKnownCardLabelButton;
  final bool emphasizeUnknownCardLabelButton;

  final VoidCallback onFlipTap;
  final VoidCallback onCardKnownTap;
  final VoidCallback onCardNotKnownTap;

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        Platform.isWindows || Platform.isMacOS || Platform.isLinux;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700),
      child: SizedBox(
        height: _controlButtonsHeight,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(right: 18, left: 32),
                    height: _controlButtonsHeight,
                    child: _buildNotknownButton(context),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 18, right: 32),
                    height: _controlButtonsHeight,
                    child: _buildCardKnownButton(context),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 7,
              child: FlipButton(
                onPressed: onFlipTap,
                tooltip: S.of(context).flipCard + (isDesktop ? ' (space)' : ''),
                isEmphasized: isFrontSide,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardKnownButton(BuildContext context) {
    final isDesktop =
        Platform.isWindows || Platform.isMacOS || Platform.isLinux;

    return LabelButton(
      onPressed: onCardKnownTap,
      hide: isFrontSide,
      isEmphasized: emphasizeKnownCardLabelButton,
      icon: Icons.check,
      foregroundColor: Theme.of(context).custom.successColor,
      notchSide: RectangleNotchSide.left,
      tooltip: S.of(context).labelTheCardAsKnown + (isDesktop ? ' (f)' : ''),
    );
  }

  Widget _buildNotknownButton(BuildContext context) {
    final isDesktop =
        Platform.isWindows || Platform.isMacOS || Platform.isLinux;

    return LabelButton(
      onPressed: onCardNotKnownTap,
      hide: isFrontSide,
      isEmphasized: emphasizeUnknownCardLabelButton,
      icon: Icons.close,
      foregroundColor: Theme.of(context).colorScheme.error,
      notchSide: RectangleNotchSide.right,
      tooltip: S.of(context).labelTheCardAsNotKnown + (isDesktop ? ' (a)' : ''),
    );
  }
}
