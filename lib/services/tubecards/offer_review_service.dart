import 'package:ferry/ferry.dart';
import 'package:injectable/injectable.dart';

import '../../graphql/graph_ql_runner.dart';
import '../../graphql/mutations/__generated__/delete_offer_review.req.gql.dart';
import '../../graphql/mutations/__generated__/upsert_offer_review.req.gql.dart';
import '../../graphql/operation_exception.dart';
import '../../graphql/update_cache_handlers/delete_offer_review_handler.dart';
import '../../graphql/update_cache_handlers/upsert_offer_review_handler.dart';

@singleton
class OfferReviewService {
  OfferReviewService(this._graphQLRunner);

  final GraphQLRunner _graphQLRunner;

  Future<void> upsert({
    required String offerId,
    required int rating,
    String? description,
  }) {
    final request = GUpsertOfferReviewReq(
      (b) => b
        ..fetchPolicy = FetchPolicy.NoCache
        ..vars.offerId = offerId
        ..vars.rating = rating
        ..vars.description = description
        ..updateCacheHandlerKey = upsertOfferReviewHandlerKey,
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

  Future<void> delete(String offerID) {
    final request = GDeleteOfferReviewReq(
      (b) => b
        ..fetchPolicy = FetchPolicy.NoCache
        ..vars.offerID = offerID
        ..updateCacheHandlerKey = deleteOfferReviewHandlerKey,
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
