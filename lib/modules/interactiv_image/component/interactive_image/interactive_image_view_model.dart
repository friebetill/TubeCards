import 'dart:io';

import 'package:flutter/foundation.dart';

class InteractiveImageViewModel {
  InteractiveImageViewModel({
    required this.image,
    required this.heroTag,
    required this.isSvgImage,
    required this.onTap,
  });
  final File image;
  final String heroTag;
  final bool isSvgImage;

  final VoidCallback onTap;
}
