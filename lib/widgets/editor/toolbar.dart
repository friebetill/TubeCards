import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../i18n/i18n.dart';
import '../../utils/logging/visual_element_ids.dart';
import '../../utils/themes/custom_theme.dart';
import '../../utils/tooltip_message.dart';
import '../visual_element.dart';
import 'intents/draw_image_intent.dart';
import 'intents/horizontal_rule_intent.dart';
import 'intents/open_camera_intent.dart';
import 'intents/open_gallery_intent.dart';
import 'intents/pick_image_intent.dart';
import 'intents/search_image_intent.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({required this.controller, Key? key}) : super(key: key);

  final QuillController controller;

  static const double _iconSize = 24;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const toolbarElevation = 4.0;
    final backgroundColor = theme.custom.elevation4DPColor;

    final isDesktop =
        Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    final isMobile = Platform.isAndroid || Platform.isIOS;

    return Material(
      elevation: toolbarElevation,
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: QuillToolbar(
          color: backgroundColor,
          toolbarHeight: 56,
          multiRowsDisplay: isDesktop,
          children: [
            // Text buttons
            _buildBoldButton(context),
            _buildItalicButton(context),
            _buildDivider(context),
            // Paragraph buttons
            _buildNumberedListButton(context),
            _buildBulletedListButton(context),
            _buildCodeButton(context),
            _buildQuoteButton(context),
            _buildHorizontalRuleButton(context),
            _buildDivider(context),
            // Image buttons
            if (isMobile) _buildGalleryButton(context),
            if (isMobile) _buildCameraButton(context),
            if (isDesktop) _buildPickImageButton(context),
            _buildDrawImageButton(context),
            _buildSearchImageButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBoldButton(BuildContext context) {
    final tooltip = buildTooltipMessage(
      message: S.of(context).bold,
      windowsShortcut: 'Ctrl+b',
      macosShortcut: '⌘+b',
      linuxShortcut: 'Ctrl+b',
    );

    return _buildToggleButton(
      attribute: Attribute.bold,
      icon: Icons.format_bold_outlined,
      tooltipMessage: tooltip.toString(),
    );
  }

  Widget _buildItalicButton(BuildContext context) {
    final tooltip = buildTooltipMessage(
      message: S.of(context).italic,
      windowsShortcut: 'Ctrl+i',
      macosShortcut: '⌘+i',
      linuxShortcut: 'Ctrl+i',
    );

    return _buildToggleButton(
      attribute: Attribute.italic,
      icon: Icons.format_italic_outlined,
      tooltipMessage: tooltip.toString(),
    );
  }

  Widget _buildNumberedListButton(BuildContext context) {
    final tooltip = buildTooltipMessage(
      message: S.of(context).numberedList,
      // Enable the Windows shortcut when issue is fixed, https://bit.ly/385SPjh
      macosShortcut: '⌘+1',
      linuxShortcut: 'Ctrl+1',
    );

    return _buildToggleButton(
      attribute: Attribute.ol,
      icon: Icons.format_list_numbered_outlined,
      tooltipMessage: tooltip.toString(),
    );
  }

  Widget _buildBulletedListButton(BuildContext context) {
    final tooltip = buildTooltipMessage(
      message: S.of(context).bulletedList,
      // Enable the Windows shortcut when issue is fixed, https://bit.ly/385SPjh
      macosShortcut: '⌘+2',
      linuxShortcut: 'Ctrl+2',
    );

    return _buildToggleButton(
      attribute: Attribute.ul,
      icon: Icons.format_list_bulleted_outlined,
      tooltipMessage: tooltip.toString(),
    );
  }

  Widget _buildCodeButton(BuildContext context) {
    final tooltip = buildTooltipMessage(
      message: S.of(context).code,
      // Enable the Windows shortcut when issue is fixed, https://bit.ly/385SPjh
      macosShortcut: '⌘+3',
      linuxShortcut: 'Ctrl+3',
    );

    return _buildToggleButton(
      attribute: Attribute.codeBlock,
      icon: Icons.code_outlined,
      tooltipMessage: tooltip.toString(),
    );
  }

  Widget _buildQuoteButton(BuildContext context) {
    final tooltip = buildTooltipMessage(
      message: S.of(context).quote,
      // Enable the Windows shortcut when issue is fixed, https://bit.ly/385SPjh
      macosShortcut: '⌘+4',
      linuxShortcut: 'Ctrl+4',
    );

    return _buildToggleButton(
      attribute: Attribute.blockQuote,
      icon: Icons.format_quote_outlined,
      tooltipMessage: tooltip.toString(),
    );
  }

  Widget _buildGalleryButton(BuildContext context) {
    return _buildButton(
      context,
      icon: Icons.image_outlined,
      onPressed: () => const OpenGalleryIntent().onInvoke(
        context: context,
        controller: controller,
      ),
      tooltipMessage: S.of(context).gallery,
    );
  }

  Widget _buildCameraButton(BuildContext context) {
    return _buildButton(
      context,
      icon: Icons.photo_camera_outlined,
      onPressed: () => const OpenCameraIntent().onInvoke(
        context: context,
        controller: controller,
      ),
      tooltipMessage: S.of(context).camera,
    );
  }

  Widget _buildPickImageButton(BuildContext context) {
    final tooltip = buildTooltipMessage(
      message: S.of(context).pickImage,
      windowsShortcut: 'Ctrl+p',
      macosShortcut: '⌘+p',
      linuxShortcut: 'Ctrl+p',
    );

    return _buildButton(
      context,
      icon: Icons.image_outlined,
      onPressed: () => PickImageIntent(context, controller).onInvoke(),
      tooltipMessage: tooltip.toString(),
    );
  }

  Widget _buildDrawImageButton(BuildContext context) {
    final tooltip = buildTooltipMessage(
      message: S.of(context).drawImage,
      windowsShortcut: 'Ctrl+d',
      macosShortcut: '⌘+d',
      linuxShortcut: 'Ctrl+d',
    );

    return _buildButton(
      context,
      icon: Icons.brush_outlined,
      onPressed: () => DrawImageIntent(context, controller).onInvoke(),
      tooltipMessage: tooltip.toString(),
    );
  }

  Widget _buildSearchImageButton(BuildContext context) {
    final tooltip = buildTooltipMessage(
      message: S.of(context).searchImage,
      windowsShortcut: 'Ctrl+s',
      macosShortcut: '⌘+s',
      linuxShortcut: 'Ctrl+s',
    );

    return VisualElement(
      id: VEs.searchAzureImageButton,
      childBuilder: (controller) {
        return _buildButton(
          context,
          icon: Icons.image_search_outlined,
          onPressed: () {
            controller.logTap();
            SearchImageIntent(context, this.controller).onInvoke();
          },
          tooltipMessage: tooltip.toString(),
        );
      },
    );
  }

  Widget _buildHorizontalRuleButton(BuildContext context) {
    final tooltip = buildTooltipMessage(
      message: S.of(context).horizontalRule,
      windowsShortcut: 'Ctrl+r',
      macosShortcut: '⌘+r',
      linuxShortcut: 'Ctrl+r',
    );

    return _buildButton(
      context,
      icon: Icons.horizontal_rule,
      onPressed: () => HorizontalRuleIntent(controller).onInvoke(),
      tooltipMessage: tooltip.toString(),
    );
  }

  Widget _buildToggleButton({
    required Attribute attribute,
    required IconData icon,
    required String tooltipMessage,
  }) {
    Widget buttonBuilder(
      BuildContext context,
      Attribute attribute,
      IconData icon,
      Color? fillColor,
      // ignore: avoid_positional_boolean_parameters
      bool? isToggled,
      VoidCallback? onPressed,
      VoidCallback? afterPressed, [
      double iconSize = kDefaultIconSize,
      QuillIconTheme? iconTheme,
    ]) {
      final theme = Theme.of(context);

      // Disabled button
      if (onPressed == null) {
        return _buildButton(
          context,
          icon: icon,
          iconColor: theme.disabledColor,
          onPressed: () => {},
          tooltipMessage: tooltipMessage,
        );
      }

      // Inactive button
      if (isToggled == null || !isToggled) {
        return _buildButton(
          context,
          icon: icon,
          iconColor: theme.iconTheme.color!,
          onPressed: onPressed,
          tooltipMessage: tooltipMessage,
        );
      }

      // Active button
      return _buildButton(
        context,
        icon: icon,
        iconColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        onPressed: onPressed,
        tooltipMessage: tooltipMessage,
      );
    }

    return ToggleStyleButton(
      controller: controller,
      attribute: attribute,
      icon: icon,
      iconSize: _iconSize,
      childBuilder: buttonBuilder,
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltipMessage,
    Color? iconColor,
    Color? backgroundColor = Colors.transparent,
  }) {
    return Tooltip(
      message: tooltipMessage,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: QuillIconButton(
          highlightElevation: 0,
          hoverElevation: 0,
          icon: Icon(
            icon,
            size: _iconSize,
            color: iconColor ?? Theme.of(context).iconTheme.color,
          ),
          fillColor: backgroundColor,
          onPressed: onPressed,
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return VerticalDivider(
      color: Theme.of(context).colorScheme.onBackground,
      indent: 12,
      endIndent: 12,
      width: 8,
    );
  }
}
