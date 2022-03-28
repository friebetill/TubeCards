import 'package:clock/clock.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../utils/sm2.dart' as sm2;
import 'average_learning_state.dart';
import 'base_model.dart';
import 'card.dart';

part 'learning_state.g.dart';

/// Represents the current learning state for a specific card.
@JsonSerializable()
class LearningState extends BaseModel {
  /// Constructs a new [LearningState] instance with the given parameters.
  const LearningState({
    String? id,
    this.card,
    this.nextDueDate,
    this.streakKnown,
    this.ease,
    this.strength,
    this.stability,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  /// Constructs a new [LearningState] with initial values for [sm2].
  LearningState.initial({this.card})
      : nextDueDate = clock.now(),
        streakKnown = sm2.initialStreakKnown,
        ease = sm2.initialEase,
        strength = 0,
        stability = Duration.zero;

  /// Constructs a new [LearningState] from the given [json].
  ///
  /// A conversion from JSON is especially useful in order to handle results
  /// from a server request.
  factory LearningState.fromJson(Map<String, dynamic> json) =>
      _$LearningStateFromJson(json);

  // The card this learning state refers to.
  final Card? card;

  /// The time where the next repetition is scheduled to occur.
  final DateTime? nextDueDate;

  /// Current streak of repetitions where the user labelled the card as known.
  final int? streakKnown;

  /// Indicates the ease with which the user remembers the corresponding card.
  final double? ease;

  /// Indicates the strength of the user's memory of the corresponding card.
  final double? strength;

  /// Indicates the stability of the user's memory of the corresponding card.
  @JsonKey(fromJson: stabilityFromJson)
  final Duration? stability;

  /// Constructs a new json map from this [LearningState].
  ///
  /// A conversion to JSON is useful in order to send data to a server.
  Map<String, dynamic> toJson() => _$LearningStateToJson(this);

  @override
  List<Object?> get props => super.props
    ..add([
      card,
      nextDueDate,
      streakKnown,
      ease,
    ]);
}
