import '../data/anki_deck.dart';
import '../data/anki_note_type.dart';

/// Helper class to clean the text of Ankis cards.
class AnkiTextCleaner {
  /// Replaces the placeholder of Anki fields with the content.
  String replaceFieldsWithContent({
    required String cardText,
    required Map<String, dynamic> cardRow,
    required AnkiNoteType noteType,
    required List<AnkiDeck> decks,
    required bool isFront,
    List<String> ignoreFields = const <String>[],
  }) {
    final deck = decks.singleWhere((d) => d.id == cardRow['did'] as int);
    final fields = (cardRow['flds'] as String).split(String.fromCharCode(31));

    var cleanedCardText = cardText;

    // Remove ignored fields
    for (final field in ignoreFields) {
      cleanedCardText = cleanedCardText.replaceAll('{{$field}}', '');
    }

    // Replace all field names with their contents.
    for (var j = 0; j < noteType.flds.length; j++) {
      cleanedCardText = cleanedCardText.replaceAll(
        '{{${noteType.flds[j]['name'] as String}}}',
        fields[j],
      );
    }

    cleanedCardText = _removeConditionalReplacements(
      cleanedCardText,
      fields,
      noteType,
    );

    if (noteType.isCloze) {
      cleanedCardText =
          _replaceClozeText(cleanedCardText, cardRow, isFront: isFront);
    }

    // There are some special fields that can be included in the template:
    // The note's tags: {{Tags}}
    if (noteType.tags != null) {
      cleanedCardText = cleanedCardText.replaceAll(
        '{{Tags}}',
        List<String>.from(noteType.tags!).join(', '),
      );
    }
    // The type of note: {{Type}}
    cleanedCardText = cleanedCardText.replaceAll('{{Type}}', noteType.name);
    // The card's deck: {{Deck}}
    cleanedCardText = cleanedCardText.replaceAll('{{Deck}}', deck.name);
    // The card's subdeck: {{Subdeck}}
    cleanedCardText =
        cleanedCardText.replaceAll('{{Subdeck}}', deck.name.split('::').last);
    // The type of card ("Forward", etc): {{Card}}
    cleanedCardText = cleanedCardText.replaceAll(
      '{{Card}}',
      noteType.tmpls[0]['name'] as String,
    );

    // Remove unnecessary Anki widgets
    cleanedCardText = cleanedCardText.replaceAll('{{FrontSide}}', '');

    cleanedCardText = cleanedCardText.replaceAll('<hr id=answer>', '');
    cleanedCardText = cleanedCardText.trim();

    return cleanedCardText;
  }

  String _replaceClozeText(
    String text,
    Map<String, dynamic> cardEntry, {
    required bool isFront,
  }) {
    // Find matches of text that look similar to {{c1:text}} and
    // {{c1::text::hint}}, where hint is currently ignored.
    final regExp = RegExp('{{c([0-9]+)::([^}]*?)(?:::[^}]*)?}}');
    final matches = regExp.allMatches(text);

    var updatedText = text;
    for (final match in matches) {
      final clozeNumber = int.parse(match.group(1)!);

      if (isFront && cardEntry['ord'] + 1 == clozeNumber) {
        updatedText = updatedText.replaceAll(match.group(0)!, '_____');
      } else {
        updatedText = updatedText.replaceAll(match.group(0)!, match.group(2)!);
      }
    }

    return updatedText;
  }

  String _removeConditionalReplacements(
    String text,
    List<String> fields,
    AnkiNoteType noteType,
  ) {
    var updatedText = text;

    for (var j = 0; j < noteType.flds.length; j++) {
      if (fields[j] == '') {
        // Remove the conditional replacement if the field is empty.
        final regExp = RegExp('{{#([^}]*)}}.*{{/1}}', dotAll: true);
        final match = regExp.firstMatch(text);

        if (match != null) {
          updatedText = updatedText.replaceAll(match.group(0)!, '');
        }
      } else {
        final fieldName = noteType.flds[j]['name'] as String;
        updatedText = updatedText.replaceAll('{{#$fieldName}}', '');
        updatedText = updatedText.replaceAll('{{/$fieldName}}', '');
      }
    }

    return updatedText;
  }

  /// Remove all audio and video links, as we don't support them yet.
  String removeVideoAudioLinks(String text) {
    var updatedText = text;
    final matches = RegExp(r'\[sound:([^\]]+)\]').allMatches(text);
    for (final match in matches) {
      updatedText = updatedText.replaceAll(match.group(0)!, '');
    }

    return updatedText;
  }
}
