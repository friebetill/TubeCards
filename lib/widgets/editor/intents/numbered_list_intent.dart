import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';

class NumberedListIntent extends Intent {
  const NumberedListIntent(this._controller);

  final QuillController _controller;

  static Map<Type, Action<Intent>> getAction() {
    return {
      NumberedListIntent: CallbackAction<NumberedListIntent>(
        onInvoke: (i) => i.onInvoke(),
      ),
    };
  }

  Map<LogicalKeySet, Intent> getShortCut() {
    return {
      LogicalKeySet(
        Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
        LogicalKeyboardKey.digit1,
      ): this,
    };
  }

  void onInvoke() {
    final selectionStyle = _controller.getSelectionStyle();
    final isSelectionOrderedList =
        selectionStyle.values.any((a) => a == Attribute.ol);

    if (isSelectionOrderedList) {
      _controller.formatSelection(Attribute.clone(Attribute.ol, null));
    } else {
      _controller.formatSelection(Attribute.ol);
    }
  }
}
