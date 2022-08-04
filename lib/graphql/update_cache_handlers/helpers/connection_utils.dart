import 'package:ferry/typed_links.dart';

/// Returns the last request that has a cached response.
Request? getRequestToLastPage<Data, Variables,
    Request extends OperationRequest<Data, Variables>>(
  CacheProxy proxy,
  Request firstPageRequest,
  Request Function(Request, Data) buildNextPageRequest,
  bool Function(Data?) hasNextPage,
) {
  var pageRequest = firstPageRequest;
  var cachedResponse = proxy.readQuery(firstPageRequest);

  if (cachedResponse == null) {
    return null;
  }

  while (hasNextPage(cachedResponse)) {
    final nextPageRequest =
        buildNextPageRequest(pageRequest, cachedResponse as Data);
    final nextPage = proxy.readQuery(nextPageRequest);

    if (nextPage == null) {
      return pageRequest;
    }

    pageRequest = nextPageRequest;
    cachedResponse = nextPage;
  }

  return pageRequest;
}

/// Returns the request to the page that fulfills the [predicate].
///
/// Returns null if no page fulfills the predicate.
Request? getRequestToPredicatePage<Data, Variables,
    Request extends OperationRequest<Data, Variables>>(
  CacheProxy proxy,
  Request firstPageRequest,
  bool Function(Data) predicate,
  Request Function(Request, Data) buildNextPageRequest,
  bool Function(Data) hasNextPage,
) {
  var pageRequest = firstPageRequest;
  var cachedResponse = proxy.readQuery(pageRequest);

  while (cachedResponse != null) {
    if (predicate(cachedResponse)) {
      return pageRequest;
    }

    if (!hasNextPage(cachedResponse)) {
      return null;
    }

    pageRequest = buildNextPageRequest(pageRequest, cachedResponse);
    cachedResponse = proxy.readQuery(pageRequest);
  }

  return null;
}

/// Returns all page requests that have a cached response.
List<Request> getAllPageRequests<Data, Variables,
    Request extends OperationRequest<Data, Variables>>(
  CacheProxy proxy,
  Request firstPageRequest,
  Request Function(Request, Data) buildNextPageRequest,
  bool Function(Data) hasNextPage,
) {
  final pageRequests = <Request>[];
  var pageRequest = firstPageRequest;
  var cachedResponse = proxy.readQuery(pageRequest);

  while (cachedResponse != null) {
    pageRequests.add(pageRequest);

    if (hasNextPage(cachedResponse)) {
      pageRequest = buildNextPageRequest(pageRequest, cachedResponse);
      cachedResponse = proxy.readQuery(pageRequest);
    } else {
      cachedResponse = null;
    }
  }

  return pageRequests;
}
