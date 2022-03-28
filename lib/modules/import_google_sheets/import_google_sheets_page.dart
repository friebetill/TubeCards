import 'package:flutter/material.dart';

import 'component/import_google_sheets/import_google_sheets_component.dart';

class ImportGoogleSheetsPage extends StatelessWidget {
  const ImportGoogleSheetsPage({Key? key}) : super(key: key);

  /// The name of the route to the [ImportGoogleSheetsPage] screen.
  static const routeName = '/import/google-sheets';

  @override
  Widget build(BuildContext context) => const ImportGoogleSheetsComponent();
}
