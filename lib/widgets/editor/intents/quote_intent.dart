import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';

class QuoteIntent extends Intent {
  const QuoteIntent(this._controller);

  final QuillController _controller;

  static Map<Type, Action<Intent>> getAction() {
    return {
      QuoteIntent: CallbackAction<QuoteIntent>(
        onInvoke: (i) => i.onInvoke(),
      ),
    };
  }

  Map<LogicalKeySet, Intent> getShortCut() {
    return {
      LogicalKeySet(
        Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
        LogicalKeyboardKey.digit4,
      ): this,
    };
  }

  void onInvoke() {
    final selectionStyle = _controller.getSelectionStyle();
    final isSelectionQuote =
        selectionStyle.values.any((a) => a == Attribute.blockQuote);

    if (isSelectionQuote) {
      _controller.formatSelection(Attribute.clone(Attribute.blockQuote, null));
    } else {
      _controller.formatSelection(Attribute.blockQuote);
    }
  }
}
