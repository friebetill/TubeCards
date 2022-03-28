import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../../../i18n/i18n.dart';
import '../../../utils/email.dart';
import '../../../utils/logging/visual_element_ids.dart';
import '../../../utils/snackbar.dart';
import '../../../widgets/stadium_button.dart';
import '../../../widgets/visual_element.dart';
import '../../login/component/login_form/login_form_component.dart';

class OpenEmailButton extends StatelessWidget {
  OpenEmailButton({Key? key}) : super(key: key);

  final _logger = Logger((OpenEmailButton).toString());

  @override
  Widget build(BuildContext context) {
    return VisualElement(
      id: VEs.openEmailAppButton,
      childBuilder: (controller) {
        return SizedBox(
          height: widgetHeight,
          width: double.infinity,
          child: StadiumButton(
            text: S.of(context).openEmailApp.toUpperCase(),
            onPressed: () {
              controller.logTap();
              _openEmailApp(context);
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            textColor: Theme.of(context).colorScheme.onPrimary,
            boldText: true,
          ),
        );
      },
    );
  }

  Future<void> _openEmailApp(BuildContext context) async {
    try {
      await openEmailApp();
    } on Exception catch (e, s) {
      _logger.severe('Unexpected exception during open email', e, s);
      ScaffoldMessenger.of(context).showErrorSnackBar(
        theme: Theme.of(context),
        text: S.of(context).problemOpenEmailAppText,
      );
    }
  }
}
