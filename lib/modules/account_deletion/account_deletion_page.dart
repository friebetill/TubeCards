import 'package:flutter/material.dart';

import 'component/account_deletion/account_deletion_component.dart';

/// The screen allows the user to delete their own account.
class AccountDeletionPage extends StatelessWidget {
  const AccountDeletionPage({Key? key}) : super(key: key);

  /// The name of the route to the [AccountDeletionPage] screen.
  static const String routeName = '/preferences/account-deletion';

  @override
  Widget build(BuildContext context) => const AccountDeletionComponent();
}
