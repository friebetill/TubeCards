import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:rxdart/rxdart.dart';

class SwipeFeedback extends StatefulWidget {
  const SwipeFeedback({
    required this.child,
    required this.onRightPanEnd,
    required this.onLeftPanEnd,
    required this.onRightDistanceCrossed,
    required this.onLeftDistanceCrossed,
    required this.resetOnToggle,
    this.targetDistance = 80,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onRightPanEnd;
  final VoidCallback onLeftPanEnd;
  final void Function(bool) onRightDistanceCrossed;
  final void Function(bool) onLeftDistanceCrossed;
  final bool resetOnToggle;
  final double targetDistance;

  @override
  SwipeFeedbackState createState() => SwipeFeedbackState();
}

class SwipeFeedbackState extends State<SwipeFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<Offset> _animation;

  late BehaviorSubject<Offset> _offset;
  late BehaviorSubject<double> _angle;
  late StreamSubscription<double> _angleSubscription;

  @override
  void initState() {
    super.initState();
    _offset = BehaviorSubject<Offset>.seeded(Offset.zero);
    _angle = BehaviorSubject<double>.seeded(0);
    Future.delayed(Duration.zero, () {
      final size = MediaQuery.of(context).size;
      _angleSubscription = _offset
          .map<double>((o) => o.dx * 0.3 / size.width)
          .listen(_angle.add);
    });

    _controller = AnimationController(vsync: this)
      ..addListener(() => _offset.add(_animation.value));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (details) => _controller.stop(),
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: StreamBuilder<Offset>(
        stream: _offset,
        initialData: Offset.zero,
        builder: (context, offset) {
          return Transform.translate(
            offset: offset.data!,
            child: StreamBuilder<double>(
              stream: _angle,
              builder: (context, angle) {
                return Transform.rotate(
                  angle: _angle.value,
                  child: widget.child,
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  void didUpdateWidget(SwipeFeedback oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.resetOnToggle != oldWidget.resetOnToggle) {
      _offset.add(Offset.zero);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _offset.close();
    _angleSubscription.cancel().then((_) => _angle.close());
    super.dispose();
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_exceedsLeftTargetDistance(_offset.value)) {
      widget.onLeftPanEnd.call();
    } else if (_exceedsRightTargetDistance(_offset.value)) {
      widget.onRightPanEnd.call();
    } else {
      _resetPosition(
        details.velocity.pixelsPerSecond,
        MediaQuery.of(context).size,
      );
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final exceedsLeftPreviously = _exceedsLeftTargetDistance(_offset.value);
    final exceedsRightPreviously = _exceedsRightTargetDistance(_offset.value);

    final offsetUpdated =
        _offset.value + Offset(details.delta.dx, details.delta.dy);
    final exceedsLeftUpdated = _exceedsLeftTargetDistance(offsetUpdated);
    final exceedsRightUpdated = _exceedsRightTargetDistance(offsetUpdated);

    if (exceedsLeftPreviously != exceedsLeftUpdated) {
      widget.onLeftDistanceCrossed(exceedsLeftUpdated);
    }

    if (exceedsRightPreviously != exceedsRightUpdated) {
      widget.onRightDistanceCrossed(exceedsRightUpdated);
    }

    _offset.add(offsetUpdated);
  }

  bool _exceedsLeftTargetDistance(Offset offset) {
    return offset.dx.abs() > widget.targetDistance &&
        offset.dx < widget.targetDistance;
  }

  bool _exceedsRightTargetDistance(Offset offset) {
    return offset.dx.abs() > widget.targetDistance &&
        offset.dx > widget.targetDistance;
  }

  /// Calculates and runs a [SpringSimulation].
  void _resetPosition(Offset pixelsPerSecond, Size size) {
    _animation = _controller
        .drive(Tween<Offset>(begin: _offset.value, end: Offset.zero));

    // Calculate the velocity relative to the unit interval, [0,1],
    // used by the animation controller.
    final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;

    const spring = SpringDescription(mass: 30, stiffness: 1, damping: 1);
    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    _controller.animateWith(simulation);
  }
}
