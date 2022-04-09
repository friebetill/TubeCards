import 'package:ferry/typed_links.dart';

import '../../data/models/role.dart';
import '../fragments/__generated__/deck_fragment.req.gql.dart';
import '../fragments/__generated__/offer_fragment.data.gql.dart';
import '../fragments/__generated__/offer_fragment.req.gql.dart';
import '../mutations/__generated__/delete_offer.data.gql.dart';
import '../mutations/__generated__/delete_offer.var.gql.dart';
import 'helpers/decks_helper.dart';
import 'helpers/new_offers_helper.dart';
import 'helpers/viewer_offer_helper.dart';

const String deleteOfferHandlerKey = 'deleteOfferHandler';

void deleteOfferHandler(
  CacheProxy proxy,
  OperationResponse<GDeleteOfferData, GDeleteOfferVars> response,
) {
  if (response.hasErrors) {
    return;
  }

  // Assumes that the offer exists in the cache, this should always be true,
  // otherwise one cannot delete am offer currently. This is necessary to get
  // the total count of cards and due cards. The alternative is that the
  // information is in the response, but our backend cannot yet return
  // subentities of deleted entities.
  final offer = proxy.readFragment(GOfferFragmentReq(
    (u) => u.idFields = {'id': response.data!.deleteOffer.id},
  ))!;

  const updateMethods = [
    _updateViewerOffersRequest,
    _updateNewOffersRequest,
    _updateDecksRequest,
    _updateDeckFragment,
  ];

  for (final updateMethod in updateMethods) {
    updateMethod(proxy, response.data!.deleteOffer, offer);
  }

  proxy
    ..evict(proxy.identify(offer)!)
    ..gc();
}

void _updateViewerOffersRequest(
  CacheProxy proxy,
  GDeleteOfferData_deleteOffer deleteOffer,
  GOfferFragmentData offer,
) {
  ViewerOffersHelper(proxy)
    ..removeOffer(deleteOffer.id)
    ..changeTotalCountBy(-1);
}

void _updateNewOffersRequest(
  CacheProxy proxy,
  GDeleteOfferData_deleteOffer deleteOffer,
  GOfferFragmentData offer,
) {
  NewOffersHelper(proxy).removeOffer(deleteOffer.id);
}

void _updateDecksRequest(
  CacheProxy proxy,
  GDeleteOfferData_deleteOffer deleteOffer,
  GOfferFragmentData offer,
) {
  // Assume that the deck is in the cache.
  final deck = proxy.readFragment(GDeckFragmentReq(
    (u) => u.idFields = {'id': offer.deck.id},
  ))!;

  DecksHelper(proxy, isActive: null, isPublic: false, roleId: Role.owner.id)
      .addDeck(deck.toJson());
}

void _updateDeckFragment(
  CacheProxy proxy,
  GDeleteOfferData_deleteOffer deleteOffer,
  GOfferFragmentData offer,
) {
  final request = GDeckFragmentReq(
    (u) => u.idFields = {'id': offer.deck.id},
  );

  final cachedResponse = proxy.readFragment(request)!;
  final updatedResponse = cachedResponse.rebuild((b) => b.offer = null);

  proxy.writeFragment(request, updatedResponse);
}
