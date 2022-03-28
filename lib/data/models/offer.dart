import 'package:built_collection/built_collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

import 'base_model.dart';
import 'card.dart';
import 'connection.dart';
import 'deck.dart';
import 'offer_review.dart';
import 'review_summary.dart';
import 'user.dart';

part 'offer.g.dart';

@JsonSerializable()
@CopyWith()
class Offer extends BaseModel {
  /// Constructs a new [Offer] instance from the given parameters.
  const Offer({
    String? id,
    this.subscriberCount,
    this.hasViewerBought,
    this.viewerReview,
    this.reviewSummary,
    this.reviewConnection,
    this.cardSamples,
    this.deck,
    this.creator,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Constructs a new [Offer] from the given [json].
  ///
  /// A conversion from JSON is especially useful in order to handle results
  /// from a server request.
  factory Offer.fromJson(Map<String, dynamic> json) => _$OfferFromJson(json);

  /// The number of subscriber this offer has.
  final int? subscriberCount;

  final bool? hasViewerBought;

  final OfferReview? viewerReview;

  /// The review summary of the offer.
  final ReviewSummary? reviewSummary;

  /// The reviews of the offer.
  final Connection<OfferReview>? reviewConnection;

  /// The card samples of the offer.
  final BuiltList<Card>? cardSamples;

  /// The deck to which this offer refers.
  final Deck? deck;

  /// The creator of the offer.
  final User? creator;

  /// Constructs a new json map from this [Offer].
  ///
  /// A conversion to JSON is useful in order to send data to a server.
  Map<String, dynamic> toJson() => _$OfferToJson(this);

  @override
  List<Object?> get props => super.props
    ..addAll([
      subscriberCount,
      hasViewerBought,
      viewerReview,
      reviewSummary,
      reviewConnection,
      cardSamples,
      deck,
      creator,
    ]);
}
