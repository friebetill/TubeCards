import 'package:flutter/material.dart';

import '../../../../i18n/i18n.dart';
import '../../../utils/logging/visual_element_ids.dart';
import '../../../widgets/visual_element.dart';

class PracticeButton extends StatelessWidget {
  const PracticeButton({required this.onTap, Key? key}) : super(key: key);

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return VisualElement(
      id: VEs.practiceButton,
      childBuilder: (controller) {
        return Tooltip(
          message: S.of(context).practiceExplanation,
          child: TextButton(
            style: _getButtonStyle(context),
            onPressed: onTap != null
                ? () {
                    controller.logTap();
                    onTap!();
                  }
                : null,
            child: Text(S.of(context).practice.toUpperCase()),
          ),
        );
      },
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    final lightModeEnabled = Theme.of(context).brightness == Brightness.light;

    return ButtonStyle(
      foregroundColor: MaterialStateProperty.resolveWith<Color>(
        (states) => states.contains(MaterialState.disabled)
            ? Theme.of(context).disabledColor
            : (lightModeEnabled ? Colors.black : Colors.white),
      ),
      backgroundColor: MaterialStateProperty.all<Color>(
        lightModeEnabled ? Colors.grey.shade100 : const Color(0xFF2A2E35),
      ),
      padding: MaterialStateProperty.all(
        const EdgeInsets.fromLTRB(12, 4, 16, 4),
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
