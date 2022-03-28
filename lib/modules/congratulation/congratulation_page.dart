import 'package:flutter/material.dart';

import 'congratulation/congratulation_component.dart';

/// The page to display when the user has completed a review session.
class CongratulationPage extends StatelessWidget {
  const CongratulationPage({Key? key}) : super(key: key);

  /// The name of the route to the [CongratulationPage] screen.
  static const String routeName = '/learn/congratulations';

  @override
  Widget build(BuildContext context) => const CongratulationComponent();
}
