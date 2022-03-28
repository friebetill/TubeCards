import 'package:flutter/widgets.dart';

Size textSize(String text, [TextStyle? style]) {
  final textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout();

  return textPainter.size;
}
