import 'dart:async';
import 'dart:isolate';

import '../../../../services/space/card_service.dart';
import '../../../../services/space/deck_member_service.dart';
import '../../../../services/space/deck_service.dart';
import '../../../../services/space/offer_service.dart';
import '../../../graph_ql_client.dart';
import '../../../mutations/add_offer.req.gql.dart';
import '../../../mutations/add_repetition.req.gql.dart';
import '../../../mutations/create_anonymous_user.req.gql.dart';
import '../../../mutations/delete_card.req.gql.dart';
import '../../../mutations/delete_deck.req.gql.dart';
import '../../../mutations/delete_deck_invite.req.gql.dart';
import '../../../mutations/delete_deck_member.req.gql.dart';
import '../../../mutations/delete_offer.req.gql.dart';
import '../../../mutations/delete_offer_review.req.gql.dart';
import '../../../mutations/delete_user.req.gql.dart';
import '../../../mutations/get_presigned_s3_post_data.req.gql.dart';
import '../../../mutations/insert_10_cards.req.gql.dart';
import '../../../mutations/insert_deck_invite.req.gql.dart';
import '../../../mutations/join_deck.req.gql.dart';
import '../../../mutations/log_in.req.gql.dart';
import '../../../mutations/sign_up.req.gql.dart';
import '../../../mutations/subscribe.req.gql.dart';
import '../../../mutations/transfer_deck_ownership.req.gql.dart';
import '../../../mutations/trigger_password_reset.req.gql.dart';
import '../../../mutations/unsubscribe.req.gql.dart';
import '../../../mutations/update_deck_member.req.gql.dart';
import '../../../mutations/update_user.req.gql.dart';
import '../../../mutations/upsert_card.req.gql.dart';
import '../../../mutations/upsert_deck.req.gql.dart';
import '../../../mutations/upsert_mirror_card.req.gql.dart';
import '../../../mutations/upsert_offer_review.req.gql.dart';
import '../../../queries/card.req.gql.dart';
import '../../../queries/cards.req.gql.dart';
import '../../../queries/deck.req.gql.dart';
import '../../../queries/deck_cards.req.gql.dart';
import '../../../queries/deck_invite.req.gql.dart';
import '../../../queries/deck_learning_state.req.gql.dart';
import '../../../queries/deck_member.req.gql.dart';
import '../../../queries/deck_members.req.gql.dart';
import '../../../queries/decks.req.gql.dart';
import '../../../queries/due_cards.req.gql.dart';
import '../../../queries/due_cards_of_deck.req.gql.dart';
import '../../../queries/export_decks.req.gql.dart';
import '../../../queries/new_offers.req.gql.dart';
import '../../../queries/offer.req.gql.dart';
import '../../../queries/popular_offers.req.gql.dart';
import '../../../queries/search_cards.req.gql.dart';
import '../../../queries/search_decks.req.gql.dart';
import '../../../queries/search_offers.req.gql.dart';
import '../../../queries/subscribed_offers.req.gql.dart';
import '../../../queries/user_learning_state.req.gql.dart';
import '../../../queries/viewer.req.gql.dart';
import '../../../queries/viewer_offers.req.gql.dart';
import 'graph_ql_command.dart';

/// Command to make a GraphQL request.
class RequestCommand implements GraphQLCommand {
  RequestCommand({required this.requestJson});

  factory RequestCommand.fromArgumentMap(Map<String, dynamic> args) {
    return RequestCommand(
      requestJson: args['requestJson'] as Map<String, dynamic>,
    );
  }

  /// Identifies this command during (de)serialization.
  static const identifier = 'request';

  final Map<String, dynamic> requestJson;

  late StreamSubscription _resultSubscription;

  @override
  Map<String, dynamic> getArgumentMap() {
    return {'requestJson': requestJson};
  }

  @override
  String getIdentifier() => identifier;

  @override
  Future<void> execute(GraphQLClient graphQLClient, SendPort? sendPort) async {
    final result = _sendRequest(graphQLClient);

    _resultSubscription = result.distinct().listen(sendPort!.send);
  }

