import 'package:flutter/material.dart';

import '../../i18n/i18n.dart';
import '../../utils/custom_navigator.dart';
import '../../utils/tooltip_message.dart';
import '../../widgets/page_callback_shortcuts.dart';
import 'component/import/import_component.dart';

class ImportExportPage extends StatelessWidget {
  const ImportExportPage({Key? key}) : super(key: key);

  /// The name of the route to the [ImportExportPage].
  static const String routeName = '/import-export';

  @override
  Widget build(BuildContext context) {
    return PageCallbackShortcuts(
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).importAndExport),
          elevation: 0,
          leading: IconButton(
            icon: const BackButtonIcon(),
            onPressed: CustomNavigator.getInstance().pop,
            tooltip: backTooltip(context),
          ),
        ),
        body: const ImportExportComponent(),
      ),
    );
  }
}
