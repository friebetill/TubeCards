import 'package:ferry/ferry.dart';
import 'package:ferry/typed_links.dart';
import 'package:injectable/injectable.dart';

import '../../services/tubecards/offer_service.dart';
import '../models/connection.dart';
import '../models/flexible_size_offer_connection.dart';
import '../models/offer.dart';

/// Repository for the [Offer] model.
@singleton
class OfferRepository {
  OfferRepository(this._service);

  final OfferService _service;

  Stream<Offer> get(String id, {FetchPolicy? fetchPolicy}) {
    return _service.get(id, fetchPolicy: fetchPolicy);
  }

  Stream<Connection<Offer>> getSubscribedOffers({
    FetchPolicy? fetchPolicy,
  }) {
    return _service.subscribedOffers(fetchPolicy: fetchPolicy);
  }

  Stream<Connection<Offer>> getPopular({FetchPolicy? fetchPolicy}) {
    return _service.getPopular(fetchPolicy: fetchPolicy);
  }

  Stream<FlexibleSizeOfferConnection> getNew({FetchPolicy? fetchPolicy}) {
    return _service.getNew(fetchPolicy: fetchPolicy);
  }

  Stream<Connection<Offer>> viewerOffers({FetchPolicy? fetchPolicy}) {
    return _service.viewerOffers(fetchPolicy: fetchPolicy);
  }

  Stream<Connection<Offer>> search(
    String searchTerm, {
    FetchPolicy? fetchPolicy,
  }) {
    return _service.search(searchTerm: searchTerm, fetchPolicy: fetchPolicy);
  }

  Future<Offer> addOffer(String deckId) {
    return _service.addOffer(deckId);
  }

  Future<void> deleteOffer(String offerID) {
    return _service.deleteOffer(offerID);
  }

  Future<void> subscribe(String offerId) {
    return _service.subscribe(offerId);
  }

  Future<void> unsubscribe(String offerId) {
    return _service.unsubscribe(offerId);
  }
}
