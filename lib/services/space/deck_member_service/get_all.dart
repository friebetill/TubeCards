part of '../deck_member_service.dart';

const int deckMembersPageSize = 20;

extension GetMembers on DeckMemberService {
  Stream<Connection<DeckMember>> getAll(
    String deckId, {
    FetchPolicy? fetchPolicy,
  }) {
    Connection<DeckMember>? memberConnection;

    final request = GDeckMembersReq(
      (b) => b
        // The unique ID prevents multiple requests from conflicting with each
        // other. This is important because otherwise the pagination of two
        // requests can mix and the wrong list is build.
        ..requestId = 'deckMembersReq ${const Uuid().v4()}'
        ..vars.deckId = deckId
        ..vars.first = deckMembersPageSize
        ..fetchPolicy = fetchPolicy
        ..updateCacheHandlerKey = deckMembersHandlerKey,
    );

    return _graphQLRunner.request(request).distinct().map((r) {
      if (r.data != null) {
        memberConnection = Connection<DeckMember>.fromJson(
          r.data!.deck.deckMemberConnection.toJson(),
        );
        memberConnection = memberConnection!.copyWith(fetchMore: () async {
          final updatedRequest = request.rebuild((b) => b
            ..vars.after = r.data!.deck.deckMemberConnection.pageInfo.endCursor
            ..updateResult = updateDeckMembersResult);

          await _graphQLRunner.request(updatedRequest).first;
        });
      }
      if (memberConnection == null && r.hasErrors) {
        throw OperationException(
          linkException: r.linkException,
          graphqlErrors: r.graphqlErrors,
        );
      }

      return memberConnection!;
    });
  }
}

GDeckMembersData? updateDeckMembersResult(
  GDeckMembersData? previous,
  GDeckMembersData? response,
) {
  if (previous == null) {
    return response;
  }

  return previous.rebuild((b) {
    final nodesMap = {
      for (var n in previous.deck.deckMemberConnection.nodes) n.user.id: n,
    };
    for (final node in response!.deck.deckMemberConnection.nodes) {
      if (!nodesMap.containsKey(node.user.id)) {
        b.deck.deckMemberConnection.nodes.add(node);
      }
    }
    b.deck.deckMemberConnection.pageInfo.endCursor =
        response.deck.deckMemberConnection.pageInfo.endCursor;
    b.deck.deckMemberConnection.pageInfo.hasNextPage =
        response.deck.deckMemberConnection.pageInfo.hasNextPage;
  });
}
