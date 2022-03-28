import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';

class BulletedListIntent extends Intent {
  const BulletedListIntent(this._controller);

  final QuillController _controller;

  static Map<Type, Action<Intent>> getAction() {
    return {
      BulletedListIntent: CallbackAction<BulletedListIntent>(
        onInvoke: (i) => i.onInvoke(),
      ),
    };
  }

  Map<LogicalKeySet, Intent> getShortCut() {
    return {
      LogicalKeySet(
        Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
        LogicalKeyboardKey.digit2,
      ): this,
    };
  }

  void onInvoke() {
    final selectionStyle = _controller.getSelectionStyle();
    final isSelectionUnorderedList =
        selectionStyle.values.any((a) => a == Attribute.ul);

    if (isSelectionUnorderedList) {
      _controller.formatSelection(Attribute.clone(Attribute.ul, null));
    } else {
      _controller.formatSelection(Attribute.ul);
    }
  }
}
