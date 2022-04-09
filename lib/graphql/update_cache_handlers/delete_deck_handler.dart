import 'package:ferry/typed_links.dart';

import '../../data/models/role.dart';
import '../fragments/__generated__/deck_fragment.data.gql.dart';
import '../fragments/__generated__/deck_fragment.req.gql.dart';
import '../mutations/__generated__/delete_deck.data.gql.dart';
import '../mutations/__generated__/delete_deck.var.gql.dart';
import 'helpers/cards_helper.dart';
import 'helpers/decks_helper.dart';
import 'helpers/due_cards_helper.dart';
import 'helpers/viewer_offer_helper.dart';

const String deleteDeckHandlerKey = 'deleteDeckHandler';

void deleteDeckHandler(
  CacheProxy proxy,
  OperationResponse<GDeleteDeckData, GDeleteDeckVars> response,
) {
  if (response.hasErrors) {
    return;
  }

  // Assumes that the deck exists in the cache, this should always be true,
  // otherwise one cannot delete a deck currently. This is necessary to get
  // the total count of cards and due cards. The alternative is that the
  // information is in the response, but our backend cannot yet return
  // subentities of deleted entities.
  final deletedDeck = proxy.readFragment(GDeckFragmentReq(
    (u) => u.idFields = {'id': response.data!.deleteDeck.id},
  ))!;

  const updateMethods = [
    _updateDecksRequest,
    _updateCardsRequest,
    _updateDueCardsRequest,
    _updateOfferRequest,
  ];

  for (final updateMethod in updateMethods) {
    updateMethod(proxy, deletedDeck);
  }

  proxy
    ..evict(proxy.identify(deletedDeck)!)
    ..gc();
}

void _updateDecksRequest(CacheProxy proxy, GDeckFragmentData deletedDeck) {
  DecksHelper(proxy, isActive: deletedDeck.viewerDeckMember!.isActive)
    ..removeDeck(deletedDeck.id)
    ..changeTotalCountBy(-1);

  if (deletedDeck.viewerDeckMember!.role.id == Role.owner.id) {
    DecksHelper(proxy, isActive: null, isPublic: false, roleId: Role.owner.id)
      ..removeDeck(deletedDeck.id)
      ..changeTotalCountBy(-1);
  }
}

void _updateCardsRequest(CacheProxy proxy, GDeckFragmentData deletedDeck) {
  if (!deletedDeck.viewerDeckMember!.isActive) {
    return;
  }

  CardsHelper(proxy).changeTotalCountBy(-deletedDeck.cardConnection.totalCount);
}

void _updateDueCardsRequest(CacheProxy proxy, GDeckFragmentData deletedDeck) {
  if (!deletedDeck.viewerDeckMember!.isActive) {
    return;
  }

  DueCardsHelper(proxy)
    ..removeCardsOfDeck(deletedDeck.id)
    ..changeTotalCountBy(-deletedDeck.dueCardConnection.totalCount);
}

void _updateOfferRequest(CacheProxy proxy, GDeckFragmentData deletedDeck) {
  if (deletedDeck.viewerDeckMember!.role.id == Role.owner.id &&
      deletedDeck.offer?.id != null) {
    ViewerOffersHelper(proxy)
      ..removeOffer(deletedDeck.offer!.id)
      ..changeTotalCountBy(-1);
  }
}
