import 'package:flutter/foundation.dart';

class DeckTileViewModel {
  DeckTileViewModel({
    required this.deckId,
    required this.coverImageUrl,
    required this.deckName,
    required this.isOwner,
    required this.cardCount,
    required this.dueCardsCount,
    required this.createMirrorCard,
    required this.onTap,
    required this.onLongPress,
  });

  final String deckId;
  final String coverImageUrl;
  final bool isOwner;
  final String deckName;
  final int cardCount;
  final int dueCardsCount;
  final bool createMirrorCard;

  final VoidCallback onTap;
  final VoidCallback onLongPress;
}
