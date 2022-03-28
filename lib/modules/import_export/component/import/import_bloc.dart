import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../utils/custom_navigator.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../export_csv/export_csv_page.dart';
import '../../../import_anki/import_anki_page.dart';
import '../../../import_csv/import_csv_page.dart';
import '../../../import_excel/import_excel_page.dart';
import '../../../import_google_sheets/import_google_sheets_page.dart';
import 'import_component.dart';
import 'import_view_model.dart';

/// BLoC for the [ImportExportComponent].
@injectable
class ImportExportBloc with ComponentBuildContext {
  ImportExportBloc();

  Stream<ImportExportViewModel>? _viewModel;
  Stream<ImportExportViewModel>? get viewModel => _viewModel;

  Stream<ImportExportViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Stream.value(ImportExportViewModel(
      onImportAnkiTap: () =>
          CustomNavigator.getInstance().pushNamed(ImportAnkiPage.routeName),
      onImportCSVTap: () =>
          CustomNavigator.getInstance().pushNamed(ImportCSVPage.routeName),
      onImportExcelTap: () =>
          CustomNavigator.getInstance().pushNamed(ImportExcelPage.routeName),
      onImportGoogleSheetsTap: () => CustomNavigator.getInstance()
          .pushNamed(ImportGoogleSheetsPage.routeName),
      onExportCSVTap: () =>
          CustomNavigator.getInstance().pushNamed(ExportCSVPage.routeName),
    ));
  }
}
