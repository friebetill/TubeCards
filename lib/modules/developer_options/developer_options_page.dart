import 'package:flutter/material.dart';

import 'component/developer_options/developer_options_component.dart';

/// The screen shows all developer options.
class DeveloperOptionsPage extends StatelessWidget {
  const DeveloperOptionsPage({Key? key}) : super(key: key);

  /// The name of the route to the [DeveloperOptionsPage] screen.
  static const String routeName = '/profile/developer-options';

  @override
  Widget build(BuildContext context) => const DeveloperOptionsComponent();
}
