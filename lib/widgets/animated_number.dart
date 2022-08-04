import 'package:flutter/material.dart';

class AnimatedNumber extends StatefulWidget {
  const AnimatedNumber({
    required this.end,
    this.start = 0.0,
    this.style,
    this.textAlign,
    this.strutStyle,
    this.duration = const Duration(milliseconds: 1000),
    this.decimalPoint = 2,
    this.isLoading = false,
    this.loadingPlaceHolder = '',
    Key? key,
  }) : super(key: key);

  final double start;
  final double end;
  final Duration duration;
  final TextStyle? style;
  final TextAlign? textAlign;
  final StrutStyle? strutStyle;
  final int decimalPoint;
  final bool isLoading;
  final String loadingPlaceHolder;

  @override
  AnimatedNumberState createState() => AnimatedNumberState();
}

class AnimatedNumberState extends State<AnimatedNumber>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(duration: widget.duration, vsync: this);
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );
  late Animation<double> _animation = Tween<double>(
    begin: widget.start,
    end: widget.end,
  ).animate(_curve);
  bool _hasShowNumber = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isLoading) {
      _controller.forward();
      _hasShowNumber = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedNumber oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isLoading || (oldWidget.end == widget.end && _hasShowNumber)) {
      return;
    }

    _animation = Tween<double>(
      begin: _animation.value,
      end: widget.end.toDouble(),
    ).animate(_curve);
    _controller
      ..reset()
      ..forward();
    _hasShowNumber = true;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Text(
        widget.loadingPlaceHolder,
        style: widget.style,
        textAlign: widget.textAlign,
        strutStyle: widget.strutStyle,
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        if (widget.isLoading) {
          return Text(
            widget.loadingPlaceHolder,
            style: widget.style,
            textAlign: widget.textAlign,
            strutStyle: widget.strutStyle,
          );
        }

        return Text(
          _animation.value.toStringAsFixed(widget.decimalPoint),
          style: widget.style,
          textAlign: widget.textAlign,
          strutStyle: widget.strutStyle,
        );
      },
    );
  }
}
