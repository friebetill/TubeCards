import 'dart:async';

import 'package:ferry/typed_links.dart';

import '../utils/config.dart';
import 'links/http_auth_link.dart';
import 'update_cache_handlers/add_offer_handler.dart';
import 'update_cache_handlers/add_repetition_handler.dart';
import 'update_cache_handlers/create_anonymous_handler.dart';
import 'update_cache_handlers/deck_cards_handler.dart';
import 'update_cache_handlers/deck_members_handler.dart';
import 'update_cache_handlers/decks_handler.dart';
import 'update_cache_handlers/delete_card_handler.dart';
import 'update_cache_handlers/delete_deck_handler.dart';
import 'update_cache_handlers/delete_deck_invite_handler.dart';
import 'update_cache_handlers/delete_deck_member_handler.dart';
import 'update_cache_handlers/delete_offer_handler.dart';
import 'update_cache_handlers/delete_offer_review_handler.dart';
import 'update_cache_handlers/due_cards_handler.dart';
import 'update_cache_handlers/due_cards_of_deck_handler.dart';
import 'update_cache_handlers/insert_deck_invite_handler.dart';
import 'update_cache_handlers/join_deck_handler.dart';
import 'update_cache_handlers/login_handler.dart';
import 'update_cache_handlers/sign_up_handler.dart';
import 'update_cache_handlers/subscribe_handler.dart';
import 'update_cache_handlers/unsubscribe_handler.dart';
import 'update_cache_handlers/update_deck_member_handler.dart';
import 'update_cache_handlers/update_user_handler.dart';
import 'update_cache_handlers/upsert_card_handler.dart';
import 'update_cache_handlers/upsert_deck_handler.dart';
import 'update_cache_handlers/upsert_mirror_card_handler.dart';
import 'update_cache_handlers/upsert_offer_review_handler.dart';

class GraphQLClient extends TypedLink {
  GraphQLClient(this._cache)
      : _link = HttpAuthLink(
          graphQLEndpoint: spaceGraphQlUrl,
          token: _cache.store.get(_authTokenKey)?['token'] as String? ?? '',
        ) {
    _typedLink = TypedLink.from([
      const ErrorTypedLink(),
      RequestControllerTypedLink(),
      const AddTypenameTypedLink(),
      UpdateCacheTypedLink(
        cache: _cache,
        updateCacheHandlers: {
          // Queries
          deckCardsHandlerKey: deckCardsHandler,
          deckMembersHandlerKey: deckMembersHandler,
          decksHandlerKey: decksHandler,
          dueCardsHandlerKey: dueCardsHandler,
          dueCardsOfDeckHandlerKey: dueCardsOfDeckHandler,
          // Mutations
          addOfferHandlerKey: addOfferHandler,
          addRepetitionHandlerKey: addRepetitionHandler,
          createAnonymousUserHandlerKey: createAnonymousUserHandler,
          deleteCardHandlerKey: deleteCardHandler,
          deleteDeckHandlerKey: deleteDeckHandler,
          deleteDeckInviteHandlerKey: deleteDeckInviteHandler,
          deleteDeckMemberHandlerKey: deleteDeckMemberHandler,
          deleteOfferHandlerKey: deleteOfferHandler,
          deleteOfferReviewHandlerKey: deleteOfferReviewHandler,
          insertDeckInviteHandlerKey: insertDeckInviteHandler,
          joinDeckHandlerKey: joinDeckHandler,
          logInHandlerKey: logInHandler,
          signUpHandlerKey: signUpHandler,
          subscribeHandlerKey: subscribeHandler,
          unsubscribeHandlerKey: unsubscribeHandler,
          updateDeckMemberHandlerKey: updateDeckMemberHandler,
          updateUserHandlerKey: updateUserHandler,
          upsertCardHandlerKey: upsertCardHandler,
          upsertDeckHandlerKey: upsertDeckHandler,
          upsertMirrorCardHandlerKey: upsertMirrorCardHandler,
          upsertOfferReviewHandlerKey: upsertOfferReviewHandler,
        },
      ),
      FetchPolicyTypedLink(link: _link, cache: _cache),
    ]);
    // Retain the authentication token to prevent it from being deleted during
    // garbage collection.
    _cache.retain(_authTokenKey);
  }

  /// The name of the Hive box for the GraphQL database.
  static const graphQLHiveBoxName = 'graphql';

  /// The key of the authentication token in the GraphQL database.
  static const _authTokenKey = 'authToken';

  /// The type policies for the GraphQL database.
  ///
  /// This allows for example to change the default key "id".
  static final typePolicies = {
    'DeckMember': TypePolicy(
      keyFields: {
        'deck': {'id': true},
        'user': {'id': true},
      },
    ),
  };

  final HttpAuthLink _link;
  final Cache _cache;
  late TypedLink _typedLink;

  @override
  Stream<OperationResponse<TData, TVars>> request<TData, TVars>(
    OperationRequest<TData, TVars> request, [
    Stream<OperationResponse<TData, TVars>> Function(
      OperationRequest<TData, TVars>,
    )?
        forward,
  ]) =>
      _typedLink.request(request, forward);

  /// Sets the authentication token for GraphQL requests.
  set authToken(String authToken) {
    _link.token = authToken;
    _cache.store.put(_authTokenKey, {'token': authToken});
  }

  // Returns the authentication token for GraphQL requests.
  String get authToken {
    return _cache.store.get(_authTokenKey)?['token'] as String? ?? '';
  }

  // Clears the cache and thus all stored GraphQL data.
  void clear() => _cache.clear();
}
