import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

import 'csv_card.dart';

part 'csv_deck.g.dart';

/// The data of an deck that will be imported.
@CopyWith()
@JsonSerializable()
class CSVDeck {
  CSVDeck({
    required this.name,
    required this.cards,
  });

  /// Constructs a new [CSVDeck] from the given [json].
  ///
  /// A conversion from JSON is especially useful in order to handle results
  /// from an import.
  factory CSVDeck.fromJson(Map<String, dynamic> json) {
    return _$CSVDeckFromJson(json);
  }

  /// Name of deck
  final String name;

  /// Cards of the deck.
  @JsonKey(defaultValue: [])
  final List<CSVCard> cards;

  /// Constructs a new json map from this [CSVDeck].
  ///
  /// A conversion to JSON is useful in order to send through an isolate.
  Map<String, dynamic> toJson() => _$CSVDeckToJson(this);
}
