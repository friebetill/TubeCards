import 'package:flutter/material.dart';

import 'component/select_deck/select_deck_component.dart';

class SelectDeckPage extends StatelessWidget {
  const SelectDeckPage({Key? key}) : super(key: key);

  /// The name of the route to the [SelectDeckPage] screen.
  static const String routeName = '/marketplace/select-deck';

  @override
  Widget build(BuildContext context) => const SelectDeckComponent();
}
