import 'package:collection/collection.dart';
import 'package:ferry/typed_links.dart';

import '../fragments/__generated__/card_fragment.data.gql.dart';
import '../fragments/__generated__/card_fragment.req.gql.dart';
import '../fragments/__generated__/deck_fragment.req.gql.dart';
import '../mutations/__generated__/upsert_mirror_card.data.gql.dart';
import '../mutations/__generated__/upsert_mirror_card.var.gql.dart';
import 'upsert_card_handler.dart';

const String upsertMirrorCardHandlerKey = 'upsertMirrorCardHandler';

void upsertMirrorCardHandler(
  CacheProxy proxy,
  OperationResponse<GUpsertMirrorCardData, GUpsertMirrorCardVars> response,
) {
  if (response.hasErrors) {
    return;
  }

  final deck = proxy.readFragment(GDeckFragmentReq(
    (u) => u.idFields = {'id': response.data!.upsertMirrorCard.first.deck.id},
  ));
  final oldCards = response.data!.upsertMirrorCard
      .map((card) => proxy
          .readFragment(GCardFragmentReq((u) => u.idFields = {'id': card.id})))
      .toList();
  final cards = response.data!.upsertMirrorCard
      .map((card) => GCardFragmentData.fromJson(card.toJson())!)
      .toList();

  final areInserts = oldCards.map(_isInsert).toList();
  final areMoved = IterableZip([cards, oldCards])
      .map((values) => _isMoved(values[0]!, values[1]))
      .toList();

  for (var i = 0; i < cards.length; i++) {
    if (areInserts[i]) {
      handleCardInsert(
        proxy,
        cards[i],
        isActiveDeck: deck!.viewerDeckMember!.isActive,
      );
    } else if (areMoved[i]) {
      handleCardMove(proxy, cards[i], oldCards[i]);
    }

    updateCardFragment(proxy, cards[i]);
  }
}

bool _isInsert(GCardFragmentData? oldCard) => oldCard == null;

bool _isMoved(GCardFragmentData card, GCardFragmentData? oldCard) {
  return card.deck.id != oldCard?.deck.id;
}
