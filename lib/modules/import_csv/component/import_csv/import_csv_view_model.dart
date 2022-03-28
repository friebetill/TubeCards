import 'package:flutter/foundation.dart';

import '../../../../widgets/import/analyze_file/analyze_file_view_model.dart';
import '../../../../widgets/import/import_state.dart';
import '../../../import_csv/data/csv_deck.dart';

class ImportCSVViewModel {
  ImportCSVViewModel({
    required this.importState,
    required this.filePath,
    required this.importDeck,
    required this.onSelectFileTap,
    required this.analyzeFile,
    required this.importOverviewCallback,
    required this.importCallback,
    required this.onOpenEmailAppTap,
  });

  final ImportState importState;
  final String? filePath;
  final CSVDeck? importDeck;

  final AsyncCallback onSelectFileTap;
  final AnalyzeFileErrorCallback analyzeFile;
  final VoidCallback importOverviewCallback;
  final VoidCallback importCallback;
  final AsyncCallback onOpenEmailAppTap;
}
