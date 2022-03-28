import 'package:flutter/foundation.dart';

class ImportExportViewModel {
  const ImportExportViewModel({
    required this.onImportAnkiTap,
    required this.onImportCSVTap,
    required this.onImportGoogleSheetsTap,
    required this.onImportExcelTap,
    required this.onExportCSVTap,
  });

  final VoidCallback onImportAnkiTap;
  final VoidCallback onImportCSVTap;
  final VoidCallback onImportGoogleSheetsTap;
  final VoidCallback onImportExcelTap;
  final VoidCallback onExportCSVTap;
}
