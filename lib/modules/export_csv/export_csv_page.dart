import 'package:flutter/material.dart';

import 'component/export_csv/export_csv_component.dart';

class ExportCSVPage extends StatelessWidget {
  const ExportCSVPage({Key? key}) : super(key: key);

  /// The name of the route to the [ExportCSVPage] screen.
  static const routeName = '/export/csv';

  @override
  Widget build(BuildContext context) => const ExportCSVComponent();
}
