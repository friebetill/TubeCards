import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class UpsertIntent extends Intent {
  const UpsertIntent(this.onControlEnterTap);

  final VoidCallback onControlEnterTap;

  static Map<Type, Action<Intent>> getAction() {
    return {
      UpsertIntent: CallbackAction<UpsertIntent>(
        onInvoke: (i) => i.onInvoke(),
      ),
    };
  }

  Map<LogicalKeySet, Intent> getShortcut() {
    return {
      LogicalKeySet(
        Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
        LogicalKeyboardKey.enter,
      ): this,
    };
  }

  void onInvoke() => onControlEnterTap();
}
