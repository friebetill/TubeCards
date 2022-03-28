import 'package:flutter/material.dart';

import 'component/import_anki/import_anki_component.dart';

class ImportAnkiPage extends StatelessWidget {
  const ImportAnkiPage({Key? key}) : super(key: key);

  /// The name of the route to the [ImportAnkiPage] screen.
  static const routeName = '/import/anki';

  @override
  Widget build(BuildContext context) => const ImportAnkiComponent();
}
