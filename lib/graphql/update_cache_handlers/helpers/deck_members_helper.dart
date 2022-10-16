import 'dart:math';

import 'package:ferry/typed_links.dart';

import '../../../services/tubecards/deck_member_service.dart';
import '../../queries/__generated__/deck_members.data.gql.dart';
import '../../queries/__generated__/deck_members.req.gql.dart';
import 'connection_utils.dart';

class DeckMembersHelper {
  DeckMembersHelper(this.proxy, String deckId)
      : firstPageRequest = GDeckMembersReq((b) => b
          ..vars.first = deckMembersPageSize
          ..vars.deckId = deckId);

  final CacheProxy proxy;
  final GDeckMembersReq firstPageRequest;

  void changeTotalCountBy(int amount) {
    final pageRequests = getAllPageRequests(
      proxy,
      firstPageRequest,
      _buildNextRequest,
      _hasNextPage,
    );

    for (final request in pageRequests) {
      final cachedResponse = proxy.readQuery(request)!;

      final updatedResponse = cachedResponse.rebuild((b) =>
          b.deck.deckMemberConnection.totalCount =
              max(0, b.deck.deckMemberConnection.totalCount! + amount));

      proxy.writeQuery(request, updatedResponse);
    }
  }

  GDeckMembersReq _buildNextRequest(
    GDeckMembersReq request,
    GDeckMembersData response,
  ) {
    return request.rebuild((b) =>
        b.vars.after = response.deck.deckMemberConnection.pageInfo.endCursor);
  }

  bool _hasNextPage(GDeckMembersData response) {
    return response.deck.deckMemberConnection.pageInfo.endCursor != null;
  }
}
