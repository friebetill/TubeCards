import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../models/average_learning_state.dart';
import '../models/card.dart';
import '../models/confidence.dart';
import '../models/connection.dart';
import '../models/review_session.dart';
import '../preferences/preferences.dart';
import 'card_repository.dart';

/// The minimum number of cached cards.
///
/// If less than this number of cards are cached, the next page is preloaded.
const double _minimumCachedCardsCount = 10;

@singleton
class ReviewSessionRepository {
  ReviewSessionRepository(this._cardRepository, this._preferences);

  final CardRepository _cardRepository;
  final Preferences _preferences;

  /// All information about current review session
  late ValueStream<ReviewSession> session;

  /// Cards that the user has to learn and has already preloaded.
  late ValueStream<BuiltList<Card>> _cards;

  /// The ID of the card being learned.
  late BehaviorSubject<String?> _cardId;

  late BehaviorSubject<BuiltMap<String, List<Confidence>>> _idToConfidences;

  /// Determines whether the user is on the front or back side.
  late BehaviorSubject<bool> _isFrontSide;

  /// True when new cards are fetched.
  late bool _isFetchingMore;

  late BehaviorSubject<AverageLearningState?> _initialLearningState;

  /// Creates a new review session
  ///
  /// The old session is deleted during this process.
  /// If [dryRun] is false, the given [connectionStream] must be sorted by
  /// the due date.
  void createSession({
    required ValueStream<Connection<Card>> connectionStream,
    required bool dryRun,
    required String title,
    required AsyncValueGetter<AverageLearningState>? loadLearningState,
  }) {
    // The IDs of the cards for this session, limited by the setting
    // Preferences.cardsPerSessionLimit
    final cardIdsOfSession = <String>[];
    _idToConfidences = BehaviorSubject.seeded(BuiltMap());
    _cardId = BehaviorSubject();
    _isFrontSide = BehaviorSubject.seeded(true);
    var initial = true;
    _isFetchingMore = false;
    _initialLearningState = BehaviorSubject.seeded(null);
    loadLearningState?.call().then(_initialLearningState.add);
    _cards = Rx.combineLatest2<Connection<Card>,
            BuiltMap<String, List<Confidence>>, BuiltList<Card>>(
      connectionStream,
      _idToConfidences,
      (connection, _) => connection.nodes!,
    )
        .map((cards) => _limitCardsPerSession(cards, cardIdsOfSession))
        .doOnData((cards) => _setInitialConfidences(cards, _idToConfidences))
        .map((cards) => cards.rebuild((b) => b.removeWhere((c) =>
            _idToConfidences.value[c.id]!.isNotEmpty &&
            _idToConfidences.value[c.id]!.last == Confidence.known)))
        .doOnData((cards) => _maybeFetchMore(cards, connectionStream.value))
        .doOnData((cards) {
      if (initial) {
        _cardId.add(cards[Random().nextInt(cards.length)].id);
        initial = false;
      }
    }).doOnCancel(() {
      _cardId.close();
      _idToConfidences.close();
      _isFrontSide.close();
      _initialLearningState.close();
    }).shareValue();

    session = Rx.combineLatest9(
      Stream.value(title),
      Stream.value(dryRun),
      Stream.value(_cardsPerSession(connectionStream.value.totalCount!)),
      _cards,
      _cardId,
      _idToConfidences,
      _isFrontSide,
      _initialLearningState,
      Stream.value(loadLearningState),
      _createSession,
    ).shareValue();
  }

  ReviewSession _createSession(
    String title,
    bool dryRun,
    int totalCount,
    BuiltList<Card> cards,
    String? cardId,
    BuiltMap<String, List<Confidence>> idToConfidences,
    bool isFrontSide,
    AverageLearningState? initialLearningState,
    AsyncValueGetter<AverageLearningState>? loadLearningState,
  ) {
    final card = cards.singleWhereOrNull((c) => c.id == _cardId.value);

    return ReviewSession(
      title: title,
      card: card,
      hasNextCard: cards.length > 1,
      progress: _getProgress(idToConfidences, cards, totalCount),
      addRepetition: (confidence) =>
          _addRepetition(confidence, card?.id, dryRun: dryRun),
      confidences: idToConfidences,
      isFrontSide: isFrontSide,
      setIsFrontSide: (isFrontSide) => _isFrontSide.add(isFrontSide),
      initialLearningState: initialLearningState,
      loadLearningState: loadLearningState,
    );
  }

