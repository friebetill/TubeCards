import 'package:ferry/typed_links.dart';

import '../../services/space/card_service.dart';
import '../queries/card.data.gql.dart';
import '../queries/card.req.gql.dart';
import '../queries/deck_cards.data.gql.dart';
import '../queries/deck_cards.var.gql.dart';

const String deckCardsHandlerKey = 'deckCardsHandler';

void deckCardsHandler(
  CacheProxy proxy,
  OperationResponse<GDeckCardsData, GDeckCardsVars> response,
) {
  if (response.hasErrors || response.dataSource == DataSource.Cache) {
    return;
  }

  final cards = response.data!.deck.cardConnection.nodes;
  final lastPage = cards.reversed.take(cardsPageSize);
  for (final card in lastPage) {
    final request = GCardReq((b) => b.vars.id = card.id);

    proxy.writeQuery(
      request,
      GCardData.fromJson({'__typename': 'Card', 'card': card.toJson()}),
    );
  }
}