  Stream _sendRequest(GraphQLClient graphQLClient) {
    final operationName = requestJson['operation']['operationName'];
    switch (operationName) {
      // Queries
      case 'Card':
        return graphQLClient.request(GCardReq.fromJson(requestJson)!);
      case 'Cards':
        return graphQLClient.request(GCardsReq.fromJson(requestJson)!);
      case 'DeckCards':
        return graphQLClient.request(GDeckCardsReq.fromJson(requestJson)!
            .rebuild((b) => b.updateResult = updateDeckCardsResult));
      case 'DeckInvite':
        return graphQLClient.request(GDeckInviteReq.fromJson(requestJson)!);
      case 'DeckLearningState':
        return graphQLClient
            .request(GDeckLearningStateReq.fromJson(requestJson)!);
      case 'DeckMember':
        return graphQLClient.request(GDeckMemberReq.fromJson(requestJson)!);
      case 'DeckMembers':
        return graphQLClient.request(GDeckMembersReq.fromJson(requestJson)!
            .rebuild((b) => b.updateResult = updateDeckMembersResult));
      case 'Deck':
        return graphQLClient.request(GDeckReq.fromJson(requestJson)!);
      case 'Decks':
        return graphQLClient.request(GDecksReq.fromJson(requestJson)!
            .rebuild((b) => b.updateResult = updateDecksResult));
      case 'DueCards':
        return graphQLClient.request(GDueCardsReq.fromJson(requestJson)!
            .rebuild((b) => b.updateResult = updateDueCardsResult));
      case 'DueCardsOfDeck':
        return graphQLClient.request(GDueCardsOfDeckReq.fromJson(requestJson)!
            .rebuild((b) => b.updateResult = updateDueCardsOfDeckResult));
      case 'ExportDecks':
        return graphQLClient.request(GExportDecksReq.fromJson(requestJson)!);
      case 'NewOffers':
        return graphQLClient.request(GNewOffersReq.fromJson(requestJson)!);
      case 'Offer':
        return graphQLClient.request(GOfferReq.fromJson(requestJson)!);
      case 'PopularOffers':
        return graphQLClient.request(GPopularOffersReq.fromJson(requestJson)!);
      case 'SearchCards':
        return graphQLClient.request(GSearchCardsReq.fromJson(requestJson)!
            .rebuild((b) => b.updateResult = updateSearchCardsResult));
      case 'SearchDecks':
        return graphQLClient.request(GSearchDecksReq.fromJson(requestJson)!
            .rebuild((b) => b.updateResult = updateSearchDecksResult));
      case 'SubscribedOffers':
        return graphQLClient.request(GSubscribedOffersReq.fromJson(requestJson)!
            .rebuild((b) => b.updateResult = updateSubscribedOffersResult));
      case 'SearchOffers':
        return graphQLClient.request(GSearchOffersReq.fromJson(requestJson)!
            .rebuild((b) => b.updateResult = updateSearchOffersResult));
      case 'UserLearningState':
        return graphQLClient
            .request(GUserLearningStateReq.fromJson(requestJson)!);
      case 'Viewer':
        return graphQLClient.request(GViewerReq.fromJson(requestJson)!);
      case 'ViewerOffers':
        return graphQLClient.request(GViewerOffersReq.fromJson(requestJson)!);
      // Mutations
      case 'AddOffer':
        return graphQLClient.request(GAddOfferReq.fromJson(requestJson)!);
      case 'AddRepetition':
        return graphQLClient.request(GAddRepetitionReq.fromJson(requestJson)!);
      case 'CreateAnonymousUser':
        return graphQLClient
            .request(GCreateAnonymousUserReq.fromJson(requestJson)!);
      case 'DeleteCard':
        return graphQLClient.request(GDeleteCardReq.fromJson(requestJson)!);
      case 'DeleteDeckInvite':
        return graphQLClient
            .request(GDeleteDeckInviteReq.fromJson(requestJson)!);
      case 'DeleteDeckMember':
        return graphQLClient
            .request(GDeleteDeckMemberReq.fromJson(requestJson)!);
      case 'DeleteDeck':
        return graphQLClient.request(GDeleteDeckReq.fromJson(requestJson)!);
      case 'DeleteOffer':
        return graphQLClient.request(GDeleteOfferReq.fromJson(requestJson)!);
      case 'DeleteOfferReview':
        return graphQLClient
            .request(GDeleteOfferReviewReq.fromJson(requestJson)!);
      case 'DeleteUser':
        return graphQLClient.request(GDeleteUserReq.fromJson(requestJson)!);
      case 'GetPreSignedS3PostData':
        return graphQLClient
            .request(GGetPreSignedS3PostDataReq.fromJson(requestJson)!);
      case 'InsertDeckInvite':
        return graphQLClient
            .request(GInsertDeckInviteReq.fromJson(requestJson)!);
      case 'JoinDeck':
        return graphQLClient.request(GJoinDeckReq.fromJson(requestJson)!);
      case 'LogIn':
        return graphQLClient.request(GLogInReq.fromJson(requestJson)!);
      case 'SignUp':
        return graphQLClient.request(GSignUpReq.fromJson(requestJson)!);
      case 'Subscribe':
        return graphQLClient.request(GSubscribeReq.fromJson(requestJson)!);
      case 'Unsubscribe':
        return graphQLClient.request(GUnsubscribeReq.fromJson(requestJson)!);
      case 'TransferDecksOwnership':
        return graphQLClient
            .request(GTransferDecksOwnershipReq.fromJson(requestJson)!);
      case 'TriggerPasswordReset':
        return graphQLClient
            .request(GTriggerPasswordResetReq.fromJson(requestJson)!);
      case 'UpdateUser':
        return graphQLClient.request(GUpdateUserReq.fromJson(requestJson)!);
      case 'UpsertCard':
        return graphQLClient.request(GUpsertCardReq.fromJson(requestJson)!);
      case 'Insert10Cards':
        return graphQLClient.request(GInsert10CardsReq.fromJson(requestJson)!);
      case 'UpsertDeck':
        return graphQLClient.request(GUpsertDeckReq.fromJson(requestJson)!);
      case 'UpsertOfferReview':
        return graphQLClient
            .request(GUpsertOfferReviewReq.fromJson(requestJson)!);
      case 'UpdateDeckMember':
        return graphQLClient
            .request(GUpdateDeckMemberReq.fromJson(requestJson)!);
      case 'UpsertMirrorCard':
        return graphQLClient
            .request(GUpsertMirrorCardReq.fromJson(requestJson)!);
      default:
        throw ArgumentError('Unknown operation: $operationName');
    }
  }

  @override
  bool get isDisposable => true;

  @override
  Future<void> dispose() async {
    await _resultSubscription.cancel();
  }
}
