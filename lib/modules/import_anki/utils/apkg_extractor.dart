import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:sqflite/sqflite.dart';

import '../data/anki_card.dart';
import '../data/anki_deck.dart';
import '../data/anki_note_type.dart';
import 'utils/../anki_text_cleaner.dart';

/// Extract the given [zippedFile] to the given [destinationFolder].
Future<void> extractZipFile(Map<String, String> paths) async {
  final filePath = paths['filePath']!;
  final extractionPath = paths['extractionPath']!;

  final zippedFile = File(filePath);
  final bytes = zippedFile.readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);

  // Extract the contents of the Zip archive to disk.
  for (final file in archive) {
    final fileName = file.name;
    // I don't know yet why media is recognized as a folder.
    if (file.isFile || file.name == 'media') {
      final data = file.content as List<int>;
      File('$extractionPath/$fileName')
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    } else {
      await Directory('$extractionPath/$fileName').create(recursive: true);
    }
  }
}

/// Extracts all decks and cards from the given [ankiDatabase].
Future<List<AnkiDeck>> extractAnkiDecks(Database ankiDatabase) async {
  // Query the decks and models (aka. node types) from the database.
  final collectionTable = await ankiDatabase.query(
    'col',
    columns: ['decks', 'models'],
  );

  // Query all needed information about the cards.
  final cardsJoinsNotesTable = await ankiDatabase.rawQuery(
    '''
      SELECT ord, did, mid, flds FROM cards
      INNER JOIN notes ON cards.nid=notes.id
      ''',
  );

  if (collectionTable.isEmpty) {
    throw Exception('Empty collection table');
  }

  // This result has only one row.
  final firstCollectionRow = collectionTable.first;

  final decks = _extractDecks(firstCollectionRow);
  final cards = await _extractCards(
    cardsJoinsNotesTable,
    firstCollectionRow,
    decks,
  );

  return decks.map((d) {
    return d.copyWith(cards: cards.where((c) => c.deckId == d.id).toList());
  }).toList();
}

List<AnkiDeck> _extractDecks(Map<String, Object?> firstCollectionRow) {
  final decksString = firstCollectionRow['decks']! as String;
  final jsonAnkiDecks = json.decode(decksString) as Map<String, dynamic>;

  return jsonAnkiDecks.entries.map((d) {
    return AnkiDeck.fromJson(d.value as Map<String, dynamic>);
  }).toList();
}

Future<List<AnkiCard>> _extractCards(
  List<Map<String, Object?>> cardsJoinsNotesTable,
  Map<String, Object?> firstCollectionRow,
  List<AnkiDeck> decks,
) async {
  final ankiNoteTypes = _extractAnkiNoteTypes(firstCollectionRow);
  final textCleaner = AnkiTextCleaner();

  final cards = <AnkiCard>[];
  for (final cardRow in cardsJoinsNotesTable) {
    final noteType = ankiNoteTypes.singleWhere((n) => n.id == cardRow['mid']);

    String htmlFront;
    String htmlBack;
    if (noteType.isCloze) {
      htmlFront = (noteType.tmpls[0]['qfmt'] as String).replaceFirst(
        '{{cloze:Text}}',
        cardRow['flds']! as String,
      );
      htmlBack = (noteType.tmpls[0]['afmt'] as String).replaceFirst(
        '{{cloze:Text}}',
        cardRow['flds']! as String,
      );
    } else {
      htmlFront = noteType.tmpls[cardRow['ord']! as int]['qfmt'] as String;
      htmlBack = noteType.tmpls[cardRow['ord']! as int]['afmt'] as String;
    }

    htmlFront = textCleaner.replaceFieldsWithContent(
      cardText: htmlFront,
      cardRow: cardRow,
      noteType: noteType,
      decks: decks,
      isFront: true,
    );
    htmlBack = textCleaner.replaceFieldsWithContent(
      cardText: htmlBack,
      cardRow: cardRow,
      noteType: noteType,
      decks: decks,
      isFront: false,
      ignoreFields: ['Front'],
    );

    htmlFront = textCleaner.removeVideoAudioLinks(htmlFront);
    htmlBack = textCleaner.removeVideoAudioLinks(htmlBack);

    cards.add(AnkiCard(
      deckId: cardRow['did']! as int,
      front: htmlFront,
      back: htmlBack,
    ));
  }

  return cards;
}

List<AnkiNoteType> _extractAnkiNoteTypes(
  Map<String, Object?> firstCollectionRow,
) {
  final modelString = firstCollectionRow['models']! as String;
  final jsonAnkiNoteTypes = json.decode(modelString) as Map<String, dynamic>;

  return jsonAnkiNoteTypes.entries.map((d) {
    return AnkiNoteType.fromJson(d.value as Map<String, dynamic>);
  }).toList();
}
