import 'package:ferry/typed_links.dart';

import '../../../services/tubecards/offer_service.dart';
import '../../queries/__generated__/new_offers.data.gql.dart';
import '../../queries/__generated__/new_offers.req.gql.dart';
import '../../queries/__generated__/new_offers.var.gql.dart';
import 'connection_utils.dart';

class NewOffersHelper {
  NewOffersHelper(this.proxy)
      : firstPageRequest =
            GNewOffersReq((b) => b.vars..first = viewerOffersPageSize);

  final CacheProxy proxy;
  final GNewOffersReq firstPageRequest;

  void addOffer(Map<String, dynamic> offer) {
    final cachedResponse = proxy.readQuery(firstPageRequest);
    if (cachedResponse == null) {
      return;
    }

    final updatedResponse = cachedResponse.rebuild((b) {
      b.newOffers.nodes.insert(
        0,
        GNewOffersData_newOffers_nodes.fromJson(offer)!,
      );
    });

    proxy.writeQuery(firstPageRequest, updatedResponse);
  }

  void removeOffer(String id) {
    final pageRequestWithDeck = getRequestToPredicatePage<GNewOffersData,
        GNewOffersVars, GNewOffersReq>(
      proxy,
      firstPageRequest,
      (page) => _idPredicate(page, id),
      _buildNextRequest,
      _hasNextPage,
    );
    if (pageRequestWithDeck == null) {
      return;
    }

    final cachedResponse = proxy.readQuery(pageRequestWithDeck)!;
    final updatedResponse = cachedResponse.rebuild((b) {
      b.newOffers.nodes.removeWhere((c) => c.id == id);
    });

    proxy.writeQuery(pageRequestWithDeck, updatedResponse);
  }

  GNewOffersReq _buildNextRequest(
      GNewOffersReq request, GNewOffersData response) {
    return request
        .rebuild((b) => b.vars.after = response.newOffers.pageInfo.endCursor);
  }

  bool _hasNextPage(GNewOffersData? response) {
    return response?.newOffers.pageInfo.endCursor != null;
  }

  bool _idPredicate(GNewOffersData response, String cardId) {
    return response.newOffers.nodes.any((c) => c.id == cardId);
  }
}
