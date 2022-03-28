import 'package:flutter/material.dart';

/// Widget to display a percentage filled bar with two labels, left and right
/// above the bar.
///
/// If the fill percentage changes, an animation is started from the last fill
/// percentage to the new one.
class LabeledBar extends StatelessWidget {
  const LabeledBar({
    required this.foregroundColor,
    required this.backgroundColor,
    required this.fillPercentage,
    this.leftText,
    this.rightText,
    this.animationDuration = const Duration(milliseconds: 400),
    Key? key,
  }) : super(key: key);

  /// The foreground color of the bar.
  final Color foregroundColor;

  /// The background color of the bar.
  final Color backgroundColor;

  /// The text displayed above the bar on the left.
  final Text? leftText;

  /// The text displayed above the bar on the right.
  final Text? rightText;

  /// The percentage to which the bar is filled.
  final double fillPercentage;

  /// The duration the fill animation needs from 0% to [fillPercentage].
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[leftText ?? Container(), rightText ?? Container()],
        ),
        if (leftText != null || rightText != null) const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraint) {
            return SizedBox(
              width: constraint.biggest.width,
              height: 20,
              child: _AnimatedColorBar(
                barWidth: constraint.biggest.width,
                barHeight: 20,
                foregroundColor: foregroundColor,
                backgroundColor: backgroundColor,
                fillPercentage: fillPercentage,
                animationDuration: animationDuration,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AnimatedColorBar extends StatefulWidget {
  const _AnimatedColorBar({
    required this.barWidth,
    required this.barHeight,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.fillPercentage,
    required this.animationDuration,
    Key? key,
  }) : super(key: key);

  /// Width of the foreground bar.
  final double barWidth;

  /// Height of the foreground and background bar.
  final double barHeight;

  final Color foregroundColor;
  final Color backgroundColor;
  final double fillPercentage;
  final Duration animationDuration;

  @override
  State<StatefulWidget> createState() => _AnimatedColorBarState();
}

class _AnimatedColorBarState extends State<_AnimatedColorBar>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: widget.animationDuration, vsync: this);
    _widthAnimation = Tween<double>(
      begin: 0,
      end: widget.fillPercentage * widget.barWidth,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedColorBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    _widthAnimation = Tween<double>(
      begin: _widthAnimation.value,
      end: widget.fillPercentage * widget.barWidth,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          width: widget.barWidth,
          height: widget.barHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            color: widget.backgroundColor,
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return Container(
              width: _widthAnimation.value > widget.barWidth * 0.05 ||
                      _widthAnimation.value == 0
                  ? _widthAnimation.value
                  : widget.barWidth * 0.05,
              height: widget.barHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: widget.foregroundColor,
              ),
            );
          },
        ),
      ],
    );
  }
}
