import 'package:flutter/widgets.dart';

import 'component/nav_container/nav_container_component.dart';

/// This screen is the main screen of the mobile application.
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  /// The name of the route to the [HomePage] screen.
  static const routeName = '/';

  @override
  Widget build(BuildContext context) => const NavContainerComponent();
}
