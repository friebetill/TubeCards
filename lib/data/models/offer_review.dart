import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'base_model.dart';
import 'offer.dart';
import 'user.dart';

part 'offer_review.g.dart';

/// The review by a user about a deck offer.
@JsonSerializable()
@CopyWith()
class OfferReview with EquatableMixin implements Datable {
  /// Constructs a new [OfferReview] instance from the given parameters.
  const OfferReview({
    this.rating,
    this.description,
    this.user,
    this.offer,
    this.createdAt,
    this.updatedAt,
  });

  /// Constructs a new [OfferReview] from the given [json].
  ///
  /// A conversion from JSON is especially useful in order to handle results
  /// from a server request.
  factory OfferReview.fromJson(Map<String, dynamic> json) =>
      _$OfferReviewFromJson(json);

  /// The user rating of the offer from 1 to 5.
  final int? rating;

  /// The description of the review.
  final String? description;

  /// The user who wrote the review.
  final User? user;

  /// The offer that was reviewed.
  final Offer? offer;

  @override
  final DateTime? createdAt;

  @override
  final DateTime? updatedAt;

  /// Constructs a new json map from this [Offer].
  ///
  /// A conversion to JSON is useful in order to send data to a server.
  Map<String, dynamic> toJson() => _$OfferReviewToJson(this);

  @override
  List<Object?> get props => [
        rating,
        description,
        user,
        offer,
        createdAt,
        updatedAt,
      ];
}
