import 'package:flutter/material.dart';

import '../../../i18n/i18n.dart';
import '../../../utils/durations.dart';
import '../../../widgets/pulsing_circle_painter.dart';
import '../util/bottom_navigation_bar_height.dart';

class EmptyHome extends StatefulWidget {
  const EmptyHome({Key? key}) : super(key: key);

  @override
  EmptyHomeState createState() => EmptyHomeState();
}

class EmptyHomeState extends State<EmptyHome>
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
        Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              64,
              0,
              64,
              getBottomNavigationBarHeight(context),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  S.of(context).noDecksYet,
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(height: 12),
                Text(
                  S.of(context).emptyDeckListSubtitleText,
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
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
