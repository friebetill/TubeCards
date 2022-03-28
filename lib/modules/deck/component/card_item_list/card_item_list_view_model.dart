import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

import '../../../../data/models/card.dart';

class CardItemListViewModel {
  CardItemListViewModel({
    required this.cards,
    required this.showInitialLoadingIndicator,
    required this.showContinuationsLoadingIndicator,
    required this.fetchMore,
  });

  final BuiltList<Card> cards;

  /// True when the cards are initially loaded
  ///
  /// Includes the initial loading when the sort order is changed and the
  /// cards weren't previously downloaded in this sort order.
  final bool showInitialLoadingIndicator;

  /// True if the next page of data exist
  final bool showContinuationsLoadingIndicator;

  final VoidCallback fetchMore;
}
