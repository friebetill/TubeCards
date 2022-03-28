import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/themes/custom_theme.dart';

class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({
    this.duration = const Duration(milliseconds: 1200),
    Key? key,
  }) : super(key: key);

  /// Duration of the shimmer animation.
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).brightness == Brightness.light
        ? Colors.grey.shade300
        : Theme.of(context).custom.elevation4DPColor;
    final highlightColor = Theme.of(context).brightness == Brightness.light
        ? Colors.grey.shade200
        : Theme.of(context).custom.elevation8DPColor;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: duration,
      child: Container(color: baseColor),
    );
  }
}
