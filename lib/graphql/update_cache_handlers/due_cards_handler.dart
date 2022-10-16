import 'package:ferry/typed_links.dart';

import '../../services/tubecards/card_service.dart';
import '../queries/__generated__/card.data.gql.dart';
import '../queries/__generated__/card.req.gql.dart';
import '../queries/__generated__/due_cards.data.gql.dart';
import '../queries/__generated__/due_cards.var.gql.dart';

const String dueCardsHandlerKey = 'dueCardsHandler';

void dueCardsHandler(
  CacheProxy proxy,
  OperationResponse<GDueCardsData, GDueCardsVars> response,
) {
  if (response.hasErrors || response.dataSource == DataSource.Cache) {
    return;
  }

  final cards = response.data!.viewer.dueCardConnection!.nodes;
  final lastPage = cards.reversed.take(dueCardsPageSize);
  for (final card in lastPage) {
    final request = GCardReq((b) => b.vars.id = card.id);

    proxy.writeQuery(
      request,
      GCardData.fromJson({'__typename': 'Card', 'card': card.toJson()}),
    );
  }
}
