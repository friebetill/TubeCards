import 'package:json_annotation/json_annotation.dart';

part 'anki_note_type.g.dart';

/// The note type of an Anki deck.
///
/// The node type specifies how flashcards of a type are structured.
/// For more information see https://bit.ly/3gjlRzP.
@JsonSerializable()
class AnkiNoteType {
  AnkiNoteType({
    required this.flds,
    required this.id,
    required this.name,
    required this.tags,
    required this.tmpls,
    required this.isCloze,
  });

  /// Constructs a new [AnkiNoteType] from the given [json].
  ///
  /// A conversion from JSON is especially useful in order to handle results
  /// from an import.
  factory AnkiNoteType.fromJson(Map<String, dynamic> json) {
    if (json['id'] is String) {
      // For some decks the ID is a string for an unknown reason.
      json['id'] = int.parse(json['id'] as String);
    }

    return _$AnkiNoteTypeFromJson(json);
  }

  /// JSONArray containing object for each field in the model
  final List flds;

  /// Model ID, matches cards.mid
  final int id;

  /// Model name
  final String name;

  /// Anki saves the tags of the last added note to the current model
  final List? tags;

  /// JSONArray containing object of CardTemplate for each card in model
  final List<dynamic> tmpls;

  // Whether the note type is a cloze-type note type or not.
  @JsonKey(name: 'type', fromJson: isClozeFromType)
  final bool isCloze;
}

bool isClozeFromType(int type) => type == 1;
