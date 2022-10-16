import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/analyze_csv_file.dart';
import '../../../../utils/config.dart';
import '../../../../utils/email.dart';
import '../../../../utils/select_csv_file.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import '../../../../widgets/import/import_state.dart';
import '../../../import_csv/data/csv_deck.dart';
import 'import_google_sheets_component.dart';
import 'import_google_sheets_view_model.dart';

/// BLoC for the [ImportGoogleSheetsComponent].
@injectable
class ImportGoogleSheetsBloc
    with ComponentBuildContext, ComponentLifecycleListener {
  Stream<ImportGoogleSheetsViewModel>? _viewModel;
  Stream<ImportGoogleSheetsViewModel>? get viewModel => _viewModel;

  final _filePath = BehaviorSubject<String?>.seeded(null);
  final _deck = BehaviorSubject<CSVDeck?>.seeded(null);
  final _importState =
      BehaviorSubject<ImportState>.seeded(ImportState.showInstructions);

  Stream<ImportGoogleSheetsViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest3(
      _importState,
      _filePath,
      _deck,
      _createViewModel,
    );
  }

  ImportGoogleSheetsViewModel _createViewModel(
    ImportState importState,
    String? filePath,
    CSVDeck? deck,
  ) {
    return ImportGoogleSheetsViewModel(
      importState: importState,
      importDeck: deck,
      filePath: filePath,
      onSelectFileTap: _handleSelectFileTap,
      analyzeFile: _analyzeFile,
      importOverviewCallback: () => _importState.add(ImportState.showProgress),
      importCallback: () => _importState.add(ImportState.importFinished),
      onOpenEmailAppTap: _handleOpenEmailAppTap,
    );
  }

  @override
  void dispose() {
    _filePath.close();
    _deck.close();
    _importState.close();
    super.dispose();
  }

  Future<void> _handleSelectFileTap() async {
    final filePath = await selectCSVFile(context);
    if (filePath == null) {
      return;
    }

    _importState.add(ImportState.analyzeFile);
    _filePath.add(filePath);
  }

  Future<void> _analyzeFile(
    void Function(String, [AsyncCallback]) errorCallback,
  ) async {
    final deck = await catchCSVExceptions(
      () => analyzeCSVFile(_filePath.value!, context),
      context,
      errorCallback,
      _handleOpenEmailAppTap,
    );
    if (deck == null) {
      return;
    }

    _importState.add(ImportState.showDataOverview);
    _deck.add(deck);
  }

  Future<void> _handleOpenEmailAppTap() async {
    try {
      await openEmailAppWithTemplate(
        email: supportEmail,
        subject: 'Problems importing an CSV file',
        body: 'Hey TubeCards Team,\n\n'
            "I'm having trouble analyzing my CSV file. "
            'I have attached the CSV file.\n\n'
            'Best regards',
      );
    } on Exception {
      ScaffoldMessenger.of(context).showErrorSnackBar(
        theme: Theme.of(context),
        text: S.of(context).errorSendEmailToSupportText(supportEmail),
      );
    }
  }
}
