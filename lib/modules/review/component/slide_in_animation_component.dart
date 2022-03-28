import 'package:flutter/material.dart';

import '../animations/slide_out_animation.dart';

class SlideInAnimationComponent extends StatefulWidget {
  const SlideInAnimationComponent({
    required this.child,
    required this.animateOnToggle,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final bool animateOnToggle;

  @override
  State<SlideInAnimationComponent> createState() =>
      _SlideInAnimationComponentState();
}

class _SlideInAnimationComponentState extends State<SlideInAnimationComponent>
    with TickerProviderStateMixin {
  late _SlideInAnimation _slideInAnimation;

  @override
  void initState() {
    super.initState();
    _slideInAnimation =
        _SlideInAnimation(AnimationController(value: 1, vsync: this));
  }

  @override
  Widget build(BuildContext context) {
    return _slideInAnimation.buildSlideInTransition(
      child: widget.child,
    );
  }

  @override
  void didUpdateWidget(SlideInAnimationComponent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.animateOnToggle != oldWidget.animateOnToggle) {
      _slideInAnimation.slideIn();
    }
  }

  @override
  void dispose() {
    _slideInAnimation.controller.dispose();
    super.dispose();
  }
}

/// The animations while the card slides in.
class _SlideInAnimation {
  /// Constructs an instance of [_SlideInAnimation].
  _SlideInAnimation(AnimationController controller)
      : controller = controller..duration ??= shortAnimationDuration,
        cardOffset =
            Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0, 0.5, curve: Curves.easeOutCubic),
          ),
        ),
        cardScale = Tween<double>(begin: 0.8, end: 1).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.5, 1, curve: Curves.easeIn),
          ),
        ),
        borderRadius = Tween<double>(begin: 10, end: 0).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.5, 1),
          ),
        );

  /// The controller for the animations.
  final AnimationController controller;

  /// Animation to slide the flashcard from top to bottom into the visible area.
  final Animation<Offset> cardOffset;

  /// Animation to scale small scaled card up when the card reaches the center.
  final Animation<double> cardScale;

  /// Animation to smooth the corners of the front card.
  final Animation<double> borderRadius;

  /// Places the card outside the screen and then slides it in slowly.
  void slideIn() => controller.forward(from: 0);

  Widget buildSlideInTransition({required Widget child}) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        return SlideTransition(
          position: cardOffset,
          child: ScaleTransition(
            scale: cardScale,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
