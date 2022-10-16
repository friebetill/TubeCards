import 'dart:async';
import 'dart:isolate';

import '../../../../services/tubecards/card_service.dart';
import '../../../../services/tubecards/deck_member_service.dart';
import '../../../../services/tubecards/deck_service.dart';
import '../../../../services/tubecards/offer_service.dart';
import '../../../graph_ql_client.dart';
import '../../../mutations/__generated__/add_offer.req.gql.dart';
import '../../../mutations/__generated__/add_repetition.req.gql.dart';
import '../../../mutations/__generated__/create_anonymous_user.req.gql.dart';
import '../../../mutations/__generated__/delete_card.req.gql.dart';
import '../../../mutations/__generated__/delete_deck.req.gql.dart';
import '../../../mutations/__generated__/delete_deck_invite.req.gql.dart';
import '../../../mutations/__generated__/delete_deck_member.req.gql.dart';
import '../../../mutations/__generated__/delete_offer.req.gql.dart';
import '../../../mutations/__generated__/delete_offer_review.req.gql.dart';
import '../../../mutations/__generated__/delete_user.req.gql.dart';
import '../../../mutations/__generated__/get_presigned_s3_post_data.req.gql.dart';
import '../../../mutations/__generated__/insert_10_cards.req.gql.dart';
import '../../../mutations/__generated__/insert_deck_invite.req.gql.dart';
import '../../../mutations/__generated__/join_deck.req.gql.dart';
import '../../../mutations/__generated__/log_in.req.gql.dart';
import '../../../mutations/__generated__/sendFeedback.req.gql.dart';
import '../../../mutations/__generated__/sign_up.req.gql.dart';
import '../../../mutations/__generated__/subscribe.req.gql.dart';
import '../../../mutations/__generated__/transfer_deck_ownership.req.gql.dart';
import '../../../mutations/__generated__/trigger_password_reset.req.gql.dart';
import '../../../mutations/__generated__/unsubscribe.req.gql.dart';
import '../../../mutations/__generated__/update_deck_member.req.gql.dart';
import '../../../mutations/__generated__/update_user.req.gql.dart';
import '../../../mutations/__generated__/upsert_card.req.gql.dart';
import '../../../mutations/__generated__/upsert_deck.req.gql.dart';
import '../../../mutations/__generated__/upsert_mirror_card.req.gql.dart';
import '../../../mutations/__generated__/upsert_offer_review.req.gql.dart';
import '../../../queries/__generated__/card.req.gql.dart';
import '../../../queries/__generated__/cards.req.gql.dart';
import '../../../queries/__generated__/deck.req.gql.dart';
import '../../../queries/__generated__/deck_cards.req.gql.dart';
import '../../../queries/__generated__/deck_invite.req.gql.dart';
import '../../../queries/__generated__/deck_learning_state.req.gql.dart';
import '../../../queries/__generated__/deck_member.req.gql.dart';
import '../../../queries/__generated__/deck_members.req.gql.dart';
import '../../../queries/__generated__/decks.req.gql.dart';
import '../../../queries/__generated__/due_cards.req.gql.dart';
import '../../../queries/__generated__/due_cards_of_deck.req.gql.dart';
import '../../../queries/__generated__/export_decks.req.gql.dart';
import '../../../queries/__generated__/new_offers.req.gql.dart';
import '../../../queries/__generated__/offer.req.gql.dart';
import '../../../queries/__generated__/popular_offers.req.gql.dart';
import '../../../queries/__generated__/search_cards.req.gql.dart';
import '../../../queries/__generated__/search_decks.req.gql.dart';
import '../../../queries/__generated__/search_offers.req.gql.dart';
import '../../../queries/__generated__/subscribed_offers.req.gql.dart';
import '../../../queries/__generated__/user_learning_state.req.gql.dart';
import '../../../queries/__generated__/viewer.req.gql.dart';
import '../../../queries/__generated__/viewer_offers.req.gql.dart';
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
      case 'SendFeedback':
        return graphQLClient.request(GSendFeedbackReq.fromJson(requestJson)!);
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
