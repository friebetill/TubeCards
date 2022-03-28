import 'package:json_annotation/json_annotation.dart';

part 'csv_card.g.dart';

@JsonSerializable()
class CSVCard {
  CSVCard({required this.front, required this.back});

  /// Constructs a new [CSVCard] from the given [json].
  ///
  /// A conversion from JSON is especially useful in order to handle results
  /// from an import.
  factory CSVCard.fromJson(Map<String, dynamic> json) {
    return _$CSVCardFromJson(json);
  }

  /// Front content of the card
  final String front;

  /// Back content of the card.
  final String back;

  /// Constructs a new json map from this [CSVCard].
  ///
  /// A conversion to JSON is useful in order to send through an isolate.
  Map<String, dynamic> toJson() => _$CSVCardToJson(this);
}
