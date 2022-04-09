import 'package:ferry/typed_links.dart';

import '../fragments/__generated__/card_fragment.data.gql.dart';
import '../fragments/__generated__/deck_fragment.data.gql.dart';
import '../fragments/__generated__/deck_fragment.req.gql.dart';
import '../mutations/__generated__/join_deck.data.gql.dart';
import '../mutations/__generated__/join_deck.var.gql.dart';
import '../queries/__generated__/deck.data.gql.dart';
import '../queries/__generated__/deck.req.gql.dart';
import 'helpers/decks_helper.dart';
import 'helpers/due_cards_helper.dart';

const String joinDeckHandlerKey = 'joinDeckHandler';

void joinDeckHandler(
  CacheProxy proxy,
  OperationResponse<GJoinDeckData, GJoinDeckVars> response,
) {
  if (response.hasErrors) {
    return;
  }

  const updateMethods = [
    _updateDecksRequest,
    _updateDeckRequest,
    _updateDeckFragment,
    _updateDueCardsRequest,
  ];

  for (final updateMethod in updateMethods) {
    updateMethod(proxy, response.data!.joinDeck.deck);
  }
}

void _updateDecksRequest(
  CacheProxy proxy,
  GJoinDeckData_joinDeck_deck upsertDeck,
) {
  DecksHelper(proxy, isActive: true)
    ..addDeck(upsertDeck.toJson())
    ..changeTotalCountBy(1);
}

void _updateDeckRequest(
  CacheProxy proxy,
  GJoinDeckData_joinDeck_deck upsertDeck,
) {
  final request = GDeckReq((b) => b..vars.id = upsertDeck.id);
  final cachedResponse = proxy.readQuery(request);

  final deck = GDeckData_deck.fromJson(upsertDeck.toJson())!;
  final response = cachedResponse != null
      ? cachedResponse.rebuild((b) => b.deck.replace(deck))
      : GDeckData((b) => b.deck.replace(deck));

  proxy.writeQuery(request, response);
}

void _updateDeckFragment(
  CacheProxy proxy,
  GJoinDeckData_joinDeck_deck upsertDeck,
) {
  final request = GDeckFragmentReq((u) => u.idFields = {'id': upsertDeck.id});

  final response = GDeckFragmentData.fromJson(upsertDeck.toJson());

  proxy.writeFragment(request, response);
}

void _updateDueCardsRequest(
  CacheProxy proxy,
  GJoinDeckData_joinDeck_deck upsertDeck,
) {
  final cards = upsertDeck.completeDueCardConnection.nodes
      .map((node) => GCardFragmentData.fromJson(node.toJson())!);

  final helper = DueCardsHelper(proxy)
    ..changeTotalCountBy(upsertDeck.completeDueCardConnection.totalCount);
  cards.forEach(helper.insertCardToCorrectPage);
}
