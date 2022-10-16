part of '../offer_service.dart';

const int offersPageSize = 20;

extension Search on OfferService {
  Stream<Connection<Offer>> search({
    required String searchTerm,
    FetchPolicy? fetchPolicy,
  }) {
    Connection<Offer>? offerConnection;

    final request = GSearchOffersReq((b) {
      b
        // The unique ID prevents multiple requests from conflicting with each
        // other. This is important because otherwise the pagination of two
        // requests can mix and the wrong list is build.
        ..requestId = 'SearchOffers ${const Uuid().v4()}'
        ..fetchPolicy = fetchPolicy
        ..vars.searchTerm = searchTerm
        ..vars.first = offersPageSize;
    });

    return _graphQLRunner.request(request).distinct().map((r) {
      if (r.data != null) {
        offerConnection = Connection<Offer>.fromJson(
          r.data!.searchOffers.toJson(),
        ).copyWith(fetchMore: () => _fetchMore(request, r.data!));
      }
      if (offerConnection == null && r.hasErrors) {
        throw OperationException(
          linkException: r.linkException,
          graphqlErrors: r.graphqlErrors,
        );
      }

      return offerConnection!;
    });
  }

  Future<void> _fetchMore(
    GSearchOffersReq request,
    GSearchOffersData data,
  ) async {
    await _graphQLRunner
        .request(
          request.rebuild((b) => b
            ..vars.after = data.searchOffers.pageInfo.endCursor
            ..updateResult = updateSearchOffersResult),
        )
        .first;
  }
}

GSearchOffersData? updateSearchOffersResult(
  GSearchOffersData? previous,
  GSearchOffersData? response,
) {
  if (previous == null) {
    return response;
  }

  return previous.rebuild((b) {
    final nodesMap = {
      for (var n in previous.searchOffers.nodes) n.id: n,
    };
    for (final node in response!.searchOffers.nodes) {
      if (!nodesMap.containsKey(node.id)) {
        b.searchOffers.nodes.add(node);
      }
    }
    b.searchOffers.pageInfo.endCursor =
        response.searchOffers.pageInfo.endCursor;
    b.searchOffers.pageInfo.hasNextPage =
        response.searchOffers.pageInfo.hasNextPage;
  });
}
