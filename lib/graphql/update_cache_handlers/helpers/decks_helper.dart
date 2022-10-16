import 'dart:math';

import 'package:ferry/typed_links.dart';

import '../../../services/tubecards/deck_service.dart';
import '../../queries/__generated__/decks.data.gql.dart';
import '../../queries/__generated__/decks.req.gql.dart';
import '../../queries/__generated__/decks.var.gql.dart';
import 'connection_utils.dart';

class DecksHelper {
  DecksHelper(
    this.proxy, {
    required bool? isActive,
    bool? isPublic,
    String? roleId,
  }) : firstPageRequest = GDecksReq((b) => b.vars
          ..first = decksPageSize
          ..isActive = isActive
          ..isPublic = isPublic
          ..roleId = roleId);

  final CacheProxy proxy;
  final GDecksReq firstPageRequest;

  void changeTotalCountBy(int amount) {
    final pageRequests = getAllPageRequests(
      proxy,
      firstPageRequest,
      _buildNextRequest,
      _hasNextPage,
    );

    for (final request in pageRequests) {
      final cachedResponse = proxy.readQuery(request)!;

      final updatedResponse = cachedResponse.rebuild((b) => b
          .viewer
          .deckConnection
          .totalCount = max(0, b.viewer.deckConnection.totalCount! + amount));

      proxy.writeQuery(request, updatedResponse);
    }
  }

  void addDeck(Map<String, dynamic> deck) {
    final createdAt = DateTime.parse(deck['createdAt'] as String);
    final request =
        getRequestToPredicatePage<GDecksData, GDecksVars, GDecksReq>(
      proxy,
      firstPageRequest,
      (data) {
        if (data.viewer.deckConnection?.nodes == null) {
          return true;
        }

        return data.viewer.deckConnection!.nodes
                .any((d) => d.createdAt.isAfter(createdAt)) ||
            !data.viewer.deckConnection!.pageInfo.hasNextPage;
      },
      _buildNextRequest,
      _hasNextPage,
    );
    if (request == null) {
      return;
    }

    final cachedResponse = proxy.readQuery(request)!;

    final updatedResponse = cachedResponse.rebuild((b) {
      var insertIndex = cachedResponse.viewer.deckConnection?.nodes
              .indexWhere((d) => d.createdAt.isAfter(createdAt)) ??
          0;
      insertIndex = insertIndex != -1
          ? insertIndex
          : cachedResponse.viewer.deckConnection!.nodes.length;

      b.viewer.deckConnection.nodes.insert(
        insertIndex,
        GDecksData_viewer_deckConnection_nodes.fromJson(deck)!,
      );
    });

    proxy.writeQuery(request, updatedResponse);
  }

  void removeDeck(String id) {
    final pageRequestWithDeck =
        getRequestToPredicatePage<GDecksData, GDecksVars, GDecksReq>(
      proxy,
      firstPageRequest,
      (page) => _idPredicate(page, id),
      _buildNextRequest,
      _hasNextPage,
    );
    if (pageRequestWithDeck == null) {
      return;
    }

    final cachedResponse = proxy.readQuery(pageRequestWithDeck)!;
    final updatedResponse = cachedResponse.rebuild((b) {
      b.viewer.deckConnection.nodes.removeWhere((c) => c.id == id);
    });

    proxy.writeQuery(pageRequestWithDeck, updatedResponse);
  }

  GDecksReq _buildNextRequest(GDecksReq request, GDecksData response) {
    return request.rebuild((b) =>
        b.vars.after = response.viewer.deckConnection!.pageInfo.endCursor);
  }

  bool _hasNextPage(GDecksData? response) {
    return response?.viewer.deckConnection!.pageInfo.endCursor != null;
  }

  bool _idPredicate(GDecksData response, String cardId) {
    return response.viewer.deckConnection!.nodes.any((c) => c.id == cardId);
  }
}
