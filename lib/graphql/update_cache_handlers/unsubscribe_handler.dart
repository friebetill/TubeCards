import 'package:ferry/typed_links.dart';

import '../fragments/deck_fragment.data.gql.dart';
import '../fragments/deck_fragment.req.gql.dart';
import '../fragments/offer_fragment.data.gql.dart';
import '../fragments/offer_fragment.req.gql.dart';
import '../mutations/unsubscribe.data.gql.dart';
import '../mutations/unsubscribe.var.gql.dart';
import '../queries/offer.data.gql.dart';
import '../queries/offer.req.gql.dart';
import 'helpers/cards_helper.dart';
import 'helpers/decks_helper.dart';
import 'helpers/due_cards_helper.dart';
import 'helpers/subscribed_offers_helper.dart';

const String unsubscribeHandlerKey = 'unsubscribeHandler';

void unsubscribeHandler(
  CacheProxy proxy,
  OperationResponse<GUnsubscribeData, GUnsubscribeVars> response,
) {
  if (response.hasErrors) {
    return;
  }

  // Assumes that the deck exists in the cache, this should always be true,
  // otherwise one cannot unsubribe a deck currently.
  final deck = proxy.readFragment(GDeckFragmentReq(
    (u) => u.idFields = {'id': response.data!.unsubscribe.offer.deck.id},
  ))!;

  const updateMethods = [
    _updateDecksRequest,
    _updateCardsRequest,
    _updateDueCardsRequest,
    _updateSubscribedOffersRequest,
    _updateOfferRequest,
    _updateOfferFragment,
  ];

  for (final updateMethod in updateMethods) {
    updateMethod(proxy, response.data!.unsubscribe.offer, deck);
  }
}

void _updateDecksRequest(
  CacheProxy proxy,
  GUnsubscribeData_unsubscribe_offer offer,
  GDeckFragmentData deck,
) {
  DecksHelper(proxy, isActive: deck.viewerDeckMember!.isActive)
    ..removeDeck(offer.deck.id)
    ..changeTotalCountBy(-1);
}

void _updateCardsRequest(
  CacheProxy proxy,
  GUnsubscribeData_unsubscribe_offer offer,
  GDeckFragmentData deck,
) {
  if (!deck.viewerDeckMember!.isActive) {
    return;
  }

  CardsHelper(proxy).changeTotalCountBy(-deck.cardConnection.totalCount);
}

void _updateDueCardsRequest(
  CacheProxy proxy,
  GUnsubscribeData_unsubscribe_offer offer,
  GDeckFragmentData deck,
) {
  if (!deck.viewerDeckMember!.isActive) {
    return;
  }

  DueCardsHelper(proxy)
    ..removeCardsOfDeck(deck.id)
    ..changeTotalCountBy(-deck.dueCardConnection.totalCount);
}

void _updateSubscribedOffersRequest(
  CacheProxy proxy,
  GUnsubscribeData_unsubscribe_offer offer,
  GDeckFragmentData deck,
) {
  SubscribedOffersHelper(proxy)
    ..removeOffer(offer.id)
    ..changeTotalCountBy(-1);
}

void _updateOfferRequest(
  CacheProxy proxy,
  GUnsubscribeData_unsubscribe_offer offer,
  GDeckFragmentData deck,
) {
  final request = GOfferReq((b) => b..vars.id = offer.id);
  final cachedResponse = proxy.readQuery(request);

  final response = cachedResponse!.rebuild(
    (b) => b.offer.replace(GOfferData_offer.fromJson(offer.toJson())!),
  );
  proxy.writeQuery(request, response);
}

void _updateOfferFragment(
  CacheProxy proxy,
  GUnsubscribeData_unsubscribe_offer offer,
  GDeckFragmentData deck,
) {
  final request = GOfferFragmentReq((u) => u.idFields = {'id': offer.id});

  final response = GOfferFragmentData.fromJson(offer.toJson());

  proxy.writeFragment(request, response);
}
