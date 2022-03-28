import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';

import '../../../data/models/deck.dart';
import '../../../utils/spacing.dart';
import '../util/bottom_navigation_bar_height.dart';
import 'deck_tile/deck_tile_component.dart';

/// The grid showing the decks of the user.
class DeckTileGrid extends StatelessWidget {
  const DeckTileGrid({
    required this.decks,
    required this.showLoadingIndicator,
    Key? key,
  }) : super(key: key);

  final BuiltList<Deck> decks;
  final bool showLoadingIndicator;

  @override
  Widget build(BuildContext context) {
    const floatingActionButtonHeight = 56.0;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.05,
      ),
      padding: EdgeInsets.fromLTRB(
        spacing16Pixels,
        2,
        spacing16Pixels,
        // Account for bottom nav bar height and overlapping FAB
        spacing16Pixels +
            getBottomNavigationBarHeight(context) +
            floatingActionButtonHeight / 2.0,
      ),
      itemCount: decks.length + (showLoadingIndicator ? 1 : 0),
      itemBuilder: _buildDeckItem,
    );
  }

  Widget _buildDeckItem(BuildContext context, int index) {
    if (index < decks.length) {
      return DeckTileComponent(
        decks[index],
        key: ValueKey('deck-item-${decks[index].id}'),
      );
    }

    return const SizedBox(
      height: 150,
      width: 200,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
