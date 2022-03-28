import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

import '../../../../data/models/deck.dart';

class SelectDeckViewModel {
  const SelectDeckViewModel({
    required this.isAnonymous,
    required this.decks,
    required this.onDeckSelect,
    required this.onCreateAccountTap,
  });

  final bool isAnonymous;
  final BuiltList<Deck> decks;
  final ValueSetter<Deck>? onDeckSelect;
  final VoidCallback onCreateAccountTap;
}
