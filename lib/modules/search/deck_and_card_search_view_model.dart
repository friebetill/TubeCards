import 'package:flutter/foundation.dart';

import '../../data/models/card.dart';
import '../../data/models/connection.dart';
import '../../data/models/deck.dart';

class DeckAndCardSearchViewModel {
  DeckAndCardSearchViewModel({
    required this.deckConnection,
    required this.cardConnection,
    required this.recentSearchTerms,
    required this.addSearchTerm,
    required this.fetchMoreDecks,
    required this.fetchMoreCards,
  });

  final Connection<Deck>? deckConnection;
  final Connection<Card>? cardConnection;
  final List<String> recentSearchTerms;

  final ValueChanged<String> addSearchTerm;
  final VoidCallback fetchMoreDecks;
  final VoidCallback fetchMoreCards;
}
