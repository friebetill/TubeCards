part of '../offer_service.dart';

const int popularOffersPageSize = 20;

extension GetPopular on OfferService {
  Stream<Connection<Offer>> getPopular({FetchPolicy? fetchPolicy}) {
    Connection<Offer>? offerConnection;

    final request = GPopularOffersReq(
      (b) => b
        // The unique ID prevents multiple requests from conflicting with each
        // other. This is important because otherwise the pagination of two
        // requests can mix and the wrong list is build.
        ..requestId = 'popularOffers ${const Uuid().v4()}'
        ..vars.first = popularOffersPageSize
        ..fetchPolicy = fetchPolicy,
    );

    return _graphQLRunner.request(request).distinct().map((r) {
      if (r.data != null) {
        offerConnection = Connection<Offer>.fromJson(
          r.data!.popularOffers.toJson(),
        ).copyWith(
          refetch: () => _refetch(request),
          fetchMore: () => _fetchMore(request, r.data!),
        );
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

  Future<void> _refetch(GPopularOffersReq request) async {
    await _graphQLRunner
        .request(
          request.rebuild((b) => b.fetchPolicy = FetchPolicy.NetworkOnly),
        )
        .first;
  }

  Future<void> _fetchMore(
    GPopularOffersReq request,
    GPopularOffersData data,
  ) async {
    await _graphQLRunner
        .request(request.rebuild((b) => b
          ..vars.after = data.popularOffers.pageInfo.endCursor
          ..updateResult = updatePopularOffersResult))
        .first;
  }
}

GPopularOffersData? updatePopularOffersResult(
  GPopularOffersData? previous,
  GPopularOffersData? response,
) {
  if (previous == null) {
    return response;
  }

  return previous.rebuild((b) {
    final nodesMap = {
      for (var n in previous.popularOffers.nodes) n.id: n,
    };
    for (final node in response!.popularOffers.nodes) {
      if (!nodesMap.containsKey(node.id)) {
        b.popularOffers.nodes.add(node);
      }
    }
    b.popularOffers.pageInfo.endCursor =
        response.popularOffers.pageInfo.endCursor;
    b.popularOffers.pageInfo.hasNextPage =
        response.popularOffers.pageInfo.hasNextPage;
  });
}
