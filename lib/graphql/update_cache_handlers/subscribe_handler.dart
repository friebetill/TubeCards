import 'package:ferry/typed_links.dart';

import '../../services/tubecards/card_service.dart';
import '../fragments/__generated__/offer_fragment.data.gql.dart';
import '../fragments/__generated__/offer_fragment.req.gql.dart';
import '../mutations/__generated__/subscribe.data.gql.dart';
import '../mutations/__generated__/subscribe.var.gql.dart';
import '../queries/__generated__/deck.data.gql.dart';
import '../queries/__generated__/deck.req.gql.dart';
import '../queries/__generated__/due_cards.data.gql.dart';
import '../queries/__generated__/due_cards.req.gql.dart';
import '../queries/__generated__/offer.data.gql.dart';
import '../queries/__generated__/offer.req.gql.dart';
import 'helpers/cards_helper.dart';
import 'helpers/decks_helper.dart';
import 'helpers/subscribed_offers_helper.dart';

const String subscribeHandlerKey = 'subscribeHandler';

void subscribeHandler(
  CacheProxy proxy,
  OperationResponse<GSubscribeData, GSubscribeVars> response,
) {
  if (response.hasErrors) {
    return;
  }

  const updateMethods = [
    _updateDeckRequest,
    _updateDecksRequest,
    _updateCardsRequest,
    _updateDueCardsRequest,
    _updateSubscribedOffersRequest,
    _updateOfferRequest,
    _updateOfferFragment,
  ];

  for (final updateMethod in updateMethods) {
    updateMethod(proxy, response.data!.subscribe);
  }
}

void _updateDeckRequest(
  CacheProxy proxy,
  GSubscribeData_subscribe response,
) {
  final request = GDeckReq((b) => b..vars.id = response.offer.deck.id);
  final cachedResponse = proxy.readQuery(request);

  final deck = GDeckData_deck.fromJson(response.offer.deck.toJson())!;
  final updatedCachedResponse = cachedResponse != null
      ? cachedResponse.rebuild((b) => b.deck.replace(deck))
      : GDeckData((b) => b.deck.replace(deck));

  proxy.writeQuery(request, updatedCachedResponse);
}

void _updateDecksRequest(
  CacheProxy proxy,
  GSubscribeData_subscribe response,
) {
  DecksHelper(proxy, isActive: true)
    ..addDeck(response.offer.deck.toJson())
    ..changeTotalCountBy(1);
}

void _updateCardsRequest(
  CacheProxy proxy,
  GSubscribeData_subscribe response,
) {
  CardsHelper(proxy)
      .changeTotalCountBy(response.offer.deck.cardConnection.totalCount);
}

void _updateDueCardsRequest(
  CacheProxy proxy,
  GSubscribeData_subscribe response,
) {
  proxy.writeQuery(
    GDueCardsReq((b) => b.vars.first = dueCardsPageSize),
    GDueCardsData.fromJson(response.toJson()),
  );
}

void _updateSubscribedOffersRequest(
  CacheProxy proxy,
  GSubscribeData_subscribe response,
) {
  SubscribedOffersHelper(proxy)
    ..insertOffer(GOfferFragmentData.fromJson(response.offer.toJson())!)
    ..changeTotalCountBy(1);
}

void _updateOfferRequest(
  CacheProxy proxy,
  GSubscribeData_subscribe response,
) {
  final request = GOfferReq((b) => b..vars.id = response.offer.id);
  final cachedResponse = proxy.readQuery(request);

  final updatedCacheResponse = cachedResponse!.rebuild(
    (b) => b.offer.replace(GOfferData_offer.fromJson(response.offer.toJson())!),
  );
  proxy.writeQuery(request, updatedCacheResponse);
}

void _updateOfferFragment(
  CacheProxy proxy,
  GSubscribeData_subscribe response,
) {
  proxy.writeFragment(
    GOfferFragmentReq((u) => u.idFields = {'id': response.offer.id}),
    GOfferFragmentData.fromJson(response.offer.toJson()),
  );
}
