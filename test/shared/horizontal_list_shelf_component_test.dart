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
import 'package:tubecards/modules/shared/horizontal_list_shelf_component.dart';

import '../helpers/test_cache_manager.dart';
import '../helpers/theme_wrapper.dart';

Widget _buildChild(String name) => OfferItemComponent(
      onTap: () => {},
      offer: Offer(
        deck: Deck(name: name, coverImage: defaultCoverImage),
        reviewSummary: const ReviewSummary(averageRating: 0, totalCount: 0),
      ),
    );

List<Widget> _buildChildren() {
  return List<int>.generate(10, (i) => i + 1)
      .map((e) => _buildChild('Offer $e'))
      .toList();
}

void main() {
  // Don't use a constant, otherwise the tests cannot be started individually.
  group('HorizontalListShelfComponent', () {
    setUpAll(() {
      GetIt.I.registerSingleton<BaseCacheManager>(TestCacheManager());
    });
    testGoldens(
      'One Item',
      (tester) async {
        final component = HorizontalListShelfComponent(
          title: 'One Item',
          children: [_buildChild('Offer 1')],
        );

        await tester.pumpWidgetBuilder(
          component,
          wrapper: lightThemeWrapper,
        );

        await screenMatchesGolden(
          tester,
          'HorizontalListShelfComponent_Default',
          // Use custom pump to prevent waiting for endless animation
          customPump: (_) => tester.pump(),
        );
      },
    );
    testGoldens(
      'Overflowing',
      (tester) async {
        final component = HorizontalListShelfComponent(
          title: 'Overflowing',
          children: _buildChildren(),
        );

        await tester.pumpWidgetBuilder(
          component,
          wrapper: lightThemeWrapper,
        );

        await screenMatchesGolden(
          tester,
          'HorizontalListShelfComponent_Overflowing',
          // Use custom pump to prevent waiting for endless animation
          customPump: (_) => tester.pump(),
        );
      },
    );
    testGoldens(
      'Action Button',
      (tester) async {
        final component = HorizontalListShelfComponent(
          title: 'Action Button',
          button: TextButton(
            onPressed: () => {},
            child: const Text('SEE ALL'),
          ),
          children: _buildChildren(),
        );

        await tester.pumpWidgetBuilder(
          component,
          wrapper: lightThemeWrapper,
        );

        await screenMatchesGolden(
          tester,
          'HorizontalListShelfComponent_ActionButton',
          // Use custom pump to prevent waiting for endless animation
          customPump: (_) => tester.pump(),
        );
      },
    );
  });
}
