import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class EmbedDividerBuilder extends EmbedBuilder {
  @override
  String get key => 'divider';

  /// Builds a widget for the given divider embed.
  @override
  Widget build(
    BuildContext context,
    QuillController controller,
    Embed node,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  ) {
    return const Divider();
  }
}
