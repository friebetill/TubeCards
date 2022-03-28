part of '../deck_service.dart';

extension Search on DeckService {
  Stream<Connection<Deck>> search({
    required String searchTerm,
    FetchPolicy? fetchPolicy,
  }) {
    Connection<Deck>? deckConnection;

    final request = GSearchDecksReq((b) {
      b
        // The unique ID prevents multiple requests from conflicting with each
        // other. This is important because otherwise the pagination of two
        // requests can mix and the wrong list is build.
        ..requestId = 'SearchDecks ${const Uuid().v4()}'
        ..fetchPolicy = fetchPolicy
        ..vars.searchTerm = searchTerm
        ..vars.first = decksPageSize;
    });

    return _graphQLRunner.request(request).distinct().map((r) {
      if (r.data != null) {
        deckConnection = Connection<Deck>.fromJson(
          r.data!.searchDecks.toJson(),
        ).copyWith(fetchMore: () => _fetchMore(request, r.data!));
      }
      if (deckConnection == null && r.hasErrors) {
        throw OperationException(
          linkException: r.linkException,
          graphqlErrors: r.graphqlErrors,
        );
      }

      return deckConnection!;
    });
  }

  Future<void> _fetchMore(
    GSearchDecksReq request,
    GSearchDecksData data,
  ) async {
    await _graphQLRunner
        .request(
          request.rebuild((b) => b
            ..vars.after = data.searchDecks.pageInfo.endCursor
            ..updateResult = updateSearchDecksResult),
        )
        .first;
  }
}

GSearchDecksData? updateSearchDecksResult(
  GSearchDecksData? previous,
  GSearchDecksData? response,
) {
  if (previous == null) {
    return response;
  }

  return previous.rebuild((b) {
    final nodesMap = {
      for (var n in previous.searchDecks.nodes) n.id: n,
    };
    for (final node in response!.searchDecks.nodes) {
      if (!nodesMap.containsKey(node.id)) {
        b.searchDecks.nodes.add(node);
      }
    }
    b.searchDecks.pageInfo.endCursor = response.searchDecks.pageInfo.endCursor;
    b.searchDecks.pageInfo.hasNextPage =
        response.searchDecks.pageInfo.hasNextPage;
  });
}
