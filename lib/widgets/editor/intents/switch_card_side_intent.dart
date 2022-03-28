import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class SwitchCardSideIntent extends Intent {
  const SwitchCardSideIntent(this.onTapTap);

  final VoidCallback onTapTap;

  static Map<Type, Action<Intent>> getAction() {
    return {
      SwitchCardSideIntent: CallbackAction<SwitchCardSideIntent>(
        onInvoke: (i) => i.onInvoke(),
      ),
    };
  }

  Map<LogicalKeySet, Intent> getShortcut() {
    return {LogicalKeySet(LogicalKeyboardKey.tab): this};
  }

  void onInvoke() => onTapTap();
}
