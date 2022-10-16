import 'package:injectable/injectable.dart';

import '../../services/tubecards/offer_review_service.dart';
import '../models/offer_review.dart';

/// Repository for the [OfferReview] model.
@singleton
class OfferReviewRepository {
  OfferReviewRepository(this._service);

  final OfferReviewService _service;

  Future<void> upsertReview({
    required String offerId,
    required int rating,
    String? description,
  }) {
    return _service.upsert(
      offerId: offerId,
      rating: rating,
      description: description,
    );
  }

  Future<void> delete({required String offerId}) => _service.delete(offerId);
}
