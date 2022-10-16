import 'dart:math';

import 'package:ferry/typed_links.dart';

import '../../../services/tubecards/offer_service.dart';
import '../../fragments/__generated__/offer_fragment.data.gql.dart';
import '../../queries/__generated__/subscribed_offers.data.gql.dart';
import '../../queries/__generated__/subscribed_offers.req.gql.dart';
import '../../queries/__generated__/subscribed_offers.var.gql.dart';
import 'connection_utils.dart';

class SubscribedOffersHelper {
  SubscribedOffersHelper(this.proxy)
      : firstPageRequest = GSubscribedOffersReq(
            (b) => b.vars.first = subscribedOffersPageSize);

  final CacheProxy proxy;
  final GSubscribedOffersReq firstPageRequest;

  void insertOffer(GOfferFragmentData offer) {
    final cachedResponse = proxy.readQuery(firstPageRequest)!;
    final updatedResponse = cachedResponse.rebuild((b) {
      b.subscribedOffers.nodes.insert(
        0,
        GSubscribedOffersData_subscribedOffers_nodes.fromJson(offer.toJson())!,
      );
    });

    proxy.writeQuery(firstPageRequest, updatedResponse);
  }

  void changeTotalCountBy(int amount) {
    final pageRequests = getAllPageRequests(
      proxy,
      firstPageRequest,
      _buildNextRequest,
      _hasNextPage,
    );

    for (final pageRequest in pageRequests) {
      final cachedResponse = proxy.readQuery(pageRequest)!;

      final updatedResponse = cachedResponse.rebuild((b) => b.subscribedOffers
          .totalCount = max(0, b.subscribedOffers.totalCount! + amount));

      proxy.writeQuery(pageRequest, updatedResponse);
    }
  }

  void removeOffer(String offerId) {
    final pageRequestWithOffer = getRequestToPredicatePage<
        GSubscribedOffersData, GSubscribedOffersVars, GSubscribedOffersReq>(
      proxy,
      firstPageRequest,
      (page) => _idPredicate(page, offerId),
      _buildNextRequest,
      _hasNextPage,
    );

    if (pageRequestWithOffer == null) {
      return;
    }

    final cachedResponse = proxy.readQuery(pageRequestWithOffer)!;
    final updatedResponse = cachedResponse.rebuild((b) {
      b.subscribedOffers.nodes.removeWhere((c) => c.id == offerId);
    });

    proxy.writeQuery(pageRequestWithOffer, updatedResponse);
  }

  GSubscribedOffersReq _buildNextRequest(
      GSubscribedOffersReq request, GSubscribedOffersData response) {
    return request.rebuild(
        (b) => b.vars.after = response.subscribedOffers.pageInfo.endCursor);
  }

  bool _hasNextPage(GSubscribedOffersData? response) {
    return response?.subscribedOffers.pageInfo.endCursor != null;
  }

  bool _idPredicate(GSubscribedOffersData response, String offerId) {
    return response.subscribedOffers.nodes.any((c) => c.id == offerId);
  }
}
