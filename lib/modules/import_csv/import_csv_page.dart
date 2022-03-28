import 'package:flutter/material.dart';

import 'component/import_csv/import_csv_component.dart';

class ImportCSVPage extends StatelessWidget {
  const ImportCSVPage({Key? key}) : super(key: key);

  /// The name of the route to the [ImportCSVPage] screen.
  static const routeName = '/import/csv';

  @override
  Widget build(BuildContext context) => const ImportCSVComponent();
}
