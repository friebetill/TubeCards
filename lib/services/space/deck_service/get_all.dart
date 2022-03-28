part of '../deck_service.dart';

const int decksPageSize = 20;

extension GetAll on DeckService {
  Stream<Connection<Deck>> getAll({
    FetchPolicy? fetchPolicy,
    bool? isActive = true,
    String? roleID,
    bool? isPublic,
  }) {
    Connection<Deck>? deckConnection;

    final request = GDecksReq(
      (b) => b
        // The unique ID prevents multiple requests from conflicting with each
        // other. This is important because otherwise the pagination of two
        // requests can mix and the wrong list is build.
        ..requestId = 'decksReq ${const Uuid().v4()}'
        ..vars.first = decksPageSize
        ..vars.isActive = isActive
        ..vars.roleId = roleID
        ..vars.isPublic = isPublic
        ..fetchPolicy = fetchPolicy
        ..updateCacheHandlerKey = decksHandlerKey,
    );

    return _graphQLRunner.request(request).distinct().map((r) {
      if (r.data != null) {
        deckConnection = Connection<Deck>.fromJson(
          r.data!.viewer.deckConnection!.toJson(),
        ).copyWith(
          refetch: () => _refetch(request),
          fetchMore: () => _fetchMore(request, r.data!),
        );
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

  Future<void> _refetch(GDecksReq request) async {
    await _graphQLRunner
        .request(
          request.rebuild((b) => b.fetchPolicy = FetchPolicy.NetworkOnly),
        )
        .first;
  }

  Future<void> _fetchMore(GDecksReq request, GDecksData data) async {
    await _graphQLRunner
        .request(request.rebuild((b) => b
          ..vars.after = data.viewer.deckConnection!.pageInfo.endCursor
          ..updateResult = updateDecksResult))
        .first;
  }
}

GDecksData? updateDecksResult(GDecksData? previous, GDecksData? response) {
  if (previous == null) {
    return response;
  }

  return previous.rebuild((b) {
    final nodesMap = {
      for (var n in previous.viewer.deckConnection!.nodes) n.id: n,
    };
    for (final node in response!.viewer.deckConnection!.nodes) {
      if (!nodesMap.containsKey(node.id)) {
        b.viewer.deckConnection.nodes.add(node);
      }
    }
    b.viewer.deckConnection.pageInfo.endCursor =
        response.viewer.deckConnection!.pageInfo.endCursor;
    b.viewer.deckConnection.pageInfo.hasNextPage =
        response.viewer.deckConnection!.pageInfo.hasNextPage;
  });
}
