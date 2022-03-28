import 'package:flutter/material.dart';

import '../../../data/models/connection.dart';
import '../../../data/models/offer_review.dart';
import '../../../data/models/review_summary.dart';
import '../../../i18n/i18n.dart';
import '../../../widgets/snap_list.dart';
import 'offer_review_component.dart';
import 'offer_review_statistic.dart';

class ReviewOverviewComponent extends StatelessWidget {
  const ReviewOverviewComponent({
    required this.reviewSummary,
    required this.reviewConnection,
    Key? key,
  }) : super(key: key);

  final ReviewSummary reviewSummary;
  final Connection<OfferReview> reviewConnection;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewsTitle(context),
        OfferReviewStatistic(reviewSummary: reviewSummary),
        if (reviewConnection.totalCount! > 0) const SizedBox(height: 12),
        if (reviewConnection.totalCount! > 0) _buildTextReviews(context),
      ],
    );
  }

  Widget _buildReviewsTitle(BuildContext context) {
    return Text(
      S.of(context).reviews,
      style: Theme.of(context)
          .textTheme
          .headline5!
          .copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextReviews(BuildContext context) {
    return SizedBox(
      height: 162,
      child: SnapList(
        // If the item is wider than 345 pixels, the next item will be
        // hidden on 360 pixel screens.
        itemWidth: 359 - 16 /* Padding */,
        paddingWidth: 16,
        itemCount: reviewConnection.nodes!.length,
        itemBuilder: (_, i) {
          return OfferReviewComponent(offerReview: reviewConnection.nodes![i]);
        },
      ),
    );
  }
}
