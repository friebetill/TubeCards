import 'package:flutter/foundation.dart';

import '../../../../data/models/connection.dart';
import '../../../../data/models/offer.dart';

class OfferSearchViewModel {
  OfferSearchViewModel({
    required this.offerConnection,
    required this.recentSearchTerms,
    required this.addSearchTerm,
    required this.fetchMoreOffers,
  });

  final Connection<Offer>? offerConnection;
  final List<String> recentSearchTerms;
  final ValueChanged<String> addSearchTerm;
  final VoidCallback fetchMoreOffers;
}
