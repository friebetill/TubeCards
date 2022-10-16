import 'dart:math';

import 'package:ferry/typed_links.dart';

import '../../../services/tubecards/card_service.dart';
import '../../__generated__/schema.schema.gql.dart';
import '../../fragments/__generated__/card_fragment.data.gql.dart';
import '../../queries/__generated__/deck_cards.data.gql.dart';
import '../../queries/__generated__/deck_cards.req.gql.dart';
import '../../queries/__generated__/deck_cards.var.gql.dart';
import 'connection_utils.dart';

class DeckCardsHelper {
  DeckCardsHelper(this.proxy, String deckId) {
    final genericFirstPageRequest = GDeckCardsReq((b) => b.vars
      ..deckId = deckId
      ..first = cardsPageSize);
    firstPageRequests = [
      genericFirstPageRequest.rebuild((b) => b.vars
        ..orderByDirection = GOrderDirection.ASC
        ..orderByField = GCardsOrderField.CREATED_AT),
      genericFirstPageRequest.rebuild((b) => b.vars
        ..orderByDirection = GOrderDirection.DESC
        ..orderByField = GCardsOrderField.CREATED_AT),
      genericFirstPageRequest.rebuild((b) => b.vars
        ..orderByDirection = GOrderDirection.ASC
        ..orderByField = GCardsOrderField.FRONT),
      genericFirstPageRequest.rebuild((b) => b.vars
        ..orderByDirection = GOrderDirection.DESC
        ..orderByField = GCardsOrderField.FRONT),
    ];
  }

  final CacheProxy proxy;

  /// The requests to the first page for each sort order.
  ///
  /// This is necessary so that all card lists are updated when for example a
  /// card is added.
  late List<GDeckCardsReq> firstPageRequests;

  void insertCardToCorrectPage(GCardFragmentData card) {
    for (final firstPageRequest in firstPageRequests) {
      final pageRequest = firstPageRequest;

      final cachedResponse = proxy.readQuery(pageRequest);

      if (cachedResponse == null) {
        continue;
      }

      final updatedResponse = cachedResponse.rebuild((b) {
        b.deck.cardConnection.nodes.insert(
          0,
          GDeckCardsData_deck_cardConnection_nodes.fromJson(card.toJson())!,
        );
      });

      proxy.writeQuery(pageRequest, updatedResponse);
    }
  }

  void changeTotalCountBy(int amount) {
    for (final firstPageRequest in firstPageRequests) {
      final pageRequests = getAllPageRequests(
        proxy,
        firstPageRequest,
        _buildNextRequest,
        _hasNextPage,
      );

      for (final pageRequest in pageRequests) {
        final cachedResponse = proxy.readQuery(pageRequest)!;

        final updatedResponse = cachedResponse.rebuild((b) => b
            .deck
            .cardConnection
            .totalCount = max(0, b.deck.cardConnection.totalCount! + amount));

        proxy.writeQuery(pageRequest, updatedResponse);
      }
    }
  }

  void removeCard(String cardId) {
    for (final firstPageRequest in firstPageRequests) {
      final pageRequestWithCard = getRequestToPredicatePage<GDeckCardsData,
          GDeckCardsVars, GDeckCardsReq>(
        proxy,
        firstPageRequest,
        (page) => _idPredicate(page, cardId),
        _buildNextRequest,
        _hasNextPage,
      );

      if (pageRequestWithCard == null) {
        continue;
      }

      final cachedResponse = proxy.readQuery(pageRequestWithCard)!;
      final updatedResponse = cachedResponse.rebuild((b) {
        b.deck.cardConnection.nodes.removeWhere((c) => c.id == cardId);
      });

      proxy.writeQuery(pageRequestWithCard, updatedResponse);
    }
  }

  GDeckCardsReq _buildNextRequest(
    GDeckCardsReq request,
    GDeckCardsData response,
  ) {
    return request.rebuild(
      (b) => b.vars.after = response.deck.cardConnection.pageInfo.endCursor,
    );
  }

  bool _hasNextPage(GDeckCardsData response) {
    return response.deck.cardConnection.pageInfo.endCursor != null;
  }

  bool _idPredicate(GDeckCardsData response, String cardId) {
    return response.deck.cardConnection.nodes.any((c) => c.id == cardId);
  }
}
