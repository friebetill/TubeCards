import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_summary.g.dart';

@JsonSerializable()
@CopyWith()
class ReviewSummary extends Equatable {
  const ReviewSummary({
    this.averageRating,
    this.totalCount,
    this.oneStarRatingCount,
    this.twoStarRatingCount,
    this.threeStarRatingCount,
    this.fourStarRatingCount,
    this.fiveStarRatingCount,
  });

  /// Constructs a new [ReviewSummary] from the given [json].
  ///
  /// A conversion from JSON is especially useful in order to handle results
  /// from a server request.
  factory ReviewSummary.fromJson(Map<String, dynamic> json) =>
      _$ReviewSummaryFromJson(json);

  /// The average rating.
  final double? averageRating;

  /// The total number of reviews.
  final int? totalCount;

  /// The number of reviews with a rating of 1.
  final int? oneStarRatingCount;

  /// The number of reviews with a rating of 2.
  final int? twoStarRatingCount;

  /// The number of reviews with a rating of 3.
  final int? threeStarRatingCount;

  /// The number of reviews with a rating of 4.
  final int? fourStarRatingCount;

  /// The number of reviews with a rating of 5.
  final int? fiveStarRatingCount;

  /// Constructs a new json map from this [ReviewSummary].
  ///
  /// A conversion to JSON is useful in order to send data to a server.
  Map<String, dynamic> toJson() => _$ReviewSummaryToJson(this);

  int? countForRating(int count) {
    assert(count >= 1 && count <= 5);

    switch (count) {
      case 1:
        return oneStarRatingCount;
      case 2:
        return twoStarRatingCount;
      case 3:
        return threeStarRatingCount;
      case 4:
        return fourStarRatingCount;
      case 5:
        return fiveStarRatingCount;
      default:
        return null;
    }
  }

  @override
  List<Object?> get props => [
        averageRating,
        totalCount,
        oneStarRatingCount,
        twoStarRatingCount,
        threeStarRatingCount,
        fourStarRatingCount,
        fiveStarRatingCount,
      ];
}
