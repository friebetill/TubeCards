import 'package:flutter/foundation.dart';

import '../../../../data/models/connection.dart';
import '../../../../data/models/flexible_size_offer_connection.dart';
import '../../../../data/models/offer.dart';

class MarketplaceViewModel {
  const MarketplaceViewModel({
    required this.subscribedOffersConnection,
    required this.viewerOfferConnection,
    required this.popularOfferConnection,
    required this.newOfferConnection,
    required this.onPublishTap,
    required this.onOfferTap,
    required this.refetch,
  });

  final Connection<Offer> subscribedOffersConnection;
  final Connection<Offer> viewerOfferConnection;
  final Connection<Offer> popularOfferConnection;
  final FlexibleSizeOfferConnection newOfferConnection;

  final VoidCallback onPublishTap;
  final ValueSetter<Offer> onOfferTap;
  final AsyncCallback refetch;
}
