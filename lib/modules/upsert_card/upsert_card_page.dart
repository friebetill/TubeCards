import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'component/upsert_card/upsert_card_component.dart';

/// The screen with which the user can add (insert) or update a card.
///
/// Returns the edited card or null if the card was deleted.
class UpsertCardPage extends StatelessWidget {
  UpsertCardPage(this.args) : super(key: args.key);

  /// The name of the route to insert a card on the [UpsertCardPage] screen.
  static const String routeNameAdd = '/card/add';

  /// The name of the route to update a card on the [UpsertCardPage] screen.
  static const String routeNameEdit = '/card/edit';

  /// The arguments this class can get.
  final UpsertCardArguments args;

  @override
  Widget build(BuildContext context) {
    return UpsertCardComponent(
      deckId: args.deckId,
      cardId: args.cardId,
      isFrontSide: args.isFrontSide,
    );
  }
}

/// Bundles the arguments of [UpsertCardPage] into one object.
///
/// This allows us to use multiple parameters on Named Routes.
/// See more about this here https://bit.ly/3ifEOpa.
class UpsertCardArguments {
  /// Returns an instance of [UpsertCardArguments].
  UpsertCardArguments({
    required this.deckId,
    this.key,
    this.cardId,
    this.isFrontSide = true,
  });

  /// Controls how one widget replaces another widget in the tree.
  final Key? key;

  final String deckId;

  /// The card that will be inserted or updated.
  ///
  /// If the card has no deck, the user will be prompted to select
  /// a deck when the screen is rendered for the first time.
  final String? cardId;

  /// Whether the front side of the flashcard is shown.
  final bool isFrontSide;
}
