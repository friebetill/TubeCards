import 'dart:async';

import 'package:ferry/ferry.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/card.dart';
import '../../data/models/cards_order_field.dart';
import '../../data/models/cards_sort_order.dart';
import '../../data/models/confidence.dart';
import '../../data/models/connection.dart';
import '../../data/models/order_direction.dart';
import '../../graphql/__generated__/schema.schema.gql.dart';
import '../../graphql/graph_ql_runner.dart';
import '../../graphql/mutations/__generated__/add_repetition.req.gql.dart';
import '../../graphql/mutations/__generated__/delete_card.req.gql.dart';
import '../../graphql/mutations/__generated__/insert_10_cards.req.gql.dart';
import '../../graphql/mutations/__generated__/upsert_card.req.gql.dart';
import '../../graphql/mutations/__generated__/upsert_mirror_card.req.gql.dart';
import '../../graphql/operation_exception.dart';
import '../../graphql/queries/__generated__/card.req.gql.dart';
import '../../graphql/queries/__generated__/cards.req.gql.dart';
import '../../graphql/queries/__generated__/deck_cards.data.gql.dart';
import '../../graphql/queries/__generated__/deck_cards.req.gql.dart';
import '../../graphql/queries/__generated__/due_cards.data.gql.dart';
import '../../graphql/queries/__generated__/due_cards.req.gql.dart';
import '../../graphql/queries/__generated__/due_cards_of_deck.data.gql.dart';
import '../../graphql/queries/__generated__/due_cards_of_deck.req.gql.dart';
import '../../graphql/queries/__generated__/search_cards.data.gql.dart';
import '../../graphql/queries/__generated__/search_cards.req.gql.dart';
import '../../graphql/update_cache_handlers/add_repetition_handler.dart';
import '../../graphql/update_cache_handlers/deck_cards_handler.dart';
import '../../graphql/update_cache_handlers/delete_card_handler.dart';
import '../../graphql/update_cache_handlers/due_cards_handler.dart';
import '../../graphql/update_cache_handlers/due_cards_of_deck_handler.dart';
import '../../graphql/update_cache_handlers/upsert_card_handler.dart';
import '../../graphql/update_cache_handlers/upsert_mirror_card_handler.dart';
// import '../../utils/sm2.dart' as sm2;
import 'user_service.dart';

part './card_service/get_all.dart';
part './card_service/get_due_cards.dart';
part './card_service/get_due_cards_of_deck.dart';
part './card_service/search_cards.dart';

@singleton
class CardService {
  CardService(this._graphQLRunner);

  final GraphQLRunner _graphQLRunner;

  Stream<Card> get(String id, {FetchPolicy? fetchPolicy}) {
    Card? card;

    return _graphQLRunner
        .request(GCardReq(
          (b) => b
            ..vars.id = id
            ..fetchPolicy = fetchPolicy,
        ))
        .distinct()
        .map((r) {
      if (!r.hasErrors) {
        card = r.data != null ? Card.fromJson(r.data!.card.toJson()) : null;
      }
      if (card == null && r.hasErrors) {
        throw OperationException(
          linkException: r.linkException,
          graphqlErrors: r.graphqlErrors,
        );
      }

      return card!;
    });
  }

  /// Upserts the given card
  ///
  /// Throws an [OperationException] or an [TimeoutException] if it was not
  /// successful.
  Future<void> upsert(Card card) async {
    return _graphQLRunner
        .request(GUpsertCardReq(
          (b) => b
            ..vars.id = card.id
            ..vars.deckId = card.deck!.id!
            ..vars.front = card.front!
            ..vars.back = card.back!
            ..fetchPolicy = FetchPolicy.NoCache
            ..updateCacheHandlerKey = upsertCardHandlerKey,
        ))
        .map((r) {
          if (r.data?.upsertCard == null) {
            throw OperationException(
              linkException: r.linkException,
              graphqlErrors: r.graphqlErrors,
            );
          }
        })
        .timeout(timeOutDuration)
        .first;
  }

  /// Upserts the given card as a mirror card
  ///
  /// Throws an [OperationException] or an [TimeoutException] if it was not
  /// successful.
  Future<void> upsertMirrorCard(Card card) async {
    return _graphQLRunner
        .request(GUpsertMirrorCardReq(
          (b) => b
            ..vars.id = card.id ?? ''
            ..vars.deckId = card.deck!.id!
            ..vars.front = card.front!
            ..vars.back = card.back!
            ..vars.nextDueDate = DateTime.now()
            ..fetchPolicy = FetchPolicy.NoCache
            ..updateCacheHandlerKey = upsertMirrorCardHandlerKey,
        ))
        .map((r) {
          if (r.hasErrors) {
            throw OperationException(
              linkException: r.linkException,
              graphqlErrors: r.graphqlErrors,
            );
          }
        })
        .timeout(timeOutDuration)
        .first;
  }

