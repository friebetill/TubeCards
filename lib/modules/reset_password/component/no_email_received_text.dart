import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../i18n/i18n.dart';
import '../../../utils/config.dart';
import '../../../utils/email.dart';
import '../../../utils/logging/visual_element_ids.dart';
import '../../../utils/snackbar.dart';
import '../../../widgets/visual_element.dart';

class NoEmailReceivedText extends StatelessWidget {
  const NoEmailReceivedText({required this.email, Key? key}) : super(key: key);

  final String email;

  @override
  Widget build(BuildContext context) {
    return VisualElement(
      id: VEs.noEmailReceivedButton,
      childBuilder: (controller) {
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: S.of(context).emailNotReceivedHelp1Text,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              TextSpan(
                  text: S.of(context).emailNotReceivedHelp2Text,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      controller.logTap();
                      _sendEmail(context);
                    }),
            ],
          ),
          textAlign: TextAlign.center,
        );
      },
    );
  }

  Future<void> _sendEmail(BuildContext context) async {
    try {
      await openEmailAppWithTemplate(
        email: supportEmail,
        subject: 'Problems resetting the password',
        body: 'Hey TubeCards Team,\n\n'
            "I'm having trouble resetting my account password "
            'with the email $email.\n\nBest regards',
      );
    } on Exception {
      ScaffoldMessenger.of(context).showErrorSnackBar(
        theme: Theme.of(context),
        text: S.of(context).errorSendEmailToSupportText(supportEmail),
      );
    }
  }
}
