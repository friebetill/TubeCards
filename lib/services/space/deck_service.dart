import 'package:ferry/ferry.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/average_learning_state.dart';
import '../../data/models/connection.dart';
import '../../data/models/deck.dart';
import '../../graphql/graph_ql_runner.dart';
import '../../graphql/mutations/__generated__/delete_deck.req.gql.dart';
import '../../graphql/mutations/__generated__/transfer_deck_ownership.req.gql.dart';
import '../../graphql/mutations/__generated__/upsert_deck.req.gql.dart';
import '../../graphql/operation_exception.dart';
import '../../graphql/queries/__generated__/deck.req.gql.dart';
import '../../graphql/queries/__generated__/deck_learning_state.req.gql.dart';
import '../../graphql/queries/__generated__/decks.data.gql.dart';
import '../../graphql/queries/__generated__/decks.req.gql.dart';
import '../../graphql/queries/__generated__/export_decks.req.gql.dart';
import '../../graphql/queries/__generated__/search_decks.data.gql.dart';
import '../../graphql/queries/__generated__/search_decks.req.gql.dart';
import '../../graphql/update_cache_handlers/decks_handler.dart';
import '../../graphql/update_cache_handlers/delete_deck_handler.dart';
import '../../graphql/update_cache_handlers/upsert_deck_handler.dart';

part './deck_service/get_all.dart';
part './deck_service/search_decks.dart';

@singleton
class DeckService {
  DeckService(this._graphQLRunner);

  final GraphQLRunner _graphQLRunner;

  Stream<Deck> get(String id, {FetchPolicy? fetchPolicy}) {
    Deck? deck;

    return _graphQLRunner
        .request(GDeckReq(
          (b) => b
            ..vars.id = id
            ..fetchPolicy = fetchPolicy,
        ))
        .distinct()
        .map((response) {
      if (response.data != null) {
        deck = Deck.fromJson(response.data!.deck.toJson());
      }
      if (deck == null && response.hasErrors) {
        throw OperationException(
          linkException: response.linkException,
          graphqlErrors: response.graphqlErrors,
        );
      }

      return deck!;
    });
  }

  Stream<AverageLearningState> getLearningState(
    String id, {
    FetchPolicy? fetchPolicy,
  }) {
    AverageLearningState? learningState;

    return _graphQLRunner
        .request(GDeckLearningStateReq(
          (b) => b
            ..vars.id = id
            ..fetchPolicy = fetchPolicy,
        ))
        .distinct()
        .map((response) {
      if (response.data != null) {
        learningState = AverageLearningState.fromJson(
          response.data!.deck.learningState.toJson(),
        );
      }
      if (learningState == null && response.hasErrors) {
        throw OperationException(
          linkException: response.linkException,
          graphqlErrors: response.graphqlErrors,
        );
      }

      return learningState!;
    });
  }

  /// Upserts the given [deck].
  ///
  /// Throws an [OperationException] if the deck is not upserted successfully.
  Future<Deck> upsert(Deck deck) {
    final request = GUpsertDeckReq((b) => b
      ..fetchPolicy = FetchPolicy.NoCache
      ..vars.id = deck.id
      ..vars.name = deck.name!
      ..vars.description = deck.description!
      ..vars.createMirrorCard = deck.createMirrorCard!
      ..vars.frontLanguage = deck.frontLanguage
      ..vars.backLanguage = deck.backLanguage
      ..vars.unsplashId = deck.coverImage!.unsplashId!
      ..vars.authorName = deck.coverImage!.authorName!
      ..vars.authorUrl = deck.coverImage!.authorUrl!
      ..vars.regularUrl = deck.coverImage!.regularUrl!
      ..vars.smallUrl = deck.coverImage!.smallUrl!
      ..vars.fullUrl = deck.coverImage!.fullUrl!
      ..updateCacheHandlerKey = upsertDeckHandlerKey);

    return _graphQLRunner.request(request).map((response) {
      if (response.hasErrors) {
        throw OperationException(
          linkException: response.linkException,
          graphqlErrors: response.graphqlErrors,
        );
      }

      return Deck.fromJson(response.data!.upsertDeck.toJson());
    }).first;
  }

  /// Removes the given [deck].
  ///
  /// Throws an [OperationException] if the deck is not removed successfully.
  Future<void> remove(Deck deck) {
    return _graphQLRunner
        .request(GDeleteDeckReq((b) => b
          ..fetchPolicy = FetchPolicy.NoCache
          ..vars.id = deck.id!
          ..updateCacheHandlerKey = deleteDeckHandlerKey))
        .map((response) {
      if (response.hasErrors) {
        throw OperationException(
          linkException: response.linkException,
          graphqlErrors: response.graphqlErrors,
        );
      }
    }).first;
  }

  /// Returns true if the decks of the current user have been transferred to
  /// the user with the given [recipientAuthToken], otherwise false.
  Future<bool> transferDecksOwnership(String recipientAuthToken) {
    return _graphQLRunner
        .request(GTransferDecksOwnershipReq(
      (b) => b
        ..vars.recipientAuthToken = recipientAuthToken
        ..fetchPolicy = FetchPolicy.NoCache,
    ))
        .map((r) {
      if (r.hasErrors) {
        throw OperationException(
          linkException: r.linkException,
          graphqlErrors: r.graphqlErrors,
        );
      }

      return true;
    }).first;
  }

  Future<bool> exportDecks(String toEmail) {
    return _graphQLRunner
        .request(GExportDecksReq(
      (b) => b
        ..vars.toEmail = toEmail
        ..fetchPolicy = FetchPolicy.NoCache,
    ))
        .map((r) {
      if (r.hasErrors) {
        throw OperationException(
          linkException: r.linkException,
          graphqlErrors: r.graphqlErrors,
        );
      }

      if (!r.data!.exportDecks.success) {
        throw ArgumentError();
      }

      return true;
    }).first;
  }
}
