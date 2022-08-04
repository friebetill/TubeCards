import 'dart:math';

import 'package:flutter/material.dart';

import '../animations/slide_out_animation.dart';

class SlideOutLeftAnimationComponent extends StatefulWidget {
  const SlideOutLeftAnimationComponent({
    required this.onAnimationCompleted,
    required this.child,
    required this.animateOnToggle,
    required this.resetOnToggle,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final bool animateOnToggle;
  final bool resetOnToggle;
  final VoidCallback onAnimationCompleted;

  @override
  SlideOutLeftAnimationComponentState createState() =>
      SlideOutLeftAnimationComponentState();
}

class SlideOutLeftAnimationComponentState
    extends State<SlideOutLeftAnimationComponent>
    with SingleTickerProviderStateMixin {
  late SlideOutLeftAnimation animation;

  @override
  void initState() {
    super.initState();
    animation = SlideOutLeftAnimation(AnimationController(vsync: this))
      ..controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onAnimationCompleted();
          // widget.viewModel.onCardLabeled(context, Confidence.unknown);
          // // setState(() => _emphasizeUnknownCardLabelButton = false);
          // _frontScrollController.jumpTo(0);
          // _backScrollController.jumpTo(0);
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return animation.buildSlideOutLeftTransition(
      child: widget.child,
    );
  }

  @override
  void didUpdateWidget(SlideOutLeftAnimationComponent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.animateOnToggle != oldWidget.animateOnToggle) {
      animation.slideOut();
    }
    if (widget.resetOnToggle != oldWidget.resetOnToggle) {
      animation.controller.reset();
    }
  }

  @override
  void dispose() {
    animation.controller.dispose();
    super.dispose();
  }
}

/// The animations while the card slides left out
///
/// Rotates the card while moving it out of the screen
/// to the left side.
class SlideOutLeftAnimation extends SlideOutAnimation {
  /// Constructs an instance of [SlideOutRightAnimation].
  SlideOutLeftAnimation(AnimationController controller)
      : super(
          controller: controller,
          targetOffset: _targetLeftOffset,
          targetAngle: _targetAngle,
        );

  /// The target offset to the left side.
  ///
  /// Since the card is rotated as well, we choose an offset above 1.0.
  static const Offset _targetLeftOffset = Offset(-1.2, 0);

  /// The target angle of the card at the end of the animation.
  static const double _targetAngle = -pi / 12.0;

  Widget buildSlideOutLeftTransition({required Widget child}) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        return SlideTransition(
          position: cardOffset,
          child: Transform.rotate(
            angle: cardRotation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
