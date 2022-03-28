import 'anki_deck.dart';

class AnkiPackage {
  AnkiPackage({
    required this.decks,
    required this.jsonMedia,
    required this.extractionPath,
  });

  final List<AnkiDeck> decks;
  final Map<String, dynamic> jsonMedia;
  final String extractionPath;
}
