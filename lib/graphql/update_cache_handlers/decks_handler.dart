import 'package:ferry/typed_links.dart';

import '../../services/tubecards/deck_service.dart';
import '../queries/__generated__/deck.data.gql.dart';
import '../queries/__generated__/deck.req.gql.dart';
import '../queries/__generated__/decks.data.gql.dart';
import '../queries/__generated__/decks.var.gql.dart';

const String decksHandlerKey = 'decksHandler';

void decksHandler(
  CacheProxy proxy,
  OperationResponse<GDecksData, GDecksVars> response,
) {
  if (response.hasErrors || response.dataSource == DataSource.Cache) {
    return;
  }

  final decks = response.data!.viewer.deckConnection!.nodes;
  final lastPage = decks.reversed.take(decksPageSize);
  for (final deck in lastPage) {
    final request = GDeckReq((b) => b.vars.id = deck.id);

    proxy.writeQuery(
      request,
      GDeckData.fromJson({'__typename': 'Deck', 'deck': deck.toJson()}),
    );
  }
}
