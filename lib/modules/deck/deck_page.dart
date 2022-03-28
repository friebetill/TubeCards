import 'package:flutter/material.dart';

import 'component/deck/deck_component.dart';

/// The screen that gives the user an overview of a specific deck.
class DeckPage extends StatelessWidget {
  /// Creates the deck page which provides the user with information about the
  /// deck with the given [deck].
  DeckPage(this.args) : super(key: args.key);

  /// The name of the route to the [DeckPage] screen.
  static const String routeName = '/deck';

  final DeckArguments args;

  @override
  Widget build(BuildContext context) => DeckComponent(args);
}

/// Bundles the arguments of [DeckPage] into one object.
///
/// This allows us to use multiple parameters on Named Routes.
/// See more about this here https://flutter.dev/docs/cookbook/navigation/navigate-with-arguments.
class DeckArguments {
  /// Returns an instance of [DeckArguments].
  DeckArguments({
    required this.deckId,
    required this.hasCardUpsertPermission,
    this.key,
  });

  /// The ID of the deck whose information is displayed on the screen.
  final String deckId;

  final bool hasCardUpsertPermission;

  /// Controls how one widget replaces another widget in the tree.
  final Key? key;
}
