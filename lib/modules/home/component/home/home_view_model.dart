import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

import '../../../../data/models/deck.dart';

class HomeViewModel {
  HomeViewModel({
    required this.strength,
    required this.totalDueCardsCount,
    required this.totalCardsCount,
    required this.activeDecks,
    required this.inactiveDecks,
    required this.activeDeckState,
    required this.showLoadingIndicator,
    required this.onActiveStateChanged,
    required this.refresh,
    required this.fetchMore,
    required this.onReviewTap,
  });

  final double strength;
  final int totalDueCardsCount;
  final int totalCardsCount;
  final BuiltList<Deck> activeDecks;
  final BuiltList<Deck> inactiveDecks;
  final ActiveState activeDeckState;
  final bool showLoadingIndicator;

  final ValueChanged<ActiveState?> onActiveStateChanged;
  final AsyncCallback refresh;
  final VoidCallback fetchMore;
  final VoidCallback? onReviewTap;
}

enum ActiveState {
  active,
  inactive,
}
