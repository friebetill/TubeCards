import 'package:flutter/material.dart';

import 'component/landing/landing_component.dart';

/// The page where the user lands when they open the app for the first time.
///
/// On the screen the user can log in, create an account or use TubeCards
/// without an account.
class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  /// The name of the route to the [LandingPage].
  static const String routeName = '/landing';

  @override
  Widget build(BuildContext context) => const LandingComponent();
}