  /// Inserts the given 10 cards.
  ///
  /// Throws an [ArgumentError] if not exactly 10 cards were given, an
  /// [OperationException] or an [TimeoutException] if it was not successful.
  ///
  /// If a card of [cards] was not successfully upserted, null is
  /// returned at the original position in the list. If no card was
  /// successfully upserted, an [OperationException] is thrown.
  // Could be removed if BatchHttpLink exists for Ferry, https://bit.ly/2Utaq19.
  Future<List<Card?>> insert10Cards(List<Card> cards) async {
    if (cards.length != 10) {
      throw ArgumentError();
    }

    final deckId = cards.first.deck!.id!;

    return _graphQLRunner
        .request(GInsert10CardsReq(
          (b) => b
            ..vars.deckId = deckId
            ..vars.front0 = cards[0].front!
            ..vars.back0 = cards[0].back!
            ..vars.front1 = cards[1].front!
            ..vars.back1 = cards[1].back!
            ..vars.front2 = cards[2].front!
            ..vars.back2 = cards[2].back!
            ..vars.front3 = cards[3].front!
            ..vars.back3 = cards[3].back!
            ..vars.front4 = cards[4].front!
            ..vars.back4 = cards[4].back!
            ..vars.front5 = cards[5].front!
            ..vars.back5 = cards[5].back!
            ..vars.front6 = cards[6].front!
            ..vars.back6 = cards[6].back!
            ..vars.front7 = cards[7].front!
            ..vars.back7 = cards[7].back!
            ..vars.front8 = cards[8].front!
            ..vars.back8 = cards[8].back!
            ..vars.front9 = cards[9].front!
            ..vars.back9 = cards[9].back!
            ..fetchPolicy = FetchPolicy.NoCache,
          // A handler is not possible, because due to the many requests
          // during the import the isolate is overloaded. Before a handler
          // can be added, Ferry must be further optimized.
          // ..updateCacheHandlerKey = insert10CardsHandler,
        ))
        .map((r) {
          final cards = [
            r.data?.card0,
            r.data?.card1,
            r.data?.card2,
            r.data?.card3,
            r.data?.card4,
            r.data?.card5,
            r.data?.card6,
            r.data?.card7,
            r.data?.card8,
            r.data?.card9,
          ];

          final wasNoCardUpserted = !cards.any((e) => e != null);
          if (r.data == null || wasNoCardUpserted) {
            throw OperationException(
              linkException: r.linkException,
              graphqlErrors: r.graphqlErrors,
            );
          }

          return cards
              .map((c) => c != null ? Card.fromJson(c.toJson()) : null)
              .toList();
        })
        .timeout(timeOutDuration)
        .first;
  }

  /// Permanently deletes the given [card].
  ///
  /// Also removes the mirror card belonging to the card.
  /// Throws an [OperationException] or an [TimeoutException] if it was not
  /// successful.
  Future<void> remove(Card card) async {
    return _graphQLRunner
        .request(GDeleteCardReq(
          (b) => b
            ..vars.id = card.id!
            ..fetchPolicy = FetchPolicy.NoCache
            ..updateCacheHandlerKey = deleteCardHandlerKey,
        ))
        .map((r) {
          if (r.hasErrors) {
            throw OperationException(
              linkException: r.linkException,
              graphqlErrors: r.graphqlErrors,
            );
          }
        })
        .timeout(timeOutDuration)
        .first;
  }

  Future<void> addRepetition(String cardId, Confidence confidence) async {
    // final card = _graphQLRunner.cache
    //     .readFragment(GCardFragmentReq((b) => b.idFields = {'id': cardId}));

    final repetitionDate = DateTime.now();
    // final sm2Result = sm2.run(
    //   card.learningState.nextRepetition,
    //   confidence,
    //   reviewDate: repetitionDate,
    //   lastReviewDate: card.learningState.createdAt,
    //   streakKnown: card.learningState.streakKnown.toInt(),
    // final sm2Result = sm2.run(
    //   card.learningState.nextRepetition,
    //   confidence,
    //   reviewDate: repetitionDate,
    //   lastReviewDate: card.learningState.createdAt,
    //   streakKnown: card.learningState.streakKnown.toInt(),
    //   ease: card.learningState.ease,
    // );

    await _graphQLRunner.request(GAddRepetitionReq((b) {
      b
        ..vars.cardId = cardId
        ..vars.confidence = confidence == Confidence.known
            ? GConfidence.KNOWN
            : GConfidence.UNKNOWN
        ..vars.repetitionDate = repetitionDate
        ..fetchPolicy = FetchPolicy.NoCache
        ..updateCacheHandlerKey = addRepetitionHandlerKey;
      // b.optimisticResponse.addRepetition
      //   ..id = card.id
      //   ..front = card.front
      //   ..back = card.back
      //   ..createdAt = card.createdAt
      //   ..updatedAt = card.updatedAt
      //   ..deck.id = card.deck.id
      //   ..deck.name = card.deck.name
      //   ..learningState.nextRepetition = sm2Result.dueDate
      //   ..learningState.streakKnown = sm2Result.streakKnown
      //   ..learningState.ease = sm2Result.ease
      //   ..learningState.createdAt = DateTime.now();
      // if (card.mirrorCard?.id != null) {
      //   b.optimisticResponse.addRepetition.mirrorCard.id =
      // card.mirrorCard.id;
      // }
    })).map((r) {
      if (r.hasErrors) {
        throw OperationException(
          linkException: r.linkException,
          graphqlErrors: r.graphqlErrors,
        );
      }

      return r;
    }).firstWhere((r) => r.dataSource == DataSource.Link);
  }
}
