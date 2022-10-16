import 'dart:math';

import 'package:ferry/typed_links.dart';

import '../../../services/tubecards/card_service.dart';
import '../../fragments/__generated__/card_fragment.data.gql.dart';
import '../../queries/__generated__/due_cards.data.gql.dart';
import '../../queries/__generated__/due_cards.req.gql.dart';
import '../../queries/__generated__/due_cards.var.gql.dart';
import 'connection_utils.dart';

class DueCardsHelper {
  DueCardsHelper(this.proxy)
      : firstPageRequest = GDueCardsReq((b) => b.vars.first = dueCardsPageSize);

  final CacheProxy proxy;
  final GDueCardsReq firstPageRequest;

  void insertCardToCorrectPage(GCardFragmentData card) {
    final pageRequest =
        getRequestToPredicatePage<GDueCardsData, GDueCardsVars, GDueCardsReq>(
              proxy,
              firstPageRequest,
              (page) => _dueDatePredicate(page, card.learningState.nextDueDate),
              _buildNextRequest,
              _hasNextPage,
            ) ??
            getRequestToLastPage(
              proxy,
              firstPageRequest,
              _buildNextRequest,
              _hasNextPage,
            );

    if (pageRequest == null) {
      return;
    }

    final cachedResponse = proxy.readQuery(pageRequest)!;
    final updatedResponse = cachedResponse.rebuild((b) {
      var index = cachedResponse.viewer.dueCardConnection!.nodes.indexWhere(
        (c) =>
            c.learningState.nextDueDate.isAfter(card.learningState.nextDueDate),
      );

      if (index == -1) {
        index = cachedResponse.viewer.dueCardConnection!.nodes.length;
      }

      b.viewer.dueCardConnection.nodes.insert(
        index,
        GDueCardsData_viewer_dueCardConnection_nodes.fromJson(card.toJson())!,
      );
    });

    proxy.writeQuery(pageRequest, updatedResponse);
  }

  void changeTotalCountBy(int amount) {
    final pageRequests = getAllPageRequests(
      proxy,
      firstPageRequest,
      _buildNextRequest,
      _hasNextPage,
    );

    for (final pageRequest in pageRequests) {
      final cachedResponse = proxy.readQuery(pageRequest)!;

      final updatedResponse = cachedResponse.rebuild((b) =>
          b.viewer.dueCardConnection.totalCount =
              max(0, b.viewer.dueCardConnection.totalCount! + amount));

      proxy.writeQuery(pageRequest, updatedResponse);
    }
  }

  void removeCard(String cardId) {
    final pageRequestWithCard =
        getRequestToPredicatePage<GDueCardsData, GDueCardsVars, GDueCardsReq>(
      proxy,
      firstPageRequest,
      (page) => _idPredicate(page, cardId),
      _buildNextRequest,
      _hasNextPage,
    );

    if (pageRequestWithCard == null) {
      return;
    }

    final cachedResponse = proxy.readQuery(pageRequestWithCard)!;
    final updatedResponse = cachedResponse.rebuild((b) {
      b.viewer.dueCardConnection.nodes.removeWhere((c) => c.id == cardId);
    });

    proxy.writeQuery(pageRequestWithCard, updatedResponse);
  }

  void removeCardsOfDeck(String deckId) {
    final pageRequests = getAllPageRequests(
      proxy,
      firstPageRequest,
      _buildNextRequest,
      _hasNextPage,
    );

    for (final pageRequest in pageRequests) {
      final cachedResponse = proxy.readQuery(pageRequest)!;

      final updatedResponse = cachedResponse.rebuild((b) {
        b.viewer.dueCardConnection.nodes.removeWhere(
          (c) => c.deck.id == deckId,
        );
      });

      proxy.writeQuery(pageRequest, updatedResponse);
    }
  }

  GDueCardsReq _buildNextRequest(GDueCardsReq request, GDueCardsData response) {
    return request.rebuild((b) =>
        b.vars.after = response.viewer.dueCardConnection!.pageInfo.endCursor);
  }

  bool _hasNextPage(GDueCardsData? response) {
    return response?.viewer.dueCardConnection!.pageInfo.endCursor != null;
  }

  bool _idPredicate(GDueCardsData response, String cardId) {
    return response.viewer.dueCardConnection!.nodes.any((c) => c.id == cardId);
  }

  bool _dueDatePredicate(GDueCardsData response, DateTime nextDueDate) {
    return response.viewer.dueCardConnection!.nodes
        .any((c) => c.learningState.nextDueDate.isAfter(nextDueDate));
  }
}
