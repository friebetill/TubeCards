import 'dart:async';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:csv/csv_settings_autodetection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';

import '../../../../i18n/i18n.dart';
import '../modules/import_csv/data/csv_card.dart';
import '../modules/import_csv/data/csv_deck.dart';
import 'config.dart';
import 'user_exception.dart';

Future<CSVDeck> analyzeCSVFile(String filePath, BuildContext context) async {
  List<List<dynamic>> rows;
  try {
    final csvFile = File(filePath)
        .readAsStringSync()
        // Necessary, because one CSV file can contain different line endings.
        .replaceAll('\r\n', '\n');
    rows = const CsvToListConverter(
      csvSettingsDetector: FirstOccurrenceSettingsDetector(
        fieldDelimiters: [','],
        textDelimiters: ['"'],
        textEndDelimiters: ['"'],
        eols: ['\n'],
      ),
    ).convert(csvFile);
  } on FileSystemException catch (_) {
    throw UserException(S.of(context).openCSVFileError);
  }

  final cards = <CSVCard>[];
  for (var i = 0; i < rows.length; i++) {
    final row = rows[i];
    if (row.length < 2) {
      final lineNumber = i + 1;
      throw UserException(S.of(context).csvLineErrorText(lineNumber));
    }

    cards.add(CSVCard(front: row[0].toString(), back: row[1].toString()));
  }

  final deck = CSVDeck(
    name: basename(filePath).replaceAll('.csv', '').trim(),
    cards: cards,
  );

  return deck;
}

Future<CSVDeck?> catchCSVExceptions(
  AsyncValueGetter<CSVDeck> analyzeFile,
  BuildContext context,
  void Function(String, [AsyncCallback]) errorCallback,
  AsyncCallback handleOpenEmailAppTap,
) async {
  final logger = Logger((catchCSVExceptions).toString());

  try {
    return await analyzeFile();
  } on FormatException catch (e) {
    errorCallback('Unexpected character at the position ${e.offset}.');
  } on UserException catch (e) {
    errorCallback(e.userMessage, handleOpenEmailAppTap);
  } on Exception catch (e, s) {
    errorCallback(
      S.of(context).pleaseSendUsAnEmailAtSupport(supportEmail),
      handleOpenEmailAppTap,
    );
    logger.severe('Exception during CSV import', e, s);
    // ignore: avoid_catching_errors
  } on StateError {
    // Swallow state errors that occur when the analysis is aborted.
    // ignore: avoid_catching_errors
  } on Error catch (e, s) {
    // Necessary, because CastErrors can occur during the analysis,
    // since we do not understand the APKG format 100%.
    errorCallback(
      S.of(context).pleaseSendUsAnEmailAtSupport(supportEmail),
      handleOpenEmailAppTap,
    );
    logger.severe('Error during CSV import', e, s);
  }

  return null;
}
