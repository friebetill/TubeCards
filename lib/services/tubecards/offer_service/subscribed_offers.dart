part of '../offer_service.dart';

const int subscribedOffersPageSize = 20;

extension SubscribedOffers on OfferService {
  Stream<Connection<Offer>> subscribedOffers({
    FetchPolicy? fetchPolicy,
  }) {
    Connection<Offer>? offerConnection;

    final request = GSubscribedOffersReq(
      (b) => b
        // The unique ID prevents multiple requests from conflicting with each
        // other. This is important because otherwise the pagination of two
        // requests can mix and the wrong list is build.
        ..requestId = 'subscribedOffers ${const Uuid().v4()}'
        ..vars.first = subscribedOffersPageSize
        ..fetchPolicy = fetchPolicy,
    );

    return _graphQLRunner.request(request).distinct().map((r) {
      if (r.data != null) {
        offerConnection = Connection<Offer>.fromJson(
          r.data!.subscribedOffers.toJson(),
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

  Future<void> _refetch(GSubscribedOffersReq request) async {
    await _graphQLRunner
        .request(
          request.rebuild((b) => b.fetchPolicy = FetchPolicy.NetworkOnly),
        )
        .first;
  }

  Future<void> _fetchMore(
    GSubscribedOffersReq request,
    GSubscribedOffersData data,
  ) async {
    await _graphQLRunner
        .request(request.rebuild((b) => b
          ..vars.after = data.subscribedOffers.pageInfo.endCursor
          ..updateResult = updateSubscribedOffersResult))
        .first;
  }
}

GSubscribedOffersData? updateSubscribedOffersResult(
  GSubscribedOffersData? previous,
  GSubscribedOffersData? response,
) {
  if (previous == null) {
    return response;
  }

  return previous.rebuild((b) {
    final nodesMap = {
      for (var n in previous.subscribedOffers.nodes) n.id: n,
    };
    for (final node in response!.subscribedOffers.nodes) {
      if (!nodesMap.containsKey(node.id)) {
        b.subscribedOffers.nodes.add(node);
      }
    }
    b.subscribedOffers.pageInfo.endCursor =
        response.subscribedOffers.pageInfo.endCursor;
    b.subscribedOffers.pageInfo.hasNextPage =
        response.subscribedOffers.pageInfo.hasNextPage;
  });
}
