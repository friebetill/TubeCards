import 'package:flutter/material.dart';

/// A horizontal scrollable widget with a snap effect.
///
/// When the user is done scrolling, it automatically snaps to the next item.
class SnapList extends StatelessWidget {
  const SnapList({
    required this.itemWidth,
    required this.paddingWidth,
    required this.itemCount,
    required this.itemBuilder,
    Key? key,
  }) : super(key: key);

  /// The width of an item.
  ///
  /// The width should not be greater than 360 pixels - [paddingWidth],
  /// otherwise the next item will not be displayed on 360 pixel screens.
  ///
  /// Since there is no cache extent yet, there is no way to preload the next
  /// items otherwise, see https://bit.ly/34j83mu.
  final double itemWidth;

  final double paddingWidth;

  final int itemCount;

  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: PageController(
        viewportFraction:
            (itemWidth + paddingWidth) / MediaQuery.of(context).size.width,
      ),
      // Make sure items are not clipped when there is horizontal space
      // left next to the last item and the user scrolls.
      clipBehavior: Clip.none,
      padEnds: false,
      itemCount: itemCount,
      itemBuilder: (context, i) {
        return Padding(
          padding: EdgeInsets.only(
            // This will make the rightmost item wider by paddingWidth pixels
            // than the other widgets. The alternative is to make this item the
            // same size as the others, but then the padding is too large for
            // the rightmost widget. The slightly bigger widget is probably
            // less noticeable.
            right: i != itemCount - 1 ? paddingWidth : 0,
          ),
          child: itemBuilder(context, i),
        );
      },
    );
  }
}
