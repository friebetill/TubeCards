import 'dart:math';

import 'package:flutter/material.dart';

import 'themes/custom_theme.dart';

/// Utility class to generate routes featuring specific transition effects.
class PageRoutes {
  /// Private constructor.
  PageRoutes._();

  /// Returns a [PageRoute] where the new route appears with a expanding circle.
  ///
  /// The back transition is a normal material transition.
  static PageRoute<T> expandingCircle<T>(
    Widget newRoute, {
    Duration transitionDuration = const Duration(milliseconds: 1000),
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation1, animation2) => newRoute,
      transitionsBuilder: (context, animation1, animation2, newRoute) {
        if (animation1.status == AnimationStatus.forward) {
          final opacity =
              (-1.0 + animation1.value * 2).clamp(0.0, 1.0).toDouble();

          return Container(
            constraints: const BoxConstraints.expand(),
            child: CustomPaint(
              painter: _ExpandingCirclePainter(
                context: context,
                animation: animation1,
                color: Theme.of(context).custom.successColor,
              ),
              child: Opacity(
                opacity: opacity,
                child: newRoute,
              ),
            ),
          );
        } else {
          // Code taken from _FadeUpwardsPageTransition in
          // page_transitions_theme.dart.
          final bottomUpTween = Tween<Offset>(
            begin: const Offset(0, 0.25),
            end: Offset.zero,
          );

          final Animation<double> fastAnimation = CurvedAnimation(
            parent: animation1,
            curve: const Interval(0.7, 1),
          );

          final Animatable<double> fastOutSlowInTween =
              CurveTween(curve: Curves.fastOutSlowIn);
          final Animatable<double> easeInTween =
              CurveTween(curve: Curves.easeIn);
          final positionAnimation =
              fastAnimation.drive(bottomUpTween.chain(fastOutSlowInTween));
          final opacityAnimation = fastAnimation.drive(easeInTween);

          return SlideTransition(
            position: positionAnimation,
            child: FadeTransition(
              opacity: opacityAnimation,
              child: newRoute,
            ),
          );
        }
      },
      transitionDuration: transitionDuration,
      settings: settings,
    );
  }
}

/// The class that expands a circle from the bottom right until the entire
/// screen is filled and then it fades.
class _ExpandingCirclePainter extends CustomPainter {
  /// Creates an instance of [_ExpandingCirclePainter].
  _ExpandingCirclePainter({
    required this.animation,
    required this.context,
    this.color = Colors.blueAccent,
  }) : super(repaint: animation);

  /// Animation driving the expanding process.
  final Animation<double> animation;

  /// The base color used to paint the circle.
  final Color color;

  /// Build context to access the height and width of the screen.
  final BuildContext context;

  @override
  void paint(Canvas canvas, Size _) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    const iconSize = 35.0;
    const paddingButton = 70;
    const buttonRowHeight = 40;

    final buttonXPosition = width - iconSize / 2 - paddingButton;
    final buttonYPosition = height - buttonRowHeight - 8;
    final radius = sqrt(
      buttonXPosition * buttonXPosition + buttonYPosition * buttonYPosition,
    );

    canvas.drawCircle(
      Offset(buttonXPosition, buttonYPosition),
      iconSize + ((radius - iconSize) * animation.value * 2).clamp(0, radius),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_ExpandingCirclePainter _) {
    return true;
  }
}
