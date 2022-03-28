import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

import 'base_model.dart';
import 'deck.dart';
import 'learning_state.dart';

part 'card.g.dart';

/// Represents a card that consists of a front and back side.
///
/// The front side is usually used to show a question whereas the back side
/// shows the respective answer.
@JsonSerializable()
@CopyWith()
class Card extends BaseModel {
  /// Constructs a new [Card] with the given parameters.
  const Card({
    String? id,
    this.deck,
    this.front,
    this.back,
    this.learningState,
    List<LearningState>? learningStates,
    this.mirrorCard,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : learningStates = learningStates ?? const <LearningState>[],
        super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  /// Constructs a new [Card] from the given [json].
  ///
  /// A conversion from JSON is especially useful in order to handle results
  /// from a server request.
  factory Card.fromJson(Map<String, dynamic> json) => _$CardFromJson(json);

  /// The [Deck] this card is a part of.
  final Deck? deck;

  /// Front content of the card.
  final String? front;

  /// Back content of the card.
  final String? back;

  /// All learning states of this card.
  ///
  /// The learning states are sorted in ascending order by their [createdAt]
  /// timestamp. It is guaranteed that this value cannot be null.
  final List<LearningState> learningStates;

  /// Latest learning state of this card.
  final LearningState? learningState;

  /// Duplicate of this card with reversed sides.
  ///
  /// This card is a shallow copy. If the mirror card exist, only the
  /// [id] is set.
  final Card? mirrorCard;

  /// Latest learning state of this card.
  LearningState get latestLearningState => learningState ?? learningStates.last;

  /// Constructs a new json map from this [Card].
  ///
  /// A conversion to JSON is useful in order to send data to a server.
  Map<String, dynamic> toJson() => _$CardToJson(this);

  @override
  List<Object?> get props => super.props
    ..addAll([
      deck,
      front,
      back,
      learningState,
      learningStates,
      mirrorCard,
    ]);

  /// Returns whether this card is due and should be learned by the user.
  ///
  /// The given [bufferDuration] serves as a time buffer to account for time
  /// differences between client and server. It will recognize a card as due
  /// if the nextDueDate timestamp is within the [bufferDuration] from now.
  bool isDue([Duration bufferDuration = const Duration(seconds: 30)]) {
    return latestLearningState.nextDueDate!
        .isBefore(DateTime.now().add(bufferDuration));
  }
}
