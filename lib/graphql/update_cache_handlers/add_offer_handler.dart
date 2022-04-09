import 'package:ferry/typed_links.dart';

import '../../data/models/role.dart';
import '../fragments/__generated__/deck_fragment.data.gql.dart';
import '../fragments/__generated__/deck_fragment.req.gql.dart';
import '../mutations/__generated__/add_offer.data.gql.dart';
import '../mutations/__generated__/add_offer.var.gql.dart';
import 'helpers/decks_helper.dart';
import 'helpers/new_offers_helper.dart';
import 'helpers/viewer_offer_helper.dart';

const String addOfferHandlerKey = 'addOfferHandler';

void addOfferHandler(
  CacheProxy proxy,
  OperationResponse<GAddOfferData, GAddOfferVars> response,
) {
  if (response.hasErrors) {
    return;
  }

  const updateMethods = [
    _updateViewerOffersRequest,
    _updateNewOffersRequest,
    _updateDecksRequest,
    _updateDeckFragment,
  ];

  for (final updateMethod in updateMethods) {
    updateMethod(proxy, response.data!.addOffer.offer);
  }
}

void _updateViewerOffersRequest(
  CacheProxy proxy,
  GAddOfferData_addOffer_offer offer,
) {
  ViewerOffersHelper(proxy)
    ..addOffer(offer.toJson())
    ..changeTotalCountBy(1);
}

void _updateNewOffersRequest(
  CacheProxy proxy,
  GAddOfferData_addOffer_offer offer,
) {
  NewOffersHelper(proxy).addOffer(offer.toJson());
}

void _updateDecksRequest(
  CacheProxy proxy,
  GAddOfferData_addOffer_offer offer,
) {
  DecksHelper(proxy, isActive: null, isPublic: false, roleId: Role.owner.id)
      .removeDeck(offer.deck.id);
}

void _updateDeckFragment(CacheProxy proxy, GAddOfferData_addOffer_offer offer) {
  final request = GDeckFragmentReq(
    (u) => u.idFields = {'id': offer.deck.id},
  );

  final cachedResponse = proxy.readFragment(request)!;
  final updatedResponse = cachedResponse.rebuild((b) {
    b.offer = GDeckFragmentData_offerBuilder()..id = offer.id;
  });

  proxy.writeFragment(request, updatedResponse);
}
