import 'dart:ui';

import 'package:flutter/material.dart' hide Image;

import 'component/draw_image/draw_image_component.dart';

/// The screen with which the user can paint images.
///
/// Returns the painted [Image] when this page is closed.
/// If the user aborted, null is returned.
class DrawImagePage extends StatelessWidget {
  const DrawImagePage({Key? key, this.imageUrl}) : super(key: key);

  /// The name of the route to the [DrawImagePage].
  static const String routeName = '/card/draw-image';

  /// The optional url of an image.
  ///
  /// Opens an empty canvas, if no URL is given.
  final String? imageUrl;

  @override
  Widget build(BuildContext context) => DrawImageComponent(imageUrl);
}
