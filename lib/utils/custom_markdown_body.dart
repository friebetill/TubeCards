import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

/// Markdown widget which allows to set [maxLines], [softWrap] and [overflow].
class CustomMarkdownBody extends MarkdownWidget {
  const CustomMarkdownBody({
    required String data,
    bool selectable = false,
    MarkdownStyleSheet? styleSheet,
    MarkdownStyleSheetBaseTheme? styleSheetTheme,
    SyntaxHighlighter? syntaxHighlighter,
    MarkdownTapLinkCallback? onTapLink,
    VoidCallback? onTapText,
    String? imageDirectory,
    List<md.BlockSyntax>? blockSyntaxes,
    List<md.InlineSyntax>? inlineSyntaxes,
    md.ExtensionSet? extensionSet,
    MarkdownImageBuilder? imageBuilder,
    MarkdownCheckboxBuilder? checkboxBuilder,
    Map<String, MarkdownElementBuilder> builders = const {},
    MarkdownListItemCrossAxisAlignment listItemCrossAxisAlignment =
        MarkdownListItemCrossAxisAlignment.baseline,
    this.shrinkWrap = true,
    bool fitContent = true,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
    Key? key,
  }) : super(
          key: key,
          data: data,
          fitContent: fitContent,
          selectable: selectable,
          styleSheet: styleSheet,
          styleSheetTheme: styleSheetTheme,
          syntaxHighlighter: syntaxHighlighter,
          onTapLink: onTapLink,
          onTapText: onTapText,
          imageDirectory: imageDirectory,
          blockSyntaxes: blockSyntaxes,
          inlineSyntaxes: inlineSyntaxes,
          extensionSet: extensionSet,
          imageBuilder: imageBuilder,
          checkboxBuilder: checkboxBuilder,
          builders: builders,
          listItemCrossAxisAlignment: listItemCrossAxisAlignment,
        );

  final TextOverflow? overflow;
  final int? maxLines;
  final bool softWrap;

  /// See [ScrollView.shrinkWrap]
  final bool shrinkWrap;

  T? _findWidgetOfType<T>(Widget widget) {
    if (widget is T) {
      return widget as T;
    }

    if (widget is MultiChildRenderObjectWidget) {
      final multiChild = widget;
      for (final child in multiChild.children) {
        return _findWidgetOfType<T>(child);
      }
    } else if (widget is SingleChildRenderObjectWidget) {
      return _findWidgetOfType<T>(widget.child!);
    }

    return null;
  }

  @override
  Widget build(BuildContext context, List<Widget>? children) {
    final richText = _findWidgetOfType<RichText>(children!.first);
    if (richText != null) {
      return RichText(
        text: richText.text,
        textScaleFactor: richText.textScaleFactor,
        textAlign: richText.textAlign,
        maxLines: maxLines,
        overflow: overflow ?? TextOverflow.visible,
        softWrap: false,
      );
    }

    return children.first;
  }
}
