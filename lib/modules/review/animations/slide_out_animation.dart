import 'package:flutter/material.dart';

/// The duration of the animations.
const Duration shortAnimationDuration = Duration(milliseconds: 300);

/// All animations that take place while the card is sliding out.
abstract class SlideOutAnimation {
  /// Constructs an instance of [SlideOutAnimation].
  ///
  /// The [targetOffset] specifies the offset from the current position
  /// at which the animation is finished.
  /// A negative x-Offset will move the card to the left whereas a positive
  /// x-Offset will move the card to the right side.
  ///
  /// The [targetAngle] specifies the angle of the card at the end of the
  /// animation.
  SlideOutAnimation({
    required AnimationController controller,
    required Offset targetOffset,
    required double targetAngle,
  })  : controller = controller..duration ??= shortAnimationDuration,
        borderRadius = Tween<double>(begin: 0, end: 10).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0, 0.2),
          ),
        ),
        cardOffset =
            Tween<Offset>(begin: Offset.zero, end: targetOffset).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.2, 1, curve: Curves.easeInCubic),
          ),
        ),
        cardRotation = Tween<double>(begin: 0, end: targetAngle).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.2, 1, curve: Curves.easeInCubic),
          ),
        );

  /// The controller for the animations.
  final AnimationController controller;

  /// The animation that rotates the card slightly right when the card is
  /// sliding out.
  final Animation<double> cardRotation;

  /// Animation that moves the flashcard right out of the visible area.
  final Animation<Offset> cardOffset;

  /// Animation to smooth the corners of the back card.
  final Animation<double> borderRadius;

  /// Slides the card outside the screen.
  void slideOut() => controller.forward();
}
