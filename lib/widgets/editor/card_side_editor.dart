import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'editor_style.dart';
import 'embed_divider_builder.dart';
import 'embed_image_builder.dart';

/// Editor for a single side of a card.
class CardSideEditor extends StatelessWidget {
  const CardSideEditor({
    required this.controller,
    required this.focusNode,
    this.placeholder,
    this.readOnly = false,
    this.contentPadding = const EdgeInsets.all(24),
    Key? key,
  }) : super(key: key);

  final QuillController controller;

  /// Placeholder that will be displayed when the editor is empty.
  ///
  /// The placeholder will no longer be displayed as soon as text is entered or
  /// a block formatting option is selected.
  final String? placeholder;

  final FocusNode? focusNode;

  final bool readOnly;

  final EdgeInsets contentPadding;

  @override
  Widget build(BuildContext context) {
    return QuillEditor(
      controller: controller,
      scrollController: ScrollController(),
      scrollable: true,
      focusNode: focusNode!,
      autoFocus: false,
      readOnly: readOnly,
      placeholder: placeholder,
      expands: false,
      padding: contentPadding,
      embedBuilders: <EmbedBuilder>[
        EmbedDividerBuilder(),
        EmbedImageBuilder(),
      ],
      customStyles: buildEditorStyle(context),
    );
  }
}
