import 'package:flutter/material.dart';

import 'component/join_shared_deck/join_shared_deck_component.dart';

/// The page on which the user can join a shared deck.
class JoinSharedDeckPage extends StatelessWidget {
  const JoinSharedDeckPage({Key? key}) : super(key: key);

  /// The name of the route to the [JoinSharedDeckPage] screen.
  static const String routeName = '/shared-deck/add';

  @override
  Widget build(BuildContext context) => const JoinSharedDeckComponent();
}
