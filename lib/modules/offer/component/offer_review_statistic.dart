import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

import '../../../data/models/review_summary.dart';
import '../../../i18n/i18n.dart';
import '../../../utils/responsiveness/breakpoints.dart';
import '../../../utils/widgets/join.dart';

class OfferReviewStatistic extends StatelessWidget {
  const OfferReviewStatistic({
    required this.reviewSummary,
    Key? key,
  }) : super(key: key);

  final ReviewSummary reviewSummary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: Breakpoint.mobileToLarge,
      child: CustomMultiChildLayout(
        delegate: _TwoXTwoLayoutDelegate(),
        children: [
          LayoutId(
            id: _LayoutId.averageRating,
            child: Text(
              reviewSummary.averageRating!.toStringAsFixed(1),
              style: Theme.of(context).textTheme.headline2!.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -5,
                  ),
            ),
          ),
          LayoutId(
            id: _LayoutId.ratingBreakdown,
            child: _buildRatingBreakdown(context),
          ),
          LayoutId(
            id: _LayoutId.outOf5,
            child: Text(
              S.of(context).outOf5,
              style: Theme.of(context).textTheme.caption!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFCCCCCC),
                  ),
            ),
          ),
          LayoutId(
            id: _LayoutId.ratingCount,
            child: Text(
              '${NumberFormat.compact().format(reviewSummary.totalCount!)} '
              '${S.of(context).ratings(reviewSummary.totalCount!)}',
              style: Theme.of(context).textTheme.caption,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBreakdown(BuildContext context) {
    final ratingBars = [
      for (var i = 5; i >= 1; i--)
        _buildRatingBar(
          context,
          rating: i,
          count: reviewSummary.countForRating(i)!,
        ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: joinWidgets(
        ratingBars,
        separator: const SizedBox(height: 2),
      ),
    );
  }

  Widget _buildRatingBar(
    BuildContext context, {
    required int rating,
    required int count,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Align(
            alignment: Alignment.centerRight,
            child: RatingBarIndicator(
              rating: rating.toDouble(),
              itemCount: rating,
              itemSize: 8,
              itemBuilder: (_, __) =>
                  const Icon(Icons.star, color: Colors.amber),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _buildFilledBar(
            context,
            fillPercentage: count / reviewSummary.totalCount!,
          ),
        ),
      ],
    );
  }

  Widget _buildFilledBar(
    BuildContext context, {
    required double fillPercentage,
  }) {
    final foregroundColor = Theme.of(context).brightness == Brightness.light
        ? const Color(0xFFCCCCCC)
        : const Color(0xFF414C58);
    final backgroundColor = Theme.of(context).brightness == Brightness.light
        ? const Color(0xFFF4F4F4)
        : Color.alphaBlend(
            ElevationOverlay.overlayColor(context, 4),
            Theme.of(context).colorScheme.surface,
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: backgroundColor,
              ),
            ),
            Container(
              height: 8,
              width: constraints.maxWidth * fillPercentage,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: foregroundColor,
              ),
            ),
          ],
        );
      },
    );
  }
}

enum _LayoutId {
  averageRating,
  ratingBreakdown,
  outOf5,
  ratingCount,
}

class _TwoXTwoLayoutDelegate extends MultiChildLayoutDelegate {
  static const padding = 16;

  @override
  void performLayout(Size maximumSize) {
    // Position it in the top left corner.
    final averageRatingSize = _positionAverageRating(maximumSize);
    // Center it vertically to the right of the average rating.
    final ratingBreakdownSize = _positionRatingBreakdown(
      maximumSize,
      averageRatingSize,
    );
    // Center it horizontally below the average rating.
    _positionOutOf5(maximumSize, averageRatingSize);
    // Position it in the bottom right corner.
    _positionRatingCount(maximumSize, averageRatingSize, ratingBreakdownSize);
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => false;

  Size _positionAverageRating(Size maximumSize) {
    return layoutChild(
      _LayoutId.averageRating,
      BoxConstraints.loose(maximumSize),
    );
  }

  Size _positionRatingBreakdown(Size maximumSize, Size firstChildSize) {
    final secondChildSize = layoutChild(
      _LayoutId.ratingBreakdown,
      BoxConstraints.loose(Size(
        // The second child should be as maximum as large as the
        // entire width - the width of the first child.
        maximumSize.width - firstChildSize.width - padding,
        maximumSize.height,
      )),
    );
    positionChild(
      _LayoutId.ratingBreakdown,
      Offset(
        firstChildSize.width + padding,
        firstChildSize.height / 2 - secondChildSize.height / 2,
      ),
    );

    return secondChildSize;
  }

  Size _positionOutOf5(Size maximumSize, Size averageRatingSize) {
    final outOf5Size = layoutChild(
      _LayoutId.outOf5,
      BoxConstraints.loose(maximumSize),
    );
    positionChild(
      _LayoutId.outOf5,
      Offset(
        averageRatingSize.width / 2 - outOf5Size.width / 2,
        averageRatingSize.height,
      ),
    );

    return outOf5Size;
  }

  void _positionRatingCount(
    Size maximumSize,
    Size averageRatingSize,
    Size ratingBreakdownSize,
  ) {
    final fourthChildSize = layoutChild(
      _LayoutId.ratingCount,
      BoxConstraints.loose(maximumSize),
    );
    positionChild(
      _LayoutId.ratingCount,
      Offset(
        averageRatingSize.width +
            padding +
            ratingBreakdownSize.width -
            fourthChildSize.width,
        averageRatingSize.height,
      ),
    );
  }
}
