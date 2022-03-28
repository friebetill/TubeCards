import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../data/models/offer_review.dart';
import '../../../utils/formatted_duration.dart';

class OfferReviewComponent extends StatelessWidget {
  const OfferReviewComponent({
    required this.offerReview,
    Key? key,
  }) : super(key: key);

  final OfferReview offerReview;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).brightness == Brightness.light
        ? const Color(0xFFF4F4F4)
        : Color.alphaBlend(
            ElevationOverlay.overlayColor(context, 4),
            Theme.of(context).colorScheme.surface,
          );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      margin: EdgeInsets.zero,
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildReviewerAvatar(context),
                const SizedBox(width: 4),
                Expanded(child: _buildReviewerName(context)),
                const SizedBox(width: 16),
                _buildReviewDate(context),
              ],
            ),
            const SizedBox(height: 4),
            _buildRatingBar(),
            const SizedBox(height: 4),
            _buildDescription(context),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewerAvatar(BuildContext context) {
    return CircleAvatar(
      radius: 12,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      child: Text(
        offerReview.user!.firstName!.toUpperCase()[0],
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildReviewerName(BuildContext context) {
    return Text(
      '${offerReview.user!.firstName!} '
      '${offerReview.user!.lastName!}',
      overflow: TextOverflow.fade,
      softWrap: false,
      maxLines: 1,
      style: Theme.of(context)
          .textTheme
          .caption!
          .copyWith(color: Theme.of(context).textTheme.bodyText1!.color),
    );
  }

  Widget _buildReviewDate(BuildContext context) {
    return Text(
      clock
          .now()
          .difference(offerReview.createdAt!)
          .countWithUnitAndAgo(context),
      style: Theme.of(context).textTheme.caption,
    );
  }

  Widget _buildRatingBar() {
    return RatingBarIndicator(
      rating: offerReview.rating!.toDouble(),
      itemSize: 14,
      itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      offerReview.description!,
      maxLines: 6,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context)
          .textTheme
          .caption!
          .copyWith(color: Theme.of(context).textTheme.bodyText1!.color),
    );
  }
}
