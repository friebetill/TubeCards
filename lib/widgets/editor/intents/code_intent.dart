import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';

class CodeIntent extends Intent {
  const CodeIntent(this._controller);

  final QuillController _controller;

  static Map<Type, Action<Intent>> getAction() {
    return {
      CodeIntent: CallbackAction<CodeIntent>(
        onInvoke: (i) => i.onInvoke(),
      ),
    };
  }

  Map<LogicalKeySet, Intent> getShortCut() {
    return {
      LogicalKeySet(
        Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
        LogicalKeyboardKey.digit3,
      ): this,
    };
  }

  void onInvoke() {
    final selectionStyle = _controller.getSelectionStyle();
    final isSelectionCode =
        selectionStyle.values.any((a) => a == Attribute.codeBlock);

    if (isSelectionCode) {
      _controller.formatSelection(Attribute.clone(Attribute.codeBlock, null));
    } else {
      _controller.formatSelection(Attribute.codeBlock);
    }
  }
}
