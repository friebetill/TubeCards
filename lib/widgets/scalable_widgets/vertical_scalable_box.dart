import 'package:flutter/material.dart';

import '../../utils/sizes.dart';

class VerticalScalableBox extends StatelessWidget {
  /// Returns a widget with a minimum height that scales with the screen height.
  ///
  /// The height is calculated as [minHeight] + (screen height -
  /// [minimumWidgetHeight]) * [scaleFactor].
  const VerticalScalableBox({
    required this.child,
    this.minHeight = 64,
    this.scaleFactor = 0.3,
    Key? key,
  }) : super(key: key);

  final Widget child;

  /// The minimum size of the image.
  final int minHeight;

  /// Factor of the screen height which is added to [minHeight].
  final double scaleFactor;

  @override
  Widget build(BuildContext context) {
    final currentScreenSize = MediaQuery.of(context).size.height;

    return SizedBox(
      height:
          minHeight + (currentScreenSize - minimumWidgetHeight) * scaleFactor,
      child: child,
    );
  }
}
