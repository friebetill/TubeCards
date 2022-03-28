import 'package:flutter/material.dart';

class HorizontalScalableBox extends StatelessWidget {
  /// Returns a widget with a minimum height that scales with the widget width.
  ///
  /// The height is calculated as [minHeight] + widget width * [scaleFactor].
  const HorizontalScalableBox({
    required this.child,
    this.minHeight = 200,
    this.scaleFactor = 0.2,
    Key? key,
  }) : super(key: key);

  final Widget child;

  /// The minimum size of the image.
  final int minHeight;

  /// Factor of the widget width which is added to [minHeight].
  final double scaleFactor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: minHeight + constraints.maxWidth * scaleFactor,
          child: child,
        );
      },
    );
  }
}
