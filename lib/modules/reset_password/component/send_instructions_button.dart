import 'package:flutter/material.dart';

import '../../../i18n/i18n.dart';
import '../../../widgets/stadium_button.dart';
import '../../login/component/login_form/login_form_component.dart';

class SendInstructionsButton extends StatelessWidget {
  const SendInstructionsButton({
    required this.onTap,
    required this.isLoading,
    Key? key,
  }) : super(key: key);

  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widgetHeight,
      width: double.infinity,
      child: StadiumButton(
        text: S.of(context).sendInstructions.toUpperCase(),
        onPressed: onTap,
        backgroundColor: Theme.of(context).colorScheme.primary,
        textColor: Theme.of(context).colorScheme.onPrimary,
        boldText: true,
        isLoading: isLoading,
      ),
    );
  }
}
