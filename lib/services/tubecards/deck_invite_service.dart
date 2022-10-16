import 'package:ferry/ferry.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/deck_invite.dart';
import '../../data/models/role.dart';
import '../../graphql/graph_ql_runner.dart';
import '../../graphql/mutations/__generated__/delete_deck_invite.req.gql.dart';
import '../../graphql/mutations/__generated__/insert_deck_invite.req.gql.dart';
import '../../graphql/mutations/__generated__/join_deck.req.gql.dart';
import '../../graphql/operation_exception.dart';
import '../../graphql/queries/__generated__/deck_invite.req.gql.dart';
import '../../graphql/update_cache_handlers/delete_deck_invite_handler.dart';
import '../../graphql/update_cache_handlers/insert_deck_invite_handler.dart';
import '../../graphql/update_cache_handlers/join_deck_handler.dart';
import 'card_service.dart';
import 'user_service.dart';

@singleton
class DeckInviteService {
  DeckInviteService(this._graphQLRunner);

  final GraphQLRunner _graphQLRunner;

  Stream<DeckInvite> get(String deckInviteId, {FetchPolicy? fetchPolicy}) {
    DeckInvite? invite;

    final request = GDeckInviteReq(
      (b) => b
        ..vars.deckInviteId = deckInviteId
        ..fetchPolicy = fetchPolicy,
    );

    return _graphQLRunner.request(request).distinct().map((response) {
      if (response.data != null) {
        invite = DeckInvite.fromJson(response.data!.deckInvite.toJson());
      }
      if (invite == null && response.hasErrors) {
        throw OperationException(
          linkException: response.linkException,
          graphqlErrors: response.graphqlErrors,
        );
      }

      return invite!;
    });
  }

  Future<DeckInvite> insert(String deckId, Role role) {
    final request = GInsertDeckInviteReq((b) => b
      ..vars.deckId = deckId
      ..vars.roleId = role.id
      ..updateCacheHandlerKey = insertDeckInviteHandlerKey);

    return _graphQLRunner.request(request).map((response) {
      if (response.hasErrors) {
        throw OperationException(
          linkException: response.linkException,
          graphqlErrors: response.graphqlErrors,
        );
      }

      return DeckInvite.fromJson(
        response.data!.insertDeckInvite.deckInvite.toJson(),
      );
    }).first;
  }

  /// Adds the current user to the deck via the deck invite [deckInviteId].
  Future<void> joinDeck(String deckInviteId) {
    return _graphQLRunner
        .request(GJoinDeckReq((b) => b
          ..fetchPolicy = FetchPolicy.NoCache
          ..vars.deckInviteId = deckInviteId
          ..vars.firstOfDueCardConnection = dueCardsPageSize
          ..updateCacheHandlerKey = joinDeckHandlerKey))
        .map((response) {
          if (response.hasErrors) {
            throw OperationException(
              linkException: response.linkException,
              graphqlErrors: response.graphqlErrors,
            );
          }
        })
        .timeout(timeOutDuration)
        .first;
  }

  Future<void> remove(DeckInvite deckInvite) {
    return _graphQLRunner
        .request(GDeleteDeckInviteReq((b) => b
          ..fetchPolicy = FetchPolicy.NoCache
          ..vars.id = deckInvite.id
          ..updateCacheHandlerKey = deleteDeckInviteHandlerKey))
        .map((response) {
      if (response.hasErrors) {
        throw OperationException(
          linkException: response.linkException,
          graphqlErrors: response.graphqlErrors,
        );
      }
    }).first;
  }
}
