part of '../card_service.dart';

extension Search on CardService {
  Stream<Connection<Card>> search({
    required String searchTerm,
    String? deckId,
    FetchPolicy? fetchPolicy,
  }) {
    Connection<Card>? cardConnection;

    final request = GSearchCardsReq((b) {
      b
        // The unique ID prevents multiple requests from conflicting with each
        // other. This is important because otherwise the pagination of two
        // requests can mix and the wrong list is build.
        ..requestId = 'SearchCards ${const Uuid().v4()}'
        ..fetchPolicy = fetchPolicy
        ..vars.searchTerm = searchTerm
        ..vars.deckId = deckId
        ..vars.first = cardsPageSize;
    });

    return _graphQLRunner.request(request).distinct().map((r) {
      if (r.data != null) {
        cardConnection = Connection<Card>.fromJson(
          r.data!.searchCards.toJson(),
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
    GSearchCardsReq request,
    GSearchCardsData data,
  ) async {
    await _graphQLRunner
        .request(request.rebuild((b) => b
          ..vars.after = data.searchCards.pageInfo.endCursor
          ..updateResult = updateSearchCardsResult))
        .first;
  }
}

GSearchCardsData? updateSearchCardsResult(
  GSearchCardsData? previous,
  GSearchCardsData? response,
) {
  if (previous == null) {
    return response;
  }

  return previous.rebuild((b) {
    final nodesMap = {
      for (var n in previous.searchCards.nodes) n.id: n,
    };
    for (final node in response!.searchCards.nodes) {
      if (!nodesMap.containsKey(node.id)) {
        b.searchCards.nodes.add(node);
      }
    }
    b.searchCards.pageInfo.endCursor = response.searchCards.pageInfo.endCursor;
    b.searchCards.pageInfo.hasNextPage =
        response.searchCards.pageInfo.hasNextPage;
  });
}
