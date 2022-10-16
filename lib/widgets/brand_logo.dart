import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../utils/assets.dart';

/// Sizing options for a BrandLogo.
enum BrandLogoSize {
  /// Corresponds to a size of 16 pixels.
  tiny,

  /// Corresponds to a size of 24 pixels.
  small,

  /// Corresponds to a size of 32 pixels.
  medium,

  /// Corresponds to a size of 48 pixels.
  large,

  /// Corresponds to a size of 72 pixels.
  huge,
}

/// Displays the brand logo and if needed the text 'TubeCards' next to it.
class BrandLogo extends StatelessWidget {
  /// Create a new instance of [BrandLogo].
  ///
  /// The [size] of the logo can be adjusted using [BrandLogoSize] and defaults
  /// to [BrandLogoSize.medium]. In addition the title 'TubeCards' can be
  /// deactivated with [showText] and defaults to false.
  const BrandLogo({
    this.size = BrandLogoSize.medium,
    this.showLogo = true,
    this.showText = true,
    Key? key,
  }) : super(key: key);

  /// Specifies the size of both the logo and the text
  final BrandLogoSize size;

  /// Whether to show the TubeCards logo.
  final bool showLogo;

  /// Whether to show the text 'TubeCards' next to the logo.
  final bool showText;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (showLogo) _buildLogo(brightness),
        if (showLogo & showText) SizedBox(width: _convertedSize() * 0.25),
        if (showText) _buildText(brightness),
      ],
    );
  }

  Widget _buildLogo(Brightness brightness) {
    return SvgPicture.asset(
      brightness == Brightness.light
          ? Assets.images.brandLogo
          : Assets.images.brandLogoWhite,
      width: _convertedSize(),
    );
  }

  Widget _buildText(Brightness brightness) {
    return SvgPicture.asset(
      brightness == Brightness.light
          ? Assets.images.brandText
          : Assets.images.brandTextWhite,
      height: _convertedSize(),
    );
  }

  double _convertedSize() {
    switch (size) {
      case BrandLogoSize.tiny:
        return 16;
      case BrandLogoSize.small:
        return 24;
      case BrandLogoSize.medium:
        return 32;
      case BrandLogoSize.large:
        return 48;
      case BrandLogoSize.huge:
        return 72;
    }
  }
}
