import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' hide context;
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/config.dart';
import '../../../../utils/email.dart';
import '../../../../utils/snackbar.dart';
import '../../../../utils/user_exception.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import '../../../../widgets/import/import_state.dart';
import '../../data/anki_package.dart';
import '../../utils/apkg_extractor.dart';
import 'import_anki_component.dart';
import 'import_anki_view_model.dart';

/// BLoC for the [ImportAnkiComponent].
@injectable
class ImportAnkiBloc with ComponentBuildContext, ComponentLifecycleListener {
  Stream<ImportAnkiViewModel>? _viewModel;
  Stream<ImportAnkiViewModel>? get viewModel => _viewModel;

  final _filePath = BehaviorSubject<String?>.seeded(null);
  final _ankiPackage = BehaviorSubject<AnkiPackage?>.seeded(null);
  final _importState =
      BehaviorSubject<ImportState>.seeded(ImportState.showInstructions);

  final _logger = Logger((ImportAnkiBloc).toString());

  Stream<ImportAnkiViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest3(
      _importState,
      _filePath,
      _ankiPackage,
      _createViewModel,
    );
  }

  ImportAnkiViewModel _createViewModel(
    ImportState importState,
    String? filePath,
    AnkiPackage? package,
  ) {
    return ImportAnkiViewModel(
      importState: importState,
      ankiPackage: package,
      filePath: filePath,
      onSelectFile: _showSelectFileDialog,
      analyzeFile: _analyzeFile,
      importOverviewCallback: (package) {
        _importState.add(ImportState.showProgress);
        _ankiPackage.add(package);
      },
      importCallback: () => _importState.add(ImportState.importFinished),
      onOpenEmailAppTap: _handleOpenEmailAppTap,
    );
  }

  @override
  void dispose() {
    _filePath.close();
    _ankiPackage.close();
    _importState.close();
    super.dispose();
  }

  Future<void> _showSelectFileDialog() async {
    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    String? filePath;
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: S.of(context).pickAnAPKGFile,
    );

    if (result == null) {
      return;
    } else if (result.files.length > 1) {
      // We allow only one file to be selected. If the result consists of
      // several files, it means that the file contains special characters, e.g.
      // commas. Unfortunately, the file name cannot be reassembled
      // automatically, so we have to show an error message to the user.
      return messenger.showErrorSnackBar(
        theme: theme,
        text: i18n.errorFileSpecialCharactersText,
      );
    } else if (extension(result.files.first.path!) == '.apkg') {
      filePath = result.files.first.path;
    } else {
      return messenger.showErrorSnackBar(
        theme: theme,
        text: i18n.errorSelectExtensionText('.apkg'),
      );
    }

    _importState.add(ImportState.analyzeFile);
    _filePath.add(filePath);
  }

  Future<void> _analyzeFile(
    void Function(String, [AsyncCallback]) errorCallback,
  ) async {
    await _catchAnkiExceptions(
      _analyzeAnkiFile,
      context,
      errorCallback,
    );
  }

  Future<void> _analyzeAnkiFile() async {
    final extractionPath = Directory.systemTemp.path;
    await compute(extractZipFile, {
      'filePath': _filePath.value!,
      'extractionPath': extractionPath,
    });

    final anki2DatabasePath = '$extractionPath/collection.anki2';
    final anki2_1DatabasePath = '$extractionPath/collection.anki21';

    final databasePath = File(anki2_1DatabasePath).existsSync()
        ? anki2_1DatabasePath
        : anki2DatabasePath;

    // Use sqflite on Android as recommended, https://bit.ly/3zt24Wg
    final ankiDatabase = await (Platform.isAndroid
        ? openDatabase(databasePath)
        : databaseFactoryFfi.openDatabase(databasePath));
    final decks = (await extractAnkiDecks(ankiDatabase))
      // Remove empty decks, as they have little benefits for the user
      // and there is almost always an empty default deck.
      ..removeWhere((d) => d.cards.isEmpty);

    final mediaFileContent = File('$extractionPath/media').readAsStringSync();
    final jsonMedia = jsonDecode(mediaFileContent) as Map<String, dynamic>;

    _importState.add(ImportState.showDataOverview);
    _ankiPackage.add(AnkiPackage(
      decks: decks,
      jsonMedia: jsonMedia,
      extractionPath: extractionPath,
    ));
  }

  Future<void> _catchAnkiExceptions(
    AsyncValueGetter<void> analyzeFile,
    BuildContext context,
    void Function(String, [AsyncCallback]) errorCallback,
  ) async {
    try {
      return await analyzeFile();
    } on UserException catch (e) {
      errorCallback(
        S.of(context).pleaseSendUsAnEmailAtSupport(e.userMessage),
        _handleOpenEmailAppTap,
      );
    } on Exception catch (e, s) {
      errorCallback(
        S.of(context).pleaseSendUsAnEmailAtSupport(supportEmail),
        _handleOpenEmailAppTap,
      );
      _logger.severe('Exception during Anki import', e, s);
      // ignore: avoid_catching_errors
    } on StateError {
      // Swallow state errors that occur when the analysis is aborted.
      // ignore: avoid_catching_errors
    } on Error catch (e, s) {
      // Necessary, because CastErrors can occur during the analysis,
      // since we do not understand the APKG format 100%.
      errorCallback(
        S.of(context).pleaseSendUsAnEmailAtSupport(supportEmail),
        _handleOpenEmailAppTap,
      );
      _logger.severe('Error during Anki import', e, s);
    }
  }

  Future<void> _handleOpenEmailAppTap() async {
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final i18n = S.of(context);

    try {
      await openEmailAppWithTemplate(
        email: supportEmail,
        subject: 'Problems importing an APKG file',
        body: 'Hey TubeCards Team,\n\n'
            "I'm having trouble analyzing my Anki APKG file. "
            'I have attached the APKG file.\n\n'
            'Best regards',
      );
    } on Exception {
      messenger.showErrorSnackBar(
        theme: theme,
        text: i18n.errorSendEmailToSupportText(supportEmail),
      );
    }
  }
}
