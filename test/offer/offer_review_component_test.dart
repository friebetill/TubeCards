import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:tubecards/data/models/offer_review.dart';
import 'package:tubecards/data/models/user.dart';
import 'package:tubecards/modules/offer/component/offer_review_component.dart';

import '../helpers/theme_wrapper.dart';

void main() {
  group('OfferReviewComponent', () {
    testGoldens(
      'TruncatedReviewerName',
      (tester) async {
        final component = OfferReviewComponent(
          offerReview: _genericOfferReview.copyWith(
            user: User(firstName: 'a' * 100, lastName: 'b'),
          ),
        );

        await withClock(Clock.fixed(DateTime(2022)), () async {
          await tester.pumpWidgetBuilder(
            component,
            wrapper: lightThemeWrapper,
            surfaceSize: _surfaceSize,
          );
        });

        await screenMatchesGolden(
          tester,
          'OfferReviewComponent_TruncatedReviewerName',
        );
      },
    );
    testGoldens(
      'TruncatedReviewDescription',
      (tester) async {
        final component = OfferReviewComponent(
          offerReview: _genericOfferReview.copyWith(description: 'a' * 200),
        );

        await withClock(Clock.fixed(DateTime(2022)), () async {
          await tester.pumpWidgetBuilder(
            component,
            wrapper: lightThemeWrapper,
            surfaceSize: _surfaceSize,
          );
        });

        await screenMatchesGolden(
          tester,
          'OfferReviewComponent_TruncatedReviewDescription',
        );
      },
    );
  });
}

const _surfaceSize = Size(328, 160);

final _genericOfferReview = OfferReview(
  user: const User(firstName: 'Joyce', lastName: 'McCown'),
  createdAt: DateTime(2021),
  rating: 4,
  description: 'I love the level of detail that Joyce put into this '
      'deck. It really helps me learn every small nuance of '
      'human anatomy. I would’ve loved if the deck would '
      'contain more images though.',
);
