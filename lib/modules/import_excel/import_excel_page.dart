import 'package:flutter/material.dart';

import 'component/import_excel/import_excel_component.dart';

class ImportExcelPage extends StatelessWidget {
  const ImportExcelPage({Key? key}) : super(key: key);

  /// The name of the route to the [ImportExcelPage] screen.
  static const routeName = '/import/excel';

  @override
  Widget build(BuildContext context) => const ImportExcelComponent();
}
