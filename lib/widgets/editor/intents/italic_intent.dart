import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';

class ItalicIntent extends Intent {
  const ItalicIntent(this._controller);

  final QuillController _controller;

  static Map<Type, Action<Intent>> getAction() {
    return {
      ItalicIntent: CallbackAction<ItalicIntent>(
        onInvoke: (i) => i.onInvoke(),
      ),
    };
  }

  Map<LogicalKeySet, Intent> getShortCut() {
    return {
      LogicalKeySet(
        Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
        LogicalKeyboardKey.keyI,
      ): this,
    };
  }

  void onInvoke() {
    final selectionStyle = _controller.getSelectionStyle();
    final isSelectionItalic =
        selectionStyle.values.any((a) => a == Attribute.italic);

    if (isSelectionItalic) {
      _controller.formatSelection(Attribute.clone(Attribute.italic, null));
    } else {
      _controller.formatSelection(Attribute.italic);
    }
  }
}