  Future<void> _maybeFetchMore(
    BuiltList<Card> cards,
    Connection<Card>? connection,
  ) async {
    if (!_isFetchingMore &&
        cards.length <= _minimumCachedCardsCount &&
        connection!.pageInfo!.hasNextPage!) {
      _isFetchingMore = true;
      await connection.fetchMore!();
      _isFetchingMore = false;
    }
  }

  Future<void> _addRepetition(
    Confidence confidence,
    String? cardId, {
    required bool dryRun,
  }) async {
    if (cardId == null) {
      return;
    }

    _idToConfidences.add(_idToConfidences.value.rebuild((confidences) {
      confidences[cardId]!.add(confidence);
    }));

    final cardToRemove = _cards.value.singleWhere((c) => c.id == cardId);
    final cards = _cards.value.rebuild((b) => b.remove(cardToRemove));
    _cardId.add(_selectNextCard(cards, _idToConfidences.value)?.id);

    if (!dryRun) {
      try {
        await _cardRepository.addRepetition(cardId, confidence);
      } on Exception {
        _revertAddRepetition(cardToRemove, confidence);
        rethrow;
      }
    }
  }

  /// Reverts all local changes made by [_addRepetition]
  void _revertAddRepetition(Card removedCard, Confidence confidence) {
    _idToConfidences.add(_idToConfidences.value.rebuild((confidences) {
      confidences[removedCard.id!]!.removeWhere((c) => c == confidence);
    }));

    _cards.value.rebuild((b) => b.add(removedCard));
  }

  /// Returns the next card to learn
  ///
  /// Returns null if no card exists.
  Card? _selectNextCard(
    BuiltList<Card> cards,
    BuiltMap<String, List<Confidence>>? idToConfidences,
  ) {
    if (cards.isEmpty) {
      return null;
    }

    // Find the cards with the least repetitions
    var leastRepetitionCards = <Card>[];
    var leastRepetitonCount = 10000000; // Very large number
    for (final card in cards) {
      if (idToConfidences![card.id]!.length < leastRepetitonCount) {
        leastRepetitonCount = idToConfidences[card.id]!.length;
        leastRepetitionCards = [];
      }
      if (idToConfidences[card.id]!.length == leastRepetitonCount) {
        leastRepetitionCards.add(card);
      }
    }

    // Take a random card inside the window from the cards
    const windowSize = 5;
    final randomNumber =
        Random().nextInt(min(leastRepetitionCards.length, windowSize));

    return leastRepetitionCards[randomNumber];
  }

  BuiltList<Card> _limitCardsPerSession(
    BuiltList<Card> cards,
    List<String?> cardIdsOfSession,
  ) {
    final cardsLimit = _preferences.cardsPerSessionLimit.getValue();
    if (cardsLimit == Preferences.offValue) {
      return cards;
    }

    final limitedCards = <Card>[];
    for (final card in cards) {
      if (cardIdsOfSession.contains(card.id) ||
          cardIdsOfSession.length < cardsLimit) {
        cardIdsOfSession.add(card.id);
        limitedCards.add(card);
      }
    }

    return limitedCards.toBuiltList();
  }

  double _getProgress(
    BuiltMap<String, List<Confidence>> confidences,
    BuiltList<Card> cards,
    int cardsPerSession,
  ) {
    return (confidences.length - cards.length) / cardsPerSession;
  }

  int _cardsPerSession(int totalCount) {
    final cardsPerSessionLimit = _preferences.cardsPerSessionLimit.getValue();
    if (cardsPerSessionLimit == Preferences.offValue) {
      return totalCount;
    }

    return min(cardsPerSessionLimit, totalCount);
  }

  void _setInitialConfidences(
    BuiltList<Card> cards,
    BehaviorSubject<BuiltMap<String, List<Confidence>>> idToConfidences,
  ) {
    final newList = idToConfidences.value.rebuild((b) {
      for (final card in cards) {
        if (card.id != null) {
          b.putIfAbsent(card.id!, () => []);
        }
      }
    });
    if (newList != idToConfidences.value) {
      idToConfidences.add(newList);
    }
  }
}
