import 'package:flutter/material.dart';

const Duration _expandDuration = Duration(milliseconds: 200);

/// The animations while the card is flipped.
class ExpandAnimation {
  ExpandAnimation(AnimationController controller)
      : _controller = controller..duration = _expandDuration,
        iconTurns = Tween<double>(begin: 0, end: 0.5).animate(controller);

  /// The controller for the animations.
  final AnimationController _controller;
  final Animation<double> iconTurns;

  bool get isExpanded =>
      _controller.value == 1 || _controller.status == AnimationStatus.forward;
  Animation<double> get view => _controller.view;

  void shrink() => _controller.reverse();
  void expand() => _controller.forward();
  void dispose() => _controller.dispose();

  Widget buildExpansionAnimation({Widget? child}) {
    return ClipRect(
      child: FadeTransition(
        opacity: _controller,
        child: AnimatedBuilder(
          animation: _controller.view,
          builder: (_, child) {
            return Align(
              // Align also sets the alignment, although we only want to set the
              // heightFactor. The alternative FrationallySizedBox doesn't work.
              alignment: Alignment.centerLeft,
              heightFactor: _controller.view.value,
              child: child,
            );
          },
          child: child,
        ),
      ),
    );
  }
}
