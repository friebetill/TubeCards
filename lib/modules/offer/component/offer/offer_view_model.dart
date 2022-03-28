import 'package:flutter/foundation.dart';

import '../../../../data/models/deck.dart';
import '../../../../data/models/offer.dart';
import '../../../../data/models/user.dart';

class OfferViewModel {
  OfferViewModel({
    required this.deck,
    required this.offer,
    required this.viewer,
    required this.creator,
    required this.showRateOffer,
    required this.isSubscribeLoading,
    required this.isUnsubscribeLoading,
    required this.isDeleteLoading,
    required this.onOpenTap,
    required this.onSubscribeTap,
    required this.onUnsubscribeTap,
    required this.onDeleteOfferTap,
  });

  final Deck deck;
  final Offer offer;
  final User viewer;
  final User creator;
  final bool showRateOffer;
  final bool isSubscribeLoading;
  final bool isUnsubscribeLoading;
  final bool isDeleteLoading;

  final VoidCallback? onOpenTap;
  final VoidCallback? onSubscribeTap;
  final VoidCallback? onUnsubscribeTap;
  final VoidCallback? onDeleteOfferTap;
}
