import 'package:flutter/material.dart';

import '../../utils/custom_navigator.dart';
import '../../utils/tooltip_message.dart';
import '../../widgets/page_callback_shortcuts.dart';
import 'component/account/account_component.dart';

/// The screen on which the profile of the user and the settings of the user
/// are displayed.
class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  /// The name of the route to the [AccountPage].
  static const String routeName = '/account';

  @override
  Widget build(BuildContext context) {
    return PageCallbackShortcuts(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_outlined),
            onPressed: CustomNavigator.getInstance().pop,
            tooltip: closeTooltip(context),
          ),
          elevation: 0,
        ),
        body: const AccountComponent(),
      ),
    );
  }
}
