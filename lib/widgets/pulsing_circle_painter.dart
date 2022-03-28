import 'dart:math';

import 'package:flutter/material.dart';

/// Widget showing multiple circles extending outwards with decreasing opacity.
class PulsingCirclePainter extends CustomPainter {
  /// Creates an instance of [PulsingCirclePainter].
  PulsingCirclePainter({
    required this.animation,
    this.color = Colors.blueAccent,
  }) : super(repaint: animation);

  /// Animation driving the painting process.
  final Animation<double> animation;

  /// The base color used to paint the circles. The color is used with different
  /// opacity to achieve the fade out effect.
  final Color color;

  /// Draws a single circle with the radius and opacity being dependent on the
  /// given [value].
  void circle(Canvas canvas, Rect rect, double value) {
    final opacity = (1.0 - (value / 4.0)).clamp(0.0, 1.0).toDouble();
    final calculatedColor = color.withOpacity(opacity);

    final size = rect.width / 2;
    final area = size * size;
    final radius = sqrt(area * value / 4);

    final paint = Paint()..color = calculatedColor;
    canvas.drawCircle(rect.center, radius, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(0, 0, size.width, size.height);

    for (var wave = 3; wave >= 0; wave--) {
      circle(canvas, rect, wave + animation.value);
    }
  }

  @override
  bool shouldRepaint(PulsingCirclePainter oldDelegate) {
    return true;
  }
}
