import 'dart:convert';

import 'package:delta_markdown/delta_markdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'editor_style.dart';
import 'embed_divider_builder.dart';
import 'embed_image_builder.dart';

/// Read-only viewer of a card side.
class CardSideViewer extends StatelessWidget {
  /// Constructs a new [CardSideViewer].
  CardSideViewer({
    Key? key,
    String? text,
    this.onTap,
    this.padding = const EdgeInsets.all(24),
  })  : _controller = QuillController(
          document: _parseDocument(text ?? ''),
          selection: const TextSelection.collapsed(offset: 0),
        ),
        super(key: key);

  /// Padding applied to the rendered content.
  final EdgeInsets padding;

  final QuillController _controller;

  final _readOnly = true;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return QuillEditor(
      controller: _controller,
      scrollController: ScrollController(),
      scrollable: true,
      focusNode: FocusNode(canRequestFocus: false),
      autoFocus: false,
      readOnly: _readOnly,
      onTapUp: (_, __) {
        onTap?.call();
        return onTap != null;
      },
      enableInteractiveSelection: false,
      expands: false,
      padding: padding,
      embedBuilders: [
        EmbedDividerBuilder(),
        EmbedImageBuilder(),
      ],
      customStyles: buildEditorStyle(context),
    );
  }

  static Document _parseDocument(String markdown) {
    final delta = Delta.fromJson(jsonDecode(markdownToDelta(markdown)) as List);

    return delta.isEmpty
        ? Document()
        : (Document()..compose(delta, ChangeSource.LOCAL));
  }
}
