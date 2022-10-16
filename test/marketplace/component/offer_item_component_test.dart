import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:tubecards/data/models/deck.dart';
import 'package:tubecards/data/models/offer.dart';
import 'package:tubecards/data/models/review_summary.dart';
import 'package:tubecards/data/models/unsplash_image.dart';
import 'package:tubecards/modules/marketplace/component/offer_item_component.dart';

import '../../helpers/test_cache_manager.dart';
import '../../helpers/theme_wrapper.dart';

Offer _buildDefaultOffer(String deckName) {
  final deck = Deck(
    name: deckName,
    coverImage: defaultCoverImage,
  );

  return Offer(
    deck: deck,
    reviewSummary: const ReviewSummary(totalCount: 165, averageRating: 3.7),
  );
}

void main() {
  // Don't use a constant, otherwise the tests cannot be started individually.
  group('OfferItemComponent', () {
    setUpAll(() {
      GetIt.I.registerSingleton<BaseCacheManager>(TestCacheManager());
    });
    testGoldens(
      'Default',
      (tester) async {
        final offer = _buildDefaultOffer('Single line');

        final component = Padding(
          padding: const EdgeInsets.all(16),
          child: OfferItemComponent(onTap: () => {}, offer: offer),
        );

        await tester.pumpWidgetBuilder(
          component,
          wrapper: lightThemeWrapper,
          surfaceSize: const Size(200, 200),
        );

        await screenMatchesGolden(
          tester,
          'OfferItemComponent_Default',
          // Use custom pump to prevent waiting for endless animation
          customPump: (_) => tester.pump(),
        );
      },
    );
    testGoldens(
      'Two Lines',
      (tester) async {
        final offer = _buildDefaultOffer('This is a two line title, wow!');

        final component = Padding(
          padding: const EdgeInsets.all(16),
          child: OfferItemComponent(onTap: () => {}, offer: offer),
        );

        await tester.pumpWidgetBuilder(
          component,
          wrapper: lightThemeWrapper,
          surfaceSize: const Size(200, 200),
        );

        await screenMatchesGolden(
          tester,
          'OfferItemComponent_TwoLines',
          // Use custom pump to prevent waiting for endless animation
          customPump: (_) => tester.pump(),
        );
      },
    );
    testGoldens(
      'Title Overflow',
      (tester) async {
        final offer = _buildDefaultOffer(
          'This is a very very very long text that is overflowing.',
        );

        final component = Padding(
          padding: const EdgeInsets.all(16),
          child: OfferItemComponent(onTap: () => {}, offer: offer),
        );

        await tester.pumpWidgetBuilder(
          component,
          wrapper: lightThemeWrapper,
          surfaceSize: const Size(200, 200),
        );

        await screenMatchesGolden(
          tester,
          'OfferItemComponent_TitleOverflow',
          // Use custom pump to prevent waiting for endless animation
          customPump: (_) => tester.pump(),
        );
      },
    );
    testGoldens(
      'No ratings',
      (tester) async {
        final offer = Offer(
          deck: Deck(name: 'Deck name', coverImage: defaultCoverImage),
          reviewSummary: const ReviewSummary(totalCount: 0),
        );

        final component = Padding(
          padding: const EdgeInsets.all(16),
          child: OfferItemComponent(onTap: () => {}, offer: offer),
        );

        await tester.pumpWidgetBuilder(
          component,
          wrapper: lightThemeWrapper,
          surfaceSize: const Size(200, 200),
        );

        await screenMatchesGolden(
          tester,
          'OfferItemComponent_NoRatings',
          // Use custom pump to prevent waiting for endless animation
          customPump: (_) => tester.pump(),
        );
      },
    );
  });
}
