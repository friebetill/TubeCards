import 'package:ferry/typed_links.dart';

import '../fragments/__generated__/card_fragment.data.gql.dart';
import '../fragments/__generated__/card_fragment.req.gql.dart';
import '../fragments/__generated__/deck_fragment.req.gql.dart';
import '../mutations/__generated__/upsert_card.data.gql.dart';
import '../mutations/__generated__/upsert_card.var.gql.dart';
import '../queries/__generated__/card.data.gql.dart';
import '../queries/__generated__/card.req.gql.dart';
import 'helpers/cards_helper.dart';
import 'helpers/deck_cards_helper.dart';
import 'helpers/due_cards_helper.dart';
import 'helpers/due_cards_of_deck_helper.dart';

const String upsertCardHandlerKey = 'upsertCardHandler';

void upsertCardHandler(
  CacheProxy proxy,
  OperationResponse<GUpsertCardData, GUpsertCardVars> response,
) {
  if (response.data?.upsertCard == null) {
    return;
  }

  final deck = proxy.readFragment(GDeckFragmentReq(
    (u) => u.idFields = {'id': response.data!.upsertCard!.deck.id},
  ));
  final oldCard = proxy.readFragment(GCardFragmentReq(
    (u) => u.idFields = {'id': response.data!.upsertCard!.id},
  ));
  final card = GCardFragmentData.fromJson(response.data!.upsertCard!.toJson())!;

  final isInsert = _isInsert(oldCard);
  final isMoved = _isMoved(card, oldCard);

  if (isInsert) {
    handleCardInsert(
      proxy,
      card,
      isActiveDeck: deck!.viewerDeckMember!.isActive,
    );
  } else if (isMoved) {
    handleCardMove(proxy, card, oldCard);
  }

  updateCardFragment(proxy, card);
}

void handleCardInsert(
  CacheProxy proxy,
  GCardFragmentData card, {
  required bool isActiveDeck,
}) {
  final updateMethods = [
    updateCardRequestOnInsert,
    updateCardsRequestOnInsert,
    updateDeckCardsRequestOnInsert,
    if (isActiveDeck) updateDueCardsRequestOnInsert,
    if (isActiveDeck) updateDueCardsOfDeckRequestOnInsert,
    updateDeckFragmentOnInsert,
  ];

  for (final updateMethod in updateMethods) {
    updateMethod(proxy, card);
  }
}

void handleCardMove(
  CacheProxy proxy,
  GCardFragmentData card,
  GCardFragmentData? oldCard,
) {
  const updateMethods = [
    updateDeckCardsRequestOnMove,
    updateDueCardsOfDeckRequestOnMove,
    updateDeckFragmentOnMove,
  ];

  for (final updateMethod in updateMethods) {
    updateMethod(proxy, card, oldCard);
  }
}

void updateCardRequestOnInsert(CacheProxy proxy, GCardFragmentData card) {
  final request = GCardReq((b) => b..vars.id = card.id);

  final cardDataCard = GCardData_card.fromJson(card.toJson())!;
  final updatedResponse = GCardData((b) => b.card.replace(cardDataCard));

  proxy.writeQuery(request, updatedResponse);
}

void updateCardsRequestOnInsert(CacheProxy proxy, GCardFragmentData card) {
  CardsHelper(proxy).changeTotalCountBy(1);
}

void updateDeckCardsRequestOnInsert(CacheProxy proxy, GCardFragmentData card) {
  DeckCardsHelper(proxy, card.deck.id)
    ..changeTotalCountBy(1)
    ..insertCardToCorrectPage(card);
}

void updateDueCardsRequestOnInsert(CacheProxy proxy, GCardFragmentData card) {
  DueCardsHelper(proxy)
    ..insertCardToCorrectPage(card)
    ..changeTotalCountBy(1);
}

void updateDueCardsOfDeckRequestOnInsert(
  CacheProxy proxy,
  GCardFragmentData card,
) {
  DueCardsOfDeckHelper(proxy, card.deck.id)
    ..insertCardToCorrectPage(card)
    ..changeTotalCountBy(1);
}

void updateDeckFragmentOnInsert(CacheProxy proxy, GCardFragmentData card) {
  final request = GDeckFragmentReq((u) => u.idFields = {'id': card.deck.id});
  final cachedResponse = proxy.readFragment(request);
  if (cachedResponse == null) {
    return;
  }

  final response = cachedResponse.rebuild((b) {
    b.cardConnection.totalCount = b.cardConnection.totalCount! + 1;
    if (card.learningState.nextDueDate.isBefore(DateTime.now())) {
      b.dueCardConnection.totalCount = b.dueCardConnection.totalCount! + 1;
    }
  });

  proxy.writeFragment(request, response);
}

void updateDeckCardsRequestOnMove(
  CacheProxy proxy,
  GCardFragmentData card,
  GCardFragmentData? oldCard,
) {
  DeckCardsHelper(proxy, card.deck.id)
    ..changeTotalCountBy(1)
    ..insertCardToCorrectPage(card);
  DeckCardsHelper(proxy, oldCard!.deck.id)
    ..changeTotalCountBy(-1)
    ..removeCard(oldCard.id);
}

void updateDueCardsOfDeckRequestOnMove(
  CacheProxy proxy,
  GCardFragmentData card,
  GCardFragmentData? oldCard,
) {
  final isDue = card.learningState.nextDueDate.isBefore(DateTime.now());
  if (isDue) {
    DueCardsOfDeckHelper(proxy, card.deck.id)
      ..insertCardToCorrectPage(card)
      ..changeTotalCountBy(1);
    DueCardsOfDeckHelper(proxy, oldCard!.deck.id)
      ..insertCardToCorrectPage(oldCard)
      ..changeTotalCountBy(-1);
  }
}

void updateDeckFragmentOnMove(
  CacheProxy proxy,
  GCardFragmentData card,
  GCardFragmentData? oldCard,
) {
  final isDue = card.learningState.nextDueDate.isBefore(DateTime.now());

  var request = GDeckFragmentReq((u) => u.idFields = {'id': card.deck.id});
  var cachedResponse = proxy.readFragment(request);
  if (cachedResponse != null) {
    final response = cachedResponse.rebuild((b) {
      b.cardConnection.totalCount = b.cardConnection.totalCount! + 1;
      if (isDue) {
        b.dueCardConnection.totalCount = b.dueCardConnection.totalCount! + 1;
      }
    });

    proxy.writeFragment(request, response);
  }

  request = GDeckFragmentReq((u) => u.idFields = {'id': oldCard!.deck.id});
  cachedResponse = proxy.readFragment(request);
  if (cachedResponse != null) {
    final response = cachedResponse.rebuild((b) {
      b.cardConnection.totalCount = b.cardConnection.totalCount! - 1;
      if (isDue) {
        b.dueCardConnection.totalCount = b.dueCardConnection.totalCount! - 1;
      }
    });

    proxy.writeFragment(request, response);
  }
}

void updateCardFragment(CacheProxy proxy, GCardFragmentData card) {
  proxy.writeFragment(
    GCardFragmentReq((u) => u.idFields = {'id': card.id}),
    card,
  );
}

bool _isInsert(GCardFragmentData? oldCard) => oldCard == null;

bool _isMoved(GCardFragmentData card, GCardFragmentData? oldCard) {
  return oldCard?.deck.id != null && card.deck.id != oldCard?.deck.id;
}
