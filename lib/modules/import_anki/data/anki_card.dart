import 'package:json_annotation/json_annotation.dart';

part 'anki_card.g.dart';

@JsonSerializable()
class AnkiCard {
  AnkiCard({
    required this.deckId,
    required this.front,
    required this.back,
  });

  /// Constructs a new [AnkiDeck] from the given [json].
  ///
  /// A conversion from JSON is especially useful in order to handle results
  /// from an import.
  factory AnkiCard.fromJson(Map<String, dynamic> json) {
    return _$AnkiCardFromJson(json);
  }

  /// Deck id from Anki.
  final int deckId;

  /// Front HTML content of the card
  ///
  /// Converting HTML to Markdown consumes a lot of time, so it happens
  /// during upload first.
  final String front;

  /// Back HTML content of the card.
  ///
  /// Converting HTML to Markdown consumes a lot of time, so it happens
  /// during upload first.
  final String back;

  /// Constructs a new json map from this [AnkiCard].
  ///
  /// A conversion to JSON is useful in order to send through an isolate.
  Map<String, dynamic> toJson() => _$AnkiCardToJson(this);
}
