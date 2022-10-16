part of '../card_service.dart';

extension GetDueCardsOfDeck on CardService {
  Stream<Connection<Card>> getDueCardsOfDeck({
    required String deckId,
    FetchPolicy? fetchPolicy,
  }) {
    Connection<Card>? cardConnection;

    final request = GDueCardsOfDeckReq((b) => b
      // The unique ID prevents multiple requests from conflicting with each
      // other. This is important because otherwise the pagination of two
      // requests can mix and the wrong list is build.
      ..requestId = 'dueCardsOfDeck ${const Uuid().v4()}'
      ..fetchPolicy = fetchPolicy
      ..vars.id = deckId
      ..vars.first = dueCardsPageSize
      ..updateCacheHandlerKey = dueCardsOfDeckHandlerKey);

    return _graphQLRunner.request(request).distinct().map((r) {
      if (r.data != null) {
        cardConnection = Connection<Card>.fromJson(
          r.data!.deck.dueCardConnection.toJson(),
        ).copyWith(fetchMore: () => _fetchMore(request, r.data!));
      }
      if (cardConnection == null && r.hasErrors) {
        throw OperationException(
          linkException: r.linkException,
          graphqlErrors: r.graphqlErrors,
        );
      }

      return cardConnection!;
    });
  }

  Future<void> _fetchMore(
    GDueCardsOfDeckReq request,
    GDueCardsOfDeckData data,
  ) async {
    await _graphQLRunner
        .request(request.rebuild((b) => b
          ..vars.after = data.deck.dueCardConnection.pageInfo.endCursor
          ..updateResult = updateDueCardsOfDeckResult))
        .first;
  }
}

GDueCardsOfDeckData? updateDueCardsOfDeckResult(
  GDueCardsOfDeckData? previous,
  GDueCardsOfDeckData? response,
) {
  if (previous == null) {
    return response;
  }

  return previous.rebuild((b) {
    final nodesMap = {
      for (var n in previous.deck.dueCardConnection.nodes) n.id: n,
    };
    for (final node in response!.deck.dueCardConnection.nodes) {
      if (!nodesMap.containsKey(node.id)) {
        b.deck.dueCardConnection.nodes.add(node);
      }
    }
    b.deck.dueCardConnection.pageInfo.endCursor =
        response.deck.dueCardConnection.pageInfo.endCursor;
    b.deck.dueCardConnection.pageInfo.hasNextPage =
        response.deck.dueCardConnection.pageInfo.hasNextPage;
  });
}
