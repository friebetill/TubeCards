import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';

class BoldIntent extends Intent {
  const BoldIntent(this._controller);

  final QuillController _controller;

  static Map<Type, Action<Intent>> getAction() {
    return {
      BoldIntent: CallbackAction<BoldIntent>(
        onInvoke: (i) => i.onInvoke(),
      ),
    };
  }

  Map<LogicalKeySet, Intent> getShortCut() {
    return {
      LogicalKeySet(
        Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
        LogicalKeyboardKey.keyB,
      ): this,
    };
  }

  void onInvoke() {
    final selectionStyle = _controller.getSelectionStyle();
    final isSelectionBold =
        selectionStyle.values.any((a) => a == Attribute.bold);

    if (isSelectionBold) {
      _controller.formatSelection(Attribute.clone(Attribute.bold, null));
    } else {
      _controller.formatSelection(Attribute.bold);
    }
  }
}
