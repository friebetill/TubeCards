import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

import '../../../../data/models/card.dart';
import '../../../../data/models/user.dart';

class OfferPreviewViewModel {
  OfferPreviewViewModel({
    required this.deckName,
    required this.coverImageUrl,
    required this.description,
    required this.cardSamples,
    required this.cardsCount,
    required this.creator,
    required this.isLoading,
    required this.onEditTap,
    required this.onPublishTap,
  });

  final String deckName;
  final String coverImageUrl;
  final String description;
  final BuiltList<Card> cardSamples;
  final int cardsCount;
  final User creator;
  final bool isLoading;
  final VoidCallback onEditTap;
  final VoidCallback onPublishTap;
}
