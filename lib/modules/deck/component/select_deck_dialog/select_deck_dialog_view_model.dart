import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

import '../../../../data/models/deck.dart';

class SelectDeckDialogViewModel {
  SelectDeckDialogViewModel({
    required this.decks,
    required this.showLoadingIndicator,
    required this.fetchMore,
  });

  final BuiltList<Deck> decks;
  final bool showLoadingIndicator;

  final VoidCallback fetchMore;
}
