import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

import '../../data/anki_deck.dart';

class ImportOverviewViewModel {
  ImportOverviewViewModel({
    required this.decks,
    required this.deckCount,
    required this.cardCount,
    required this.onStartImportTap,
    required this.onToggleActiveDeckTap,
    required this.activeDecks,
  });

  final List<AnkiDeck>? decks;
  final BuiltMap<int, bool> activeDecks;
  final int? deckCount;
  final int? cardCount;

  final VoidCallback onStartImportTap;
  final void Function(bool, int) onToggleActiveDeckTap;
}
