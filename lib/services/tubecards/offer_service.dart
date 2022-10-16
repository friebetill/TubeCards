import 'package:ferry/ferry.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/connection.dart';
import '../../data/models/flexible_size_offer_connection.dart';
import '../../data/models/offer.dart';
import '../../graphql/graph_ql_runner.dart';
import '../../graphql/mutations/__generated__/add_offer.req.gql.dart';
import '../../graphql/mutations/__generated__/delete_offer.req.gql.dart';
import '../../graphql/mutations/__generated__/subscribe.req.gql.dart';
import '../../graphql/mutations/__generated__/unsubscribe.req.gql.dart';
import '../../graphql/operation_exception.dart';
import '../../graphql/queries/__generated__/new_offers.data.gql.dart';
import '../../graphql/queries/__generated__/new_offers.req.gql.dart';
import '../../graphql/queries/__generated__/offer.req.gql.dart';
import '../../graphql/queries/__generated__/popular_offers.data.gql.dart';
import '../../graphql/queries/__generated__/popular_offers.req.gql.dart';
import '../../graphql/queries/__generated__/search_offers.data.gql.dart';
import '../../graphql/queries/__generated__/search_offers.req.gql.dart';
import '../../graphql/queries/__generated__/subscribed_offers.data.gql.dart';
import '../../graphql/queries/__generated__/subscribed_offers.req.gql.dart';
import '../../graphql/queries/__generated__/viewer_offers.data.gql.dart';
import '../../graphql/queries/__generated__/viewer_offers.req.gql.dart';
import '../../graphql/update_cache_handlers/add_offer_handler.dart';
import '../../graphql/update_cache_handlers/delete_offer_handler.dart';
import '../../graphql/update_cache_handlers/subscribe_handler.dart';
import '../../graphql/update_cache_handlers/unsubscribe_handler.dart';
import 'card_service.dart';

part 'offer_service/get_new.dart';
part 'offer_service/get_popular.dart';
part 'offer_service/search_offers.dart';
part 'offer_service/subscribed_offers.dart';
part 'offer_service/viewer_offers.dart';

@singleton
class OfferService {
  OfferService(this._graphQLRunner);

  final GraphQLRunner _graphQLRunner;

  Stream<Offer> get(String offerId, {FetchPolicy? fetchPolicy}) {
    Offer? offer;

    return _graphQLRunner
        .request(GOfferReq((b) => b
          ..vars.id = offerId
          ..fetchPolicy = fetchPolicy))
        .distinct()
        .map((response) {
      if (response.data?.offer != null) {
        offer = Offer.fromJson(response.data!.offer.toJson());
      }
      if (offer == null && response.hasErrors) {
        throw OperationException(
          linkException: response.linkException,
          graphqlErrors: response.graphqlErrors,
        );
      }

      return offer!;
    });
  }

  Future<void> subscribe(String offerId) {
    final request = GSubscribeReq(
      (b) => b
        ..fetchPolicy = FetchPolicy.NoCache
        ..vars.offerId = offerId
        ..vars.first = dueCardsPageSize
        ..updateCacheHandlerKey = subscribeHandlerKey,
    );

    return _graphQLRunner.request(request).map((response) {
      if (response.hasErrors) {
        throw OperationException(
          linkException: response.linkException,
          graphqlErrors: response.graphqlErrors,
        );
      }
    }).first;
  }

  Future<void> unsubscribe(String offerId) {
    final request = GUnsubscribeReq(
      (b) => b
        ..fetchPolicy = FetchPolicy.NoCache
        ..vars.offerId = offerId
        ..updateCacheHandlerKey = unsubscribeHandlerKey,
    );

    return _graphQLRunner.request(request).map((response) {
      if (response.hasErrors) {
        throw OperationException(
          linkException: response.linkException,
          graphqlErrors: response.graphqlErrors,
        );
      }
    }).first;
  }

  Future<Offer> addOffer(String deckID) {
    final request = GAddOfferReq(
      (b) => b
        ..fetchPolicy = FetchPolicy.NoCache
        ..vars.deckID = deckID
        ..updateCacheHandlerKey = addOfferHandlerKey,
    );

    return _graphQLRunner.request(request).map((response) {
      if (response.hasErrors) {
        throw OperationException(
          linkException: response.linkException,
          graphqlErrors: response.graphqlErrors,
        );
      }

      return Offer.fromJson(response.data!.addOffer.offer.toJson());
    }).first;
  }

  Future<void> deleteOffer(String offerID) {
    final request = GDeleteOfferReq(
      (b) => b
        ..fetchPolicy = FetchPolicy.NoCache
        ..vars.offerID = offerID
        ..updateCacheHandlerKey = deleteOfferHandlerKey,
    );

    return _graphQLRunner.request(request).map((response) {
      if (response.hasErrors) {
        throw OperationException(
          linkException: response.linkException,
          graphqlErrors: response.graphqlErrors,
        );
      }
    }).first;
  }
}
