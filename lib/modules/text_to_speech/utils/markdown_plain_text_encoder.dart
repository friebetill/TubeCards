import 'dart:convert';

import 'package:delta_markdown/delta_markdown.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:meta/meta.dart';

/// Encodes a given Markdown formatted string into plain text.
///
/// The plain text does not contain any Markdown-specific formatting (e.g.
/// underscores for italic text).
@immutable
class MarkdownPlainTextEncoder extends Converter<String, String> {
  const MarkdownPlainTextEncoder() : super();

  @override
  String convert(String input) {
    final delta = Delta.fromJson(jsonDecode(markdownToDelta(input)) as List);
    final document = delta.isEmpty ? Document() : Document.fromDelta(delta);

    return document.toPlainText();
  }
}
