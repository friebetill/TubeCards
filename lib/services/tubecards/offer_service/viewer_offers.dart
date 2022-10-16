part of '../offer_service.dart';

const int viewerOffersPageSize = 20;

extension ViewerOffers on OfferService {
  Stream<Connection<Offer>> viewerOffers({FetchPolicy? fetchPolicy}) {
    Connection<Offer>? offerConnection;

    final request = GViewerOffersReq(
      (b) => b
        // The unique ID prevents multiple requests from conflicting with each
        // other. This is important because otherwise the pagination of two
        // requests can mix and the wrong list is build.
        ..requestId = 'viewerOffers ${const Uuid().v4()}'
        ..vars.first = viewerOffersPageSize
        ..fetchPolicy = fetchPolicy,
    );

    return _graphQLRunner.request(request).distinct().map((r) {
      if (r.data != null) {
        offerConnection = Connection<Offer>.fromJson(
          r.data!.viewer.offerConnection.toJson(),
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

  Future<void> _refetch(GViewerOffersReq request) async {
    await _graphQLRunner
        .request(
          request.rebuild((b) => b.fetchPolicy = FetchPolicy.NetworkOnly),
        )
        .first;
  }

  Future<void> _fetchMore(
    GViewerOffersReq request,
    GViewerOffersData data,
  ) async {
    await _graphQLRunner
        .request(request.rebuild((b) => b
          ..vars.after = data.viewer.offerConnection.pageInfo.endCursor
          ..updateResult = updateViewerOffersResult))
        .first;
  }
}

GViewerOffersData? updateViewerOffersResult(
  GViewerOffersData? previous,
  GViewerOffersData? response,
) {
  if (previous == null) {
    return response;
  }

  return previous.rebuild((b) {
    final nodesMap = {
      for (var n in previous.viewer.offerConnection.nodes) n.id: n,
    };
    for (final node in response!.viewer.offerConnection.nodes) {
      if (!nodesMap.containsKey(node.id)) {
        b.viewer.offerConnection.nodes.add(node);
      }
    }
    b.viewer.offerConnection.pageInfo.endCursor =
        response.viewer.offerConnection.pageInfo.endCursor;
    b.viewer.offerConnection.pageInfo.hasNextPage =
        response.viewer.offerConnection.pageInfo.hasNextPage;
  });
}
