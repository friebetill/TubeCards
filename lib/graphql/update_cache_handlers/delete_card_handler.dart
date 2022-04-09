import 'package:ferry/typed_links.dart';

import '../fragments/__generated__/card_fragment.data.gql.dart';
import '../fragments/__generated__/card_fragment.req.gql.dart';
import '../fragments/__generated__/deck_fragment.req.gql.dart';
import '../mutations/__generated__/delete_card.data.gql.dart';
import '../mutations/__generated__/delete_card.var.gql.dart';
import 'helpers/cards_helper.dart';
import 'helpers/deck_cards_helper.dart';
import 'helpers/due_cards_helper.dart';
import 'helpers/due_cards_of_deck_helper.dart';

const String deleteCardHandlerKey = 'deleteCardHandler';

void deleteCardHandler(
  CacheProxy proxy,
  OperationResponse<GDeleteCardData, GDeleteCardVars> response,
) {
  if (response.hasErrors) {
    return;
  }

  // Assumes that the card exists in the cache, this should always be true,
  // otherwise you cannot delete a single card currently. This is necessary
  // to determine the mirror card and the due date of the card
  final card = proxy.readFragment(GCardFragmentReq(
    (u) => u.idFields = {'id': response.data!.deleteCard.id},
  ))!;
  deleteCard(proxy, card);

  final mirrorCard = card.mirrorCard?.id != null
      ? proxy.readFragment(GCardFragmentReq(
          (u) => u.idFields = {'id': card.mirrorCard!.id},
        ))
      : null;
  if (mirrorCard != null) {
    deleteCard(proxy, mirrorCard);
  }
  // TODO(tillf): Fix the null event that occurs when deleting a mirror card
  //              I suspect it is due to the circular reference of the cards
  proxy.gc();
}

void deleteCard(CacheProxy proxy, GCardFragmentData card) {
  CardsHelper(proxy).changeTotalCountBy(-1);
  DeckCardsHelper(proxy, card.deck.id).changeTotalCountBy(-1);

  final isDue = card.learningState.nextDueDate.isBefore(DateTime.now());
  if (isDue) {
    DueCardsHelper(proxy).changeTotalCountBy(-1);
    DueCardsOfDeckHelper(proxy, card.deck.id).changeTotalCountBy(-1);
  }
  _updateDeckFragment(proxy, card.deck.id, isDue);

  proxy.evict(proxy.identify(card)!);
}

void _updateDeckFragment(CacheProxy proxy, String deckId, bool isDue) {
  final request = GDeckFragmentReq(
    (u) => u.idFields = {'id': deckId},
  );

  final cachedResponse = proxy.readFragment(request)!;
  final updatedResponse = cachedResponse.rebuild((b) {
    b.cardConnection.totalCount = b.cardConnection.totalCount! - 1;
    if (isDue) {
      b.dueCardConnection.totalCount = b.dueCardConnection.totalCount! - 1;
    }
  });

  proxy.writeFragment(request, updatedResponse);
}
