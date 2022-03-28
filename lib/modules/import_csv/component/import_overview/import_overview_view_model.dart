import 'package:flutter/foundation.dart';

import '../../../import_csv/data/csv_deck.dart';

class DataOverviewViewModel {
  DataOverviewViewModel({
    required this.deck,
    required this.onStartImportTap,
  });

  final CSVDeck deck;

  final VoidCallback onStartImportTap;
}
