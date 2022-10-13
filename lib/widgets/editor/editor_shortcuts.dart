import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'intents/bold_intent.dart';
import 'intents/bulleted_list_intent.dart';
import 'intents/code_intent.dart';
import 'intents/draw_image_intent.dart';
import 'intents/horizontal_rule_intent.dart';
import 'intents/italic_intent.dart';
import 'intents/numbered_list_intent.dart';
import 'intents/pick_image_intent.dart';
import 'intents/quote_intent.dart';
import 'intents/search_image_intent.dart';
import 'intents/switch_card_side_intent.dart';
import 'intents/upsert_intent.dart';

/// Shortcuts for the [QuillEditor].
class EditorShortcuts extends StatelessWidget {
  const EditorShortcuts({
    required this.controller,
    required this.child,
    required this.onSwitchCardSideShortcut,
    required this.onUpsertShortcut,
    Key? key,
  }) : super(key: key);

  final QuillController controller;
  final Widget child;
  final VoidCallback? onSwitchCardSideShortcut;
  final VoidCallback? onUpsertShortcut;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        ..._formattingShortCuts(),
        ..._imageShortcuts(context),
        // Disables the arrow keys which traverse the focus tree.
        ..._disabledNavigationKeys(),
        if (onSwitchCardSideShortcut != null)
          ...SwitchCardSideIntent(onSwitchCardSideShortcut!).getShortcut(),
        if (onUpsertShortcut != null)
          ...UpsertIntent(onUpsertShortcut!).getShortcut(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ...BoldIntent.getAction(),
          ...ItalicIntent.getAction(),
          ...NumberedListIntent.getAction(),
          ...BulletedListIntent.getAction(),
          ...CodeIntent.getAction(),
          ...QuoteIntent.getAction(),
          ...SwitchCardSideIntent.getAction(),
          ...PickImageIntent.getAction(),
          ...DrawImageIntent.getAction(),
          ...SearchImageIntent.getAction(),
          ...HorizontalRuleIntent.getAction(),
          ...UpsertIntent.getAction(),
        },
        child: child,
      ),
    );
  }

  Map<LogicalKeySet, Intent> _formattingShortCuts() {
    return {
      ...BoldIntent(controller).getShortCut(),
      ...ItalicIntent(controller).getShortCut(),
      ...NumberedListIntent(controller).getShortCut(),
      ...BulletedListIntent(controller).getShortCut(),
      ...CodeIntent(controller).getShortCut(),
      ...QuoteIntent(controller).getShortCut(),
      ...HorizontalRuleIntent(controller).getShortCut(),
    };
  }

  Map<LogicalKeySet, Intent> _imageShortcuts(BuildContext context) {
    return {
      ...PickImageIntent(context, controller).getShortCut(),
      ...DrawImageIntent(context, controller).getShortCut(),
      ...SearchImageIntent(context, controller).getShortCut(),
    };
  }

  Map<LogicalKeySet, Intent> _disabledNavigationKeys() {
    return <LogicalKeySet, Intent>{
      LogicalKeySet(LogicalKeyboardKey.arrowUp): const DoNothingIntent(),
      LogicalKeySet(LogicalKeyboardKey.arrowDown): const DoNothingIntent(),
      LogicalKeySet(LogicalKeyboardKey.arrowLeft): const DoNothingIntent(),
      LogicalKeySet(LogicalKeyboardKey.arrowRight): const DoNothingIntent(),
    };
  }
}
