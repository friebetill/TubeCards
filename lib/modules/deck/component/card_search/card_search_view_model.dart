import 'package:flutter/foundation.dart';

import '../../../../data/models/card.dart';
import '../../../../data/models/connection.dart';

class CardSearchViewModel {
  CardSearchViewModel({
    required this.cardConnection,
    required this.recentSearchTerms,
    required this.addSearchTerm,
    required this.fetchMoreCards,
  });

  final Connection<Card>? cardConnection;
  final List<String> recentSearchTerms;

  final ValueChanged<String> addSearchTerm;
  final VoidCallback fetchMoreCards;
}
