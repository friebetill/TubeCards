import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'average_learning_state.g.dart';

/// Represents the average learning state of an entity.
@JsonSerializable()
class AverageLearningState extends Equatable {
  const AverageLearningState({this.strength, this.stability});

  /// Constructs a new [AverageLearningState] from the given [json].
  ///
  /// A conversion from JSON is useful to handle results from a server request.
  factory AverageLearningState.fromJson(Map<String, dynamic> json) =>
      _$AverageLearningStateFromJson(json);

  /// The average learning strength of the entity.
  ///
  /// Ranges from 0.0 to 1.0.
  final double? strength;

  /// The average learning stability of the entity.
  @JsonKey(fromJson: stabilityFromJson)
  final Duration? stability;

  /// Constructs a new json map from this [AverageLearningState].
  ///
  /// A conversion to JSON is useful in order to send data to a server.
  Map<String, dynamic> toJson() => _$AverageLearningStateToJson(this);

  @override
  List<Object?> get props => [strength, stability];
}

Duration stabilityFromJson(double stability) {
  return Duration(hours: stability.round());
}
