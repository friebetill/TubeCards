part of '../card_service.dart';

const int dueCardsPageSize = 20;

extension GetDueCards on CardService {
  Stream<Connection<Card>> getDueCards({FetchPolicy? fetchPolicy}) {
    Connection<Card>? cardConnection;

    final request = GDueCardsReq((b) => b
      // The unique ID prevents multiple requests from conflicting with each
      // other. This is important because otherwise the pagination of two
      // requests can mix and the wrong list is build.
      ..requestId = 'dueCards ${const Uuid().v4()}'
      ..fetchPolicy = fetchPolicy
      ..vars.first = dueCardsPageSize
      ..updateCacheHandlerKey = dueCardsHandlerKey);

    return _graphQLRunner.request(request).distinct().map((r) {
      if (r.data != null) {
        cardConnection = Connection<Card>.fromJson(
          r.data!.viewer.dueCardConnection!.toJson(),
        ).copyWith(
          refetch: () => _refetch(request),
          fetchMore: () => _fetchMore(request, r.data!),
        );
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

  Future<void> _refetch(GDueCardsReq request) async {
    await _graphQLRunner
        .request(
          request.rebuild((b) => b.fetchPolicy = FetchPolicy.NetworkOnly),
        )
        .first;
  }

  Future<void> _fetchMore(GDueCardsReq request, GDueCardsData data) async {
    await _graphQLRunner
        .request(request.rebuild((b) => b
          ..vars.after = data.viewer.dueCardConnection!.pageInfo.endCursor
          ..updateResult = updateDueCardsResult))
        .first;
  }
}

GDueCardsData? updateDueCardsResult(
  GDueCardsData? previous,
  GDueCardsData? response,
) {
  if (previous == null) {
    return response;
  }

  return previous.rebuild((b) {
    final nodesMap = {
      for (var n in previous.viewer.dueCardConnection!.nodes) n.id: n,
    };
    for (final node in response!.viewer.dueCardConnection!.nodes) {
      if (!nodesMap.containsKey(node.id)) {
        b.viewer.dueCardConnection.nodes.add(node);
      }
    }
    b.viewer.dueCardConnection.pageInfo.endCursor =
        response.viewer.dueCardConnection!.pageInfo.endCursor;
    b.viewer.dueCardConnection.pageInfo.hasNextPage =
        response.viewer.dueCardConnection!.pageInfo.hasNextPage;
  });
}
