import 'package:flutter/material.dart';

import '../../../i18n/i18n.dart';
import '../../../utils/custom_navigator.dart';

class LeaveDialog extends StatelessWidget {
  const LeaveDialog({required this.deckName, Key? key}) : super(key: key);

  final String deckName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).leaveDeck),
      content: Text(S.of(context).leaveDeckCautionText(deckName)),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).textTheme.bodyText2!.color,
          ),
          onPressed: () => CustomNavigator.getInstance().pop(false),
          child: Text(S.of(context).cancel.toUpperCase()),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => CustomNavigator.getInstance().pop(true),
          child: Text(S.of(context).leave.toUpperCase()),
        ),
      ],
    );
  }
}
