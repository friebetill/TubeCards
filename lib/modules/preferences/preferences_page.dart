import 'package:flutter/material.dart';

import '../../i18n/i18n.dart';
import '../../utils/custom_navigator.dart';
import '../../utils/tooltip_message.dart';
import '../../widgets/page_callback_shortcuts.dart';
import 'component/preferences/preferences_component.dart';

/// The screen on which the profile of the user and the settings of the user
/// are displayed.
class PreferencesPage extends StatelessWidget {
  const PreferencesPage({Key? key}) : super(key: key);

  /// The name of the route to the [PreferencesPage] screen.
  static const String routeName = '/preferences';

  @override
  Widget build(BuildContext context) {
    return PageCallbackShortcuts(
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).preferences),
          elevation: 0,
          leading: IconButton(
            icon: const BackButtonIcon(),
            onPressed: CustomNavigator.getInstance().pop,
            tooltip: backTooltip(context),
          ),
        ),
        body: const PreferencesComponent(),
      ),
    );
  }
}
