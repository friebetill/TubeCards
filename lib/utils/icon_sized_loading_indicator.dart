import 'package:flutter/material.dart';

/// A loading indicator that has the same size as an default icon.
///
/// An icon is 20x20 pixels by default, but a loading indicator that is
/// also 20x20 is proportionally too large. Therefore this widget returns
/// a 16x16 pixel loading indiciator with a 4 pixel padding.
class IconSizedLoadingIndicator extends StatelessWidget {
  const IconSizedLoadingIndicator({this.color, Key? key}) : super(key: key);

  /// The color of the loading indicator.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        height: 16,
        width: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: color != null ? AlwaysStoppedAnimation(color) : null,
        ),
      ),
    );
  }
}
