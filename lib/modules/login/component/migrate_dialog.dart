import 'package:flutter/material.dart';

import '../../../i18n/i18n.dart';
import '../../../utils/custom_navigator.dart';

class MigrateDialog extends StatelessWidget {
  const MigrateDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).migrateDecks),
      content: Text(S.of(context).migrateInformation),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).textTheme.bodyText2!.color,
          ),
          onPressed: () => CustomNavigator.getInstance().pop(false),
          child: Text(S.of(context).discardCards.toUpperCase()),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => CustomNavigator.getInstance().pop(true),
          child: Text(S.of(context).migrate.toUpperCase()),
        ),
      ],
    );
  }
}
