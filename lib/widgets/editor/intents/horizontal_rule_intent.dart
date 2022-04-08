import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';

class HorizontalRuleIntent extends Intent {
  const HorizontalRuleIntent(this.controller);

  final QuillController controller;

  static Map<Type, Action<Intent>> getAction() {
    return {
      HorizontalRuleIntent: CallbackAction<HorizontalRuleIntent>(
        onInvoke: (i) => i.onInvoke(),
      ),
    };
  }

  Map<LogicalKeySet, Intent> getShortCut() {
    return {
      LogicalKeySet(
        Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
        LogicalKeyboardKey.keyR,
      ): this,
    };
  }

  Future<void> onInvoke() async {
    final index = controller.selection.baseOffset;
    final length = controller.selection.extentOffset - index;

    controller.replaceText(
      index,
      length,
      const BlockEmbed('divider', 'hr'),
      null,
    );
  }
}
