import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:tubecards/data/models/review_summary.dart';
import 'package:tubecards/modules/offer/component/offer_review_statistic.dart';

import '../helpers/theme_wrapper.dart';

void main() {
  group('OfferReviewStatistic', () {
    testGoldens(
      'Default',
      (tester) async {
        final component = OfferReviewStatistic(
          reviewSummary: _genericReviewSummary(),
        );

        await tester.pumpWidgetBuilder(
          component,
          wrapper: lightThemeWrapper,
          surfaceSize: _surfaceSize,
        );

        await screenMatchesGolden(
          tester,
          'OfferReviewStatistic_Default',
        );
      },
    );
    testGoldens(
      'AbbreviatedRatingNumber',
      (tester) async {
        final component = OfferReviewStatistic(
          reviewSummary: _genericReviewSummary(totalCount: 1000),
        );

        await tester.pumpWidgetBuilder(
          component,
          wrapper: lightThemeWrapper,
          surfaceSize: _surfaceSize,
        );

        await screenMatchesGolden(
          tester,
          'OfferReviewStatistic_AbbreviatedRatingNumber',
        );
      },
    );
  });
}

const _surfaceSize = Size(300, 80);

ReviewSummary _genericReviewSummary({int totalCount = 100}) {
  return ReviewSummary(
    averageRating: 4.7,
    oneStarRatingCount: (totalCount * 0.1).round(),
    twoStarRatingCount: (totalCount * 0.05).round(),
    threeStarRatingCount: (totalCount * 0.05).round(),
    fourStarRatingCount: (totalCount * 0.1).round(),
    fiveStarRatingCount: (totalCount * 0.7).round(),
    totalCount: totalCount,
  );
}
