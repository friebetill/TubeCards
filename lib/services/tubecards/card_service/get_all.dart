part of '../card_service.dart';

const int cardsPageSize = 20;

extension GetAll on CardService {
  Stream<Connection<Card>> getAll({
    required CardsSortOrder sortOrder,
    String? deckId,
    FetchPolicy? fetchPolicy,
  }) {
    return deckId == null
        ? _requestCards(fetchPolicy)
        : _requestDeckCards(deckId, sortOrder, fetchPolicy);
  }

  Stream<Connection<Card>> _requestDeckCards(
    String deckId,
    CardsSortOrder sortOrder,
    FetchPolicy? fetchPolicy,
  ) {
    Connection<Card>? allcardConnection;

    final request = GDeckCardsReq((b) {
      b
        // The unique ID prevents multiple requests from conflicting with each
        // other. This is important because otherwise the pagination of two
        // requests can mix and the wrong list is build.
        ..requestId = 'deckCards ${const Uuid().v4()}'
        ..fetchPolicy = fetchPolicy
        ..updateCacheHandlerKey = deckCardsHandlerKey
        ..vars.deckId = deckId
        ..vars.first = cardsPageSize
        ..vars.orderByField = sortOrder.field == CardsOrderField.createdAt
            ? GCardsOrderField.CREATED_AT
            : GCardsOrderField.FRONT
        ..vars.orderByDirection =
            sortOrder.direction == OrderDirection.ascending
                ? GOrderDirection.ASC
                : GOrderDirection.DESC;
    });

    return _graphQLRunner.request(request).distinct().map((r) {
      if (r.data != null) {
        allcardConnection = Connection<Card>.fromJson(
          r.data!.deck.cardConnection.toJson(),
        ).copyWith(
          fetchMore: () => _fetchMore(request, r.data!),
          refetch: () {
            return _graphQLRunner
                .request(request
                    .rebuild((b) => b.fetchPolicy = FetchPolicy.NetworkOnly))
                .first;
          },
        );
      }
      if (allcardConnection == null && r.hasErrors) {
        throw OperationException(
          linkException: r.linkException,
          graphqlErrors: r.graphqlErrors,
        );
      }

      return allcardConnection!;
    });
  }

  Stream<Connection<Card>> _requestCards(FetchPolicy? fetchPolicy) {
    Connection<Card>? allcardConnection;

    final request = GCardsReq((b) {
      b
        // The unique ID prevents multiple requests from conflicting with each
        // other. This is important because otherwise the pagination of two
        // requests can mix and the wrong list is build.
        ..requestId = 'cards ${const Uuid().v4()}'
        ..fetchPolicy = fetchPolicy;
    });

    return _graphQLRunner.request(request).distinct().map((r) {
      if (r.data != null) {
        allcardConnection = Connection<Card>.fromJson(
          r.data!.viewer.cardConnection!.toJson(),
        ).copyWith(
          refetch: () {
            return _graphQLRunner
                .request(request
                    .rebuild((b) => b.fetchPolicy = FetchPolicy.NetworkOnly))
                .first;
          },
        );
      }
      if (allcardConnection == null && r.hasErrors) {
        throw OperationException(
          linkException: r.linkException,
          graphqlErrors: r.graphqlErrors,
        );
      }

      return allcardConnection!;
    });
  }

  Future<void> _fetchMore(GDeckCardsReq request, GDeckCardsData data) async {
    await _graphQLRunner
        .request(request.rebuild((b) => b
          ..vars.after = data.deck.cardConnection.pageInfo.endCursor
          ..updateResult = updateDeckCardsResult))
        .first;
  }
}

GDeckCardsData? updateDeckCardsResult(
  GDeckCardsData? previous,
  GDeckCardsData? response,
) {
  if (previous == null) {
    return response;
  }

  return previous.rebuild((b) {
    final nodesMap = {
      for (var n in previous.deck.cardConnection.nodes) n.id: n,
    };
    for (final node in response!.deck.cardConnection.nodes) {
      if (!nodesMap.containsKey(node.id)) {
        b.deck.cardConnection.nodes.add(node);
      }
    }
    b.deck.cardConnection.pageInfo.endCursor =
        response.deck.cardConnection.pageInfo.endCursor;
    b.deck.cardConnection.pageInfo.hasNextPage =
        response.deck.cardConnection.pageInfo.hasNextPage;
  });
}
