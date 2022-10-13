import 'package:flutter/material.dart';

import '../../../i18n/i18n.dart';
import '../../../utils/custom_navigator.dart';

class DiscardDialog extends StatelessWidget {
  const DiscardDialog({required this.isEdit, Key? key}) : super(key: key);

  final bool isEdit;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        isEdit ? S.of(context).discardEdits : S.of(context).discardImage,
      ),
      content: Text(isEdit
          ? S.of(context).discardEditsText
          : S.of(context).discardImageText),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).textTheme.bodyText1!.color,
          ),
          onPressed: () => CustomNavigator.getInstance().pop(false),
          child: Text(S.of(context).cancel.toUpperCase()),
        ),
        TextButton(
          onPressed: () => CustomNavigator.getInstance().pop(true),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(S.of(context).discard.toUpperCase()),
        ),
      ],
    );
  }
}
