import 'package:flutter/foundation.dart';

import '../../../../widgets/import/analyze_file/analyze_file_view_model.dart';
import '../../../../widgets/import/import_state.dart';
import '../../data/anki_package.dart';

class ImportAnkiViewModel {
  ImportAnkiViewModel({
    required this.importState,
    required this.filePath,
    required this.ankiPackage,
    required this.onSelectFile,
    required this.analyzeFile,
    required this.importOverviewCallback,
    required this.importCallback,
    required this.onOpenEmailAppTap,
  });

  final ImportState importState;
  final String? filePath;
  final AnkiPackage? ankiPackage;

  final AsyncCallback onSelectFile;
  final AnalyzeFileErrorCallback analyzeFile;
  final Function(AnkiPackage) importOverviewCallback;
  final VoidCallback importCallback;
  final AsyncCallback onOpenEmailAppTap;
}
