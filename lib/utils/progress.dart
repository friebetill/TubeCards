import 'package:meta/meta.dart';

/// Represents progress of some continuous operation.
///
/// The progress spans from 0% to 100%. An operation is assumed to be finished
/// once the progress
/// hits 100%.
@immutable
class Progress {
  /// Constructs a new [Progress] instance from the given parameters.
  const Progress(this.value);

  /// Actual progress value of the underlying operation.
  ///
  /// The progress value is in the interval [0, 1] and ranges from 0% to 100%.
  final double value;

  /// Returns whether the underlying operation if done.
  bool isDone() => value == 1;

  /// Converts the progress to percent and returns the value.
  ///
  /// Percentages are in the range [0, 100].
  double toPercent([int fractionDigits = 0]) =>
      double.parse((value * 100).toStringAsFixed(fractionDigits));

  @override
  String toString() => '${toPercent()}%';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Progress &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
