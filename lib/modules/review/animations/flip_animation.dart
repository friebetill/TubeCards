import 'dart:math';

import 'package:flutter/material.dart';

import 'slide_out_animation.dart';

/// The animations while the card is flipped.
class FlipAnimation {
  /// Constructs an instance of [FlipAnimation].
  FlipAnimation(AnimationController controller)
      : controller = controller..duration ??= shortAnimationDuration,
        frontSideScale = Tween<double>(begin: 1, end: 0.8).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0, 0.4, curve: Curves.easeOut),
          ),
        ),
        backSideScale = Tween<double>(begin: 0.8, end: 1).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.6, 1, curve: Curves.easeIn),
          ),
        ),
        frontSideBorderRadius = Tween<double>(begin: 0, end: 10).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0, 0.2),
          ),
        ),
        backSideBorderRadius = Tween<double>(begin: 10, end: 0).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.8, 1),
          ),
        ),
        frontSideAngle = Tween<double>(begin: 0, end: pi / 2).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.2, 0.5, curve: Curves.easeOutQuad),
          ),
        ),
        backSideAngle = Tween<double>(begin: -pi / 2, end: 0).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.5, 0.8, curve: Curves.easeInQuad),
          ),
        );

  /// The controller for the animations.
  final AnimationController controller;

  /// Animation to scale down the front side during the flip.
  final Animation<double> frontSideScale;

  /// Animation to smooth the corners of the front card.
  final Animation<double> frontSideBorderRadius;

  /// Animation to flip the front side of the flashcard 90 degrees.
  final Animation<double> frontSideAngle;

  /// Animation to flip the back side of the flashcard 90 degrees.
  final Animation<double> backSideAngle;

  /// Animation to scale down the back side during the flip.
  final Animation<double> backSideScale;

  /// Animation to smooth the corners of the back card.
  final Animation<double> backSideBorderRadius;

  /// Animates the card to back from the current state.
  void toFrontSide() => controller.reverse();

  /// Animates the card to back from the current state.
  void toBackSide() => controller.forward();

  /// Whether the front side of the flashcard is shown.
  bool get isFrontSideShown => controller.value <= 0.5;

  Widget buildFlipFrontCardTransition({required Widget child}) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        return Opacity(
          opacity: isFrontSideShown ? 1 : 0,
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0003)
              ..rotateY(frontSideAngle.value),
            alignment: Alignment.center,
            child: ScaleTransition(
              scale: frontSideScale,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }

  Widget buildFlipBackCardTransition({required Widget child}) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        return Opacity(
          opacity: !isFrontSideShown ? 1 : 0,
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0003)
              ..rotateY(backSideAngle.value),
            alignment: Alignment.center,
            child: ScaleTransition(
              scale: backSideScale,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
