import 'dart:math';

import 'package:ferry/typed_links.dart';

import '../../queries/__generated__/cards.req.gql.dart';
import 'connection_utils.dart';

class CardsHelper {
  CardsHelper(this.proxy);

  final CacheProxy proxy;

  void changeTotalCountBy(int amount) {
    final pageRequests = getAllPageRequests(
      proxy,
      GCardsReq(),
      (_, __) => GCardsReq(),
      (_) => false,
    );

    for (final pageRequest in pageRequests) {
      final cachedResponse = proxy.readQuery(pageRequest)!;

      final updatedResponse = cachedResponse.rebuild((b) => b
          .viewer
          .cardConnection
          .totalCount = max(0, b.viewer.cardConnection.totalCount! + amount));

      proxy.writeQuery(pageRequest, updatedResponse);
    }
  }
}
