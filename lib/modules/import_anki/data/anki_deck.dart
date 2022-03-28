import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

import 'anki_card.dart';

part 'anki_deck.g.dart';

/// The data of an Anki deck.
///
/// For more information see https://bit.ly/3gjlRzP.
@CopyWith()
@JsonSerializable()
class AnkiDeck {
  AnkiDeck({
    required this.name,
    required this.id,
    required this.desc,
    required this.cards,
  });

  /// Constructs a new [AnkiDeck] from the given [json].
  ///
  /// A conversion from JSON is especially useful in order to handle results
  /// from an import.
  factory AnkiDeck.fromJson(Map<String, dynamic> json) {
    return _$AnkiDeckFromJson(json);
  }

  /// Name of deck
  final String name;

  /// Deck ID
  final int id;

  /// Deck description.
  final String desc;

  /// Cards of the deck.
  @JsonKey(defaultValue: [])
  final List<AnkiCard> cards;

  /// Constructs a new json map from this [AnkiDeck].
  ///
  /// A conversion to JSON is useful in order to send through an isolate.
  Map<String, dynamic> toJson() => _$AnkiDeckToJson(this);
}
