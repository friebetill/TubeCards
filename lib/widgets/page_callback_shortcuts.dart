import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../utils/custom_navigator.dart';

class PageCallbackShortcuts extends StatefulWidget {
  /// Constructs a [PageCallbackShortcuts] object.
  ///
  /// If [bindings] is not given, a default binding is used where pressing
  /// "ESC" pops the current route.
  PageCallbackShortcuts({
    required this.child,
    Map<ShortcutActivator, VoidCallback>? bindings,
    Key? key,
  })  : bindings = bindings ??
            <ShortcutActivator, VoidCallback>{
              LogicalKeySet(LogicalKeyboardKey.escape):
                  CustomNavigator.getInstance().pop,
            },
        super(key: key);

  final Map<ShortcutActivator, VoidCallback> bindings;
  final Widget child;

  @override
  State<PageCallbackShortcuts> createState() => _PageCallbackShortcutsState();
}

class _PageCallbackShortcutsState extends State<PageCallbackShortcuts> {
  @override
  Widget build(BuildContext context) {
    // Use FocusScope instead of Focus as quickfix for the UpsertCard page.
    // Otherwise there is the bug that if the TextField has focus and one clicks
    // on e.g. the TabBar the TextField loses focus.
    //
    // A clean solution would be to use FocusManager.instance.rootScope.onKey to
    // directly enable the KeyBindings, but there the bug exists.
    return FocusScope(
      autofocus: true,
      onKey: (node, event) {
        var result = KeyEventResult.ignored;
        for (final activator in widget.bindings.keys) {
          result = _applyKeyBinding(activator, event)
              ? KeyEventResult.handled
              : result;
        }

        return result;
      },
      child: widget.child,
    );
  }

  bool _applyKeyBinding(ShortcutActivator activator, RawKeyEvent event) {
    if (activator.accepts(event, RawKeyboard.instance)) {
      widget.bindings[activator]!.call();

      return true;
    }

    return false;
  }
}
