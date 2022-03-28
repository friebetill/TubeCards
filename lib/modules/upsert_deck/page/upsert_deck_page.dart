import 'package:flutter/material.dart';

import '../component/upsert_deck/upsert_deck_component.dart';

/// The screen with which the user can add (insert) or update a deck.
class UpsertDeckPage extends StatelessWidget {
  /// Returns an instance of UpsertDeck.
  ///
  /// If no [deckId] is passed, a new deck is added with this screen.
  const UpsertDeckPage({this.deckId, Key? key}) : super(key: key);

  /// The name of the route to insert a deck on the [UpsertDeckPage] screen.
  static const String routeNameAdd = '/deck/add';

  /// The name of the route to update a deck on the [UpsertDeckPage] screen.
  static const String routeNameEdit = '/deck/edit';

  /// The existing deck in case we are editing a deck.
  final String? deckId;

  @override
  Widget build(BuildContext context) {
    return UpsertDeckComponent(deckId: deckId);
  }
}
