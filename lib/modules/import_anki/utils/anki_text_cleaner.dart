import '../data/anki_deck.dart';
import '../data/anki_note_type.dart';

/// Helper class to clean the text of Ankis cards.
class AnkiTextCleaner {
  /// Replaces the placeholder of Anki fields with the content.
  String replaceFieldsWithContent({
    required String cardText,
    required Map<String, dynamic> cardEntry,
    required AnkiNoteType noteType,
    required List<AnkiDeck> decks,
    List<String> ignoreFields = const <String>[],
  }) {
    final deck = decks.singleWhere((d) => d.id == cardEntry['did'] as int);
    final fields = (cardEntry['flds'] as String).split(String.fromCharCode(31));

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
