import 'package:flutter/material.dart';

import '../../../i18n/i18n.dart';
import '../../../utils/durations.dart';
import '../../../widgets/pulsing_circle_painter.dart';
import '../../home/util/bottom_navigation_bar_height.dart';
import 'deck_cover_image/deck_cover_image_component.dart';

class EmptyDeck extends StatefulWidget {
  const EmptyDeck({required this.deckId, Key? key}) : super(key: key);

  final String deckId;

  @override
  EmptyDeckState createState() => EmptyDeckState();
}

class EmptyDeckState extends State<EmptyDeck>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this)
      ..repeat(period: Durations.milliseconds4000);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildFloatingActionButtonAnimation(context),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DeckCoverImageComponent(deckId: widget.deckId),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    64,
                    0,
                    64,
                    getBottomNavigationBarHeight(context) + 128,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        S.of(context).noCardsYet,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        S.of(context).emptyCardListSubtitleText,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(
                              color: Theme.of(context).hintColor,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildFloatingActionButtonAnimation(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: getBottomNavigationBarHeight(context)),
      child: OverflowBox(
        alignment: Alignment.bottomCenter,
        child: CustomPaint(
          painter: PulsingCirclePainter(
            animation: _animationController,
            color: Colors.blueAccent.shade200,
          ),
          child: const SizedBox(width: 300),
        ),
      ),
    );
  }
}
