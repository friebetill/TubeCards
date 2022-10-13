import 'package:flutter/material.dart';

import '../../../i18n/i18n.dart';
import '../../../utils/custom_navigator.dart';

class MakeOwnerDialog extends StatelessWidget {
  const MakeOwnerDialog({required this.fullName, Key? key}) : super(key: key);

  final String fullName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).makeOwner),
      content: Text(
        S.of(context).makeOwnerCautionText(fullName),
      ),
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
          child: Text(S.of(context).makeOwner.toUpperCase()),
        ),
      ],
    );
  }
}
