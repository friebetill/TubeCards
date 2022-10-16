import 'dart:async';

import 'package:ferry/ferry.dart';
import 'package:injectable/injectable.dart';

import '../../graphql/operation_exception.dart';
import '../../services/tubecards/card_service.dart';
import '../models/card.dart';
import '../models/cards_sort_order.dart';
import '../models/confidence.dart';
import '../models/connection.dart';

/// Repository for the [Card] model.
@singleton
class CardRepository {
  CardRepository(this._service);

  final CardService _service;

  Stream<Card> get(String id, {FetchPolicy? fetchPolicy}) {
    return _service.get(id, fetchPolicy: fetchPolicy);
  }

  /// Returns the connection of all cards that are due to be learned today.
  ///
  /// Today is determined based on the local timezone and the number of cards
  /// is adjusted by number of cards the user already learned today and
  /// what the limit for due cards per day is.
  Stream<Connection<Card>> getDueCards({FetchPolicy? fetchPolicy}) {
    return _service.getDueCards(fetchPolicy: fetchPolicy);
  }

  Stream<Connection<Card>> getDueCardsOfDeck({
    required String deckId,
    FetchPolicy? fetchPolicy,
  }) {
    return _service.getDueCardsOfDeck(deckId: deckId, fetchPolicy: fetchPolicy);
  }

  Stream<Connection<Card>> getAll({
    String? deckId,
    FetchPolicy? fetchPolicy,
    CardsSortOrder sortOrder = CardsSortOrder.defaultValue,
  }) {
    return _service.getAll(
      deckId: deckId,
      fetchPolicy: fetchPolicy,
      sortOrder: sortOrder,
    );
  }

  /// Upserts the given card
  ///
  /// Throws an [OperationException] or an [TimeoutException] if it was not
  /// successful.
  Future<void> upsert(Card card) => _service.upsert(card);

  /// Upserts the given card as a mirror card
  ///
  /// Throws an [OperationException] or an [TimeoutException] if it was not
  /// successful.
  Future<void> upsertMirrorCard(Card card) => _service.upsertMirrorCard(card);

  /// Inserts the given 10 card
  ///
  /// Throws an [OperationException] or an [TimeoutException] if it was not
  /// successful.
  ///
  /// If a card of [cards] was not successfully upserted, null is
  /// returned at the original position in the list. If no card was
  /// successfully upserted, an [OperationException] is thrown.
  Future<List<Card?>> insert10Cards(List<Card> cards) =>
      _service.insert10Cards(cards);

  /// Permanently deletes the given [card].
  ///
  /// Also removes the mirror card belonging to the card.
  /// Throws an [OperationException] or an [TimeoutException] if it was not
  /// successful.
  Future<void> remove(Card card) => _service.remove(card);

  Future<void> addRepetition(String cardId, Confidence confidence) {
    return _service.addRepetition(cardId, confidence);
  }

  Stream<Connection<Card>> search(
    String searchTerm, {
    String? deckId,
    FetchPolicy? fetchPolicy,
  }) {
    return _service.search(
      searchTerm: searchTerm,
      deckId: deckId,
      fetchPolicy: fetchPolicy,
    );
  }
}
