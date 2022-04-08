import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:tuple/tuple.dart';

DefaultStyles buildEditorStyle(BuildContext context) {
  final theme = Theme.of(context);
  final fontFamily = _getFontFamily(theme);
  final codeFontFamily = _getCodeFontFamily(theme);
  final baseStyle = DefaultTextStyle.of(context)
      .style
      .copyWith(fontSize: 20, height: 1.2, fontFamily: fontFamily);

  const baseSpacing = Tuple2<double, double>(6, 0);

  return DefaultStyles(
    h1: DefaultTextBlockStyle(
      baseStyle.copyWith(
        fontSize: 34,
        color: baseStyle.color!.withOpacity(0.7),
        height: 1.15,
        fontWeight: FontWeight.w300,
      ),
      const Tuple2(16, 0),
      const Tuple2(0, 0),
      null,
    ),
    h2: DefaultTextBlockStyle(
      baseStyle.copyWith(
        fontSize: 24,
        color: baseStyle.color!.withOpacity(0.7),
        height: 1.15,
        fontWeight: FontWeight.normal,
      ),
      const Tuple2(8, 0),
      const Tuple2(0, 0),
      null,
    ),
    h3: DefaultTextBlockStyle(
      baseStyle.copyWith(
        fontSize: 20,
        color: baseStyle.color!.withOpacity(0.7),
        height: 1.25,
        fontWeight: FontWeight.w500,
      ),
      const Tuple2(8, 0),
      const Tuple2(0, 0),
      null,
    ),
    paragraph: DefaultTextBlockStyle(
      baseStyle,
      const Tuple2(6, 0),
      const Tuple2(0, 0),
      null,
    ),
    bold: const TextStyle(fontWeight: FontWeight.bold),
    italic: const TextStyle(fontStyle: FontStyle.italic),
    underline: const TextStyle(decoration: TextDecoration.underline),
    strikeThrough: const TextStyle(decoration: TextDecoration.lineThrough),
    link: TextStyle(
      color: theme.colorScheme.primary,
      decoration: TextDecoration.underline,
    ),
    placeHolder: DefaultTextBlockStyle(
      baseStyle.copyWith(
        fontSize: 20,
        color: Colors.grey.withOpacity(0.6),
      ),
      const Tuple2(0, 0),
      const Tuple2(0, 0),
      null,
    ),
    lists: DefaultListBlockStyle(
      baseStyle,
      baseSpacing,
      const Tuple2(0, 6),
      null,
      null,
    ),
    quote: DefaultTextBlockStyle(
      TextStyle(color: baseStyle.color!.withOpacity(0.6)),
      baseSpacing,
      const Tuple2(6, 2),
      BoxDecoration(
        border: Border(
          left: BorderSide(width: 4, color: Colors.grey.shade300),
        ),
      ),
    ),
    code: DefaultTextBlockStyle(
      baseStyle.copyWith(
        color: theme.brightness == Brightness.light
            ? Colors.blueGrey.shade800
            : Colors.blueGrey.shade100,
        fontFamily: codeFontFamily,
        fontSize: 13,
        height: 1.15,
      ),
      baseSpacing,
      const Tuple2(0, 0),
      BoxDecoration(
        color: theme.brightness == Brightness.light
            ? Colors.blueGrey.shade50
            : Colors.blueGrey.shade900,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
    indent: DefaultTextBlockStyle(
      baseStyle,
      baseSpacing,
      const Tuple2(0, 6),
      null,
    ),
    align: DefaultTextBlockStyle(
      baseStyle,
      const Tuple2(0, 0),
      const Tuple2(0, 0),
      null,
    ),
    leading: DefaultTextBlockStyle(
      baseStyle,
      const Tuple2(0, 0),
      const Tuple2(0, 0),
      null,
    ),
    sizeSmall: const TextStyle(fontSize: 10),
    sizeLarge: const TextStyle(fontSize: 18),
    sizeHuge: const TextStyle(fontSize: 22),
  );
}

String _getFontFamily(ThemeData theme) {
  switch (theme.platform) {
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return 'SanFranciscoPro';
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      return 'Roboto';
    default:
      throw UnimplementedError();
  }
}

String _getCodeFontFamily(ThemeData theme) {
  switch (theme.platform) {
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return 'SanFranciscoMono';
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      return 'RobotoMono';
    default:
      throw UnimplementedError();
  }
}
