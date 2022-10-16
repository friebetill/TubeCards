import 'dart:math';

import 'package:ferry/typed_links.dart';

import '../../../services/tubecards/card_service.dart';
import '../../fragments/__generated__/card_fragment.data.gql.dart';
import '../../queries/__generated__/due_cards_of_deck.data.gql.dart';
import '../../queries/__generated__/due_cards_of_deck.req.gql.dart';
import '../../queries/__generated__/due_cards_of_deck.var.gql.dart';
import 'connection_utils.dart';

class DueCardsOfDeckHelper {
  DueCardsOfDeckHelper(this.proxy, String deckId)
      : initialRequest = GDueCardsOfDeckReq(
          (b) => b.vars
            ..id = deckId
            ..first = dueCardsPageSize,
        );

  final CacheProxy proxy;
  final GDueCardsOfDeckReq initialRequest;

  void insertCardToCorrectPage(GCardFragmentData card) {
    final pageRequest = getRequestToPredicatePage<GDueCardsOfDeckData,
            GDueCardsOfDeckVars, GDueCardsOfDeckReq>(
          proxy,
          initialRequest,
          (page) => _dueDatePredicate(page, card.learningState.nextDueDate),
          _buildNextRequest,
          _hasNextPage,
        ) ??
        getRequestToLastPage(
          proxy,
          initialRequest,
          _buildNextRequest,
          _hasNextPage,
        );

    if (pageRequest == null) {
      return;
    }

    final cachedResponse = proxy.readQuery(pageRequest)!;
    final updatedResponse = cachedResponse.rebuild((b) {
      var index = cachedResponse.deck.dueCardConnection.nodes.indexWhere(
        (c) =>
            c.learningState.nextDueDate.isAfter(card.learningState.nextDueDate),
      );
      if (index == -1) {
        index = cachedResponse.deck.dueCardConnection.nodes.length;
      }

      b.deck.dueCardConnection.nodes.insert(
        index,
        GDueCardsOfDeckData_deck_dueCardConnection_nodes.fromJson(
          card.toJson(),
        )!,
      );
    });

    proxy.writeQuery(pageRequest, updatedResponse);
  }

  void changeTotalCountBy(int amount) {
    final pageRequests = getAllPageRequests(
      proxy,
      initialRequest,
      _buildNextRequest,
      _hasNextPage,
    );

    for (final pageRequest in pageRequests) {
      final cachedResponse = proxy.readQuery(pageRequest)!;

      final updatedResponse = cachedResponse.rebuild((b) => b
          .deck
          .dueCardConnection
          .totalCount = max(0, b.deck.dueCardConnection.totalCount! + amount));

      proxy.writeQuery(pageRequest, updatedResponse);
    }
  }

  void removeCard(String cardId) {
    final pageRequestWithCard = getRequestToPredicatePage<GDueCardsOfDeckData,
        GDueCardsOfDeckVars, GDueCardsOfDeckReq>(
      proxy,
      initialRequest,
      (page) => _idPredicate(page, cardId),
      _buildNextRequest,
      _hasNextPage,
    );

    if (pageRequestWithCard == null) {
      return;
    }

    final cachedResponse = proxy.readQuery(pageRequestWithCard)!;
    final updatedResponse = cachedResponse.rebuild((b) {
      b.deck.dueCardConnection.nodes.removeWhere((c) => c.id == cardId);
    });

    proxy.writeQuery(pageRequestWithCard, updatedResponse);
  }

  bool _idPredicate(GDueCardsOfDeckData response, String cardId) {
    return response.deck.dueCardConnection.nodes.any((c) => c.id == cardId);
  }

  bool _dueDatePredicate(GDueCardsOfDeckData response, DateTime nextDueDate) {
    return response.deck.dueCardConnection.nodes
        .any((c) => c.learningState.nextDueDate.isAfter(nextDueDate));
  }

  GDueCardsOfDeckReq _buildNextRequest(
    GDueCardsOfDeckReq request,
    GDueCardsOfDeckData? response,
  ) {
    return request.rebuild(
      (b) => b.vars.after = response!.deck.dueCardConnection.pageInfo.endCursor,
    );
  }

  bool _hasNextPage(GDueCardsOfDeckData? response) {
    return response?.deck.dueCardConnection.pageInfo.endCursor != null;
  }
}
