import 'dart:math';

import 'package:ferry/typed_links.dart';

import '../../../services/tubecards/offer_service.dart';
import '../../queries/__generated__/viewer_offers.data.gql.dart';
import '../../queries/__generated__/viewer_offers.req.gql.dart';
import '../../queries/__generated__/viewer_offers.var.gql.dart';
import 'connection_utils.dart';

class ViewerOffersHelper {
  ViewerOffersHelper(this.proxy)
      : firstPageRequest =
            GViewerOffersReq((b) => b.vars..first = viewerOffersPageSize);

  final CacheProxy proxy;
  final GViewerOffersReq firstPageRequest;

  void changeTotalCountBy(int amount) {
    final pageRequests = getAllPageRequests(
      proxy,
      firstPageRequest,
      _buildNextRequest,
      _hasNextPage,
    );

    for (final request in pageRequests) {
      final cachedResponse = proxy.readQuery(request)!;

      final updatedResponse = cachedResponse.rebuild((b) => b
          .viewer
          .offerConnection
          .totalCount = max(0, b.viewer.offerConnection.totalCount! + amount));

      proxy.writeQuery(request, updatedResponse);
    }
  }

  void addOffer(Map<String, dynamic> offer) {
    final cachedResponse = proxy.readQuery(firstPageRequest);
    if (cachedResponse == null) {
      return;
    }

    final updatedResponse = cachedResponse.rebuild((b) {
      b.viewer.offerConnection.nodes.insert(
        0,
        GViewerOffersData_viewer_offerConnection_nodes.fromJson(offer)!,
      );
    });

    proxy.writeQuery(firstPageRequest, updatedResponse);
  }

  void removeOffer(String id) {
    final pageRequestWithDeck = getRequestToPredicatePage<GViewerOffersData,
        GViewerOffersVars, GViewerOffersReq>(
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
      b.viewer.offerConnection.nodes.removeWhere((c) => c.id == id);
    });

    proxy.writeQuery(pageRequestWithDeck, updatedResponse);
  }

  GViewerOffersReq _buildNextRequest(
      GViewerOffersReq request, GViewerOffersData response) {
    return request.rebuild((b) =>
        b.vars.after = response.viewer.offerConnection.pageInfo.endCursor);
  }

  bool _hasNextPage(GViewerOffersData? response) {
    return response?.viewer.offerConnection.pageInfo.endCursor != null;
  }

  bool _idPredicate(GViewerOffersData response, String cardId) {
    return response.viewer.offerConnection.nodes.any((c) => c.id == cardId);
  }
}
