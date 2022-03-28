part of '../offer_service.dart';

const int newOffersPageSize = 20;

extension GetNew on OfferService {
  Stream<FlexibleSizeOfferConnection> getNew({FetchPolicy? fetchPolicy}) {
    FlexibleSizeOfferConnection? offerConnection;

    final request = GNewOffersReq(
      (b) => b
        // The unique ID prevents multiple requests from conflicting with each
        // other. This is important because otherwise the pagination of two
        // requests can mix and the wrong list is build.
        ..requestId = 'newOffers ${const Uuid().v4()}'
        ..vars.first = newOffersPageSize
        ..fetchPolicy = fetchPolicy,
    );

    return _graphQLRunner.request(request).distinct().map((r) {
      if (r.data != null) {
        offerConnection = FlexibleSizeOfferConnection.fromJson(
          r.data!.newOffers.toJson(),
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

  Future<void> _refetch(GNewOffersReq request) async {
    await _graphQLRunner
        .request(
          request.rebuild((b) => b.fetchPolicy = FetchPolicy.NetworkOnly),
        )
        .first;
  }

  Future<void> _fetchMore(
    GNewOffersReq request,
    GNewOffersData data,
  ) async {
    await _graphQLRunner
        .request(request.rebuild((b) => b
          ..vars.after = data.newOffers.pageInfo.endCursor
          ..updateResult = updateNewOffersResult))
        .first;
  }
}

GNewOffersData? updateNewOffersResult(
  GNewOffersData? previous,
  GNewOffersData? response,
) {
  if (previous == null) {
    return response;
  }

  return previous.rebuild((b) {
    final nodesMap = {
      for (var n in previous.newOffers.nodes) n.id: n,
    };
    for (final node in response!.newOffers.nodes) {
      if (!nodesMap.containsKey(node.id)) {
        b.newOffers.nodes.add(node);
      }
    }
    b.newOffers.pageInfo.endCursor = response.newOffers.pageInfo.endCursor;
    b.newOffers.pageInfo.hasNextPage = response.newOffers.pageInfo.hasNextPage;
  });
}
