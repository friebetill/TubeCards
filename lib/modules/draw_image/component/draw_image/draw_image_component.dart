import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/icon_sized_loading_indicator.dart';
import '../../../../utils/themes/custom_theme.dart';
import '../../../../utils/tooltip_message.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/page_callback_shortcuts.dart';
import '../../../../widgets/simple_skeleton.dart';
import '../toolbar_icon_button.dart';
import '../toolbar_toggle_button.dart';
import 'draw_image_bloc.dart';
import 'draw_image_view_model.dart';

class DrawImageComponent extends StatelessWidget {
  const DrawImageComponent(this._imageUrl, {Key? key}) : super(key: key);

  final String? _imageUrl;

  @override
  Widget build(BuildContext context) {
    return Component<DrawImageBloc>(
      createViewModel: (bloc) => bloc.createViewModel(_imageUrl),
      builder: (context, bloc) {
        return StreamBuilder<DrawImageViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SimpleSkeleton();
            }

            return _DrawImageView(snapshot.data!);
          },
        );
      },
    );
  }
}

class _DrawImageView extends StatefulWidget {
  const _DrawImageView(this.viewModel);

  final DrawImageViewModel viewModel;

  @override
  State<_DrawImageView> createState() => _DrawImageViewState();
}

class _DrawImageViewState extends State<_DrawImageView> {
  late Size _canvasSize;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleWillPop,
      child: PageCallbackShortcuts(
        bindings: {
          LogicalKeySet(LogicalKeyboardKey.escape):
              widget.viewModel.onEscapePress,
          LogicalKeySet(
            Platform.isMacOS
                ? LogicalKeyboardKey.meta
                : LogicalKeyboardKey.control,
            LogicalKeyboardKey.enter,
          ): () => widget.viewModel.saveImage(_canvasSize),
        },
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: Column(
            children: <Widget>[
              Expanded(child: _buildCanvas(context)),
              _buildToolbar(context),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _handleWillPop() async {
    widget.viewModel.onClose();

    return false;
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        widget.viewModel.isEdit
            ? S.of(context).editDrawing
            : S.of(context).addDrawing,
      ),
      elevation: 4,
      leading: IconButton(
        icon: const Icon(Icons.close_outlined),
        onPressed: widget.viewModel.onClose,
        tooltip: closeTooltip(context),
      ),
      actions: <Widget>[
        IconButton(
          icon: widget.viewModel.isSaving
              ? const IconSizedLoadingIndicator()
              : const Icon(Icons.check_outlined),
          tooltip: saveTooltip(context),
          color: Theme.of(context).colorScheme.primary,
          onPressed: () => widget.viewModel.saveImage(_canvasSize),
        ),
      ],
    );
  }

  Widget _buildCanvas(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.005,
      maxScale: 4,
      panEnabled: false,
      child: Center(
        child: LayoutBuilder(builder: (context, constraints) {
          // Always set the canvas size, as it changes on some devices after
          // the first build.
          _canvasSize = widget.viewModel.backgroundImage != null
              ? Size(
                  widget.viewModel.backgroundImage!.width.toDouble(),
                  widget.viewModel.backgroundImage!.height.toDouble(),
                )
              : constraints.biggest;

          return AspectRatio(
            aspectRatio: _canvasSize.width / _canvasSize.height,
            child: FlutterPainter(controller: widget.viewModel.controller),
          );
        }),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Material(
      elevation: 4,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: SizedBox(
          height: 48,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              const SizedBox(width: 8),
              _buildDrawButton(context),
              _buildTextButton(context),
              if (Platform.isLinux || Platform.isWindows || Platform.isMacOS)
                const VerticalDivider(indent: 8, endIndent: 8),
              ..._buildShapeButtons(context),
              const VerticalDivider(indent: 8, endIndent: 8),
              if (widget.viewModel.mode == PainterMode.draw)
                _buildBrushColorButton(context)
              else if (widget.viewModel.mode == PainterMode.text)
                _buildTextColorButton(context)
              else
                _buildShapeColorButton(context),
              if (widget.viewModel.mode == PainterMode.draw)
                _buildPickBrushSizeButton(context)
              else if (widget.viewModel.mode == PainterMode.text)
                _buildPickTextSizeButton(context)
              else if (widget.viewModel.shapesFilled &&
                  (widget.viewModel.mode == PainterMode.rectangle ||
                      widget.viewModel.mode == PainterMode.circle))
                const SizedBox(width: 42)
              else
                _buildPickShapeSizeButton(context),
              if (widget.viewModel.mode == PainterMode.rectangle)
                _buildFillRectangleButton(context)
              else if (widget.viewModel.mode == PainterMode.circle)
                _buildFillCircleButton(context)
              else
                const SizedBox(width: 42),
              const VerticalDivider(indent: 8, endIndent: 8),
              _buildUndoButton(context),
              _buildClearButton(context),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawButton(BuildContext context) {
    return ToolbarToggleButton(
      icon: Icons.brush_outlined,
      isToggled: widget.viewModel.mode == PainterMode.draw,
      onTap: widget.viewModel.onDrawTap,
      tooltip: S.of(context).draw,
    );
  }

  Widget _buildTextButton(BuildContext context) {
    return ToolbarToggleButton(
      icon: Icons.title_outlined,
      isToggled: widget.viewModel.mode == PainterMode.text,
      onTap: widget.viewModel.onTextTap,
      tooltip: S.of(context).text,
    );
  }

  List<Widget> _buildShapeButtons(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) {
      return <Widget>[
        // We use
        // - SizedBox to limit the background size of the PopMenuButton
        // - Material is necessary for InkWell and colors the background color
        // - InkWell to limit the splash animation to the size of SizedBox
        SizedBox(
          width: 42,
          height: 42,
          child: Material(
            color: _getBackgroundColor(),
            child: InkWell(
              child: PopupMenuButton(
                icon: _getPopMenuIcon(),
                tooltip: S.of(context).selectShape,
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      onTap: widget.viewModel.onLineTap,
                      child: Row(
                        children: [
                          const Icon(PhosphorIcons.line_segment),
                          const SizedBox(width: 10),
                          Text(S.of(context).line)
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: widget.viewModel.onArrowTap,
                      child: Row(
                        children: [
                          const Icon(PhosphorIcons.arrow_up_right),
                          const SizedBox(width: 10),
                          Text(S.of(context).arrow)
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: widget.viewModel.onRectangleTap,
                      child: Row(
                        children: [
                          const Icon(PhosphorIcons.rectangle),
                          const SizedBox(width: 10),
                          Text(S.of(context).rectangle)
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: widget.viewModel.onCircleTap,
                      child: Row(
                        children: [
                          const Icon(PhosphorIcons.circle),
                          const SizedBox(width: 10),
                          Text(S.of(context).circle)
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ),
          ),
        ),
      ];
    } else {
      return <Widget>[
        ToolbarToggleButton(
          icon: PhosphorIcons.line_segment,
          isToggled: widget.viewModel.mode == PainterMode.line,
          onTap: widget.viewModel.onLineTap,
          tooltip: S.of(context).line,
        ),
        ToolbarToggleButton(
          icon: PhosphorIcons.arrow_up_right,
          isToggled: widget.viewModel.mode == PainterMode.arrow,
          onTap: widget.viewModel.onArrowTap,
          tooltip: S.of(context).arrow,
        ),
        ToolbarToggleButton(
          icon: PhosphorIcons.rectangle,
          isToggled: widget.viewModel.mode == PainterMode.rectangle,
          onTap: widget.viewModel.onRectangleTap,
          tooltip: S.of(context).rectangle,
        ),
        ToolbarToggleButton(
          icon: PhosphorIcons.circle,
          isToggled: widget.viewModel.mode == PainterMode.circle,
          onTap: widget.viewModel.onCircleTap,
          tooltip: S.of(context).circle,
        ),
      ];
    }
  }

  Color _getBackgroundColor() {
    final activeBackgroundColor =
        Theme.of(context).brightness == Brightness.light
            ? const Color(0xFFF4F8FE)
            : const Color(0xFF343D52);
    final inactiveBackgroundColor = Theme.of(context).custom.elevation4DPColor;

    if (widget.viewModel.mode == PainterMode.line ||
        widget.viewModel.mode == PainterMode.arrow ||
        widget.viewModel.mode == PainterMode.rectangle ||
        widget.viewModel.mode == PainterMode.circle) {
      return activeBackgroundColor;
    } else {
      return inactiveBackgroundColor;
    }
  }

  Icon _getPopMenuIcon() {
    final color = Theme.of(context).brightness == Brightness.light
        ? Colors.blue.shade700
        : Colors.blue.shade100;
    switch (widget.viewModel.mode) {
      case PainterMode.line:
        return Icon(PhosphorIcons.line_segment, color: color);
      case PainterMode.arrow:
        return Icon(PhosphorIcons.arrow_up_right, color: color);
      case PainterMode.rectangle:
        return Icon(PhosphorIcons.rectangle, color: color);
      case PainterMode.circle:
        return Icon(PhosphorIcons.circle, color: color);
      default:
        return Icon(PhosphorIcons.line_segment, color: color);
    }
  }

  Widget _buildBrushColorButton(BuildContext context) {
    return ToolbarIconButton(
      icon: Icons.palette_outlined,
      onTap: widget.viewModel.onPickBrushColorTap,
      tooltip: S.of(context).pickBrushColor,
    );
  }

  Widget _buildPickBrushSizeButton(BuildContext context) {
    return ToolbarIconButton(
      icon: Icons.line_weight,
      onTap: widget.viewModel.onPickBrushSizeTap,
      tooltip: S.of(context).pickBrushWidth,
    );
  }

  Widget _buildTextColorButton(BuildContext context) {
    return ToolbarIconButton(
      icon: Icons.palette_outlined,
      onTap: widget.viewModel.onPickTextColorTap,
      tooltip: S.of(context).pickTextColor,
    );
  }

  Widget _buildPickTextSizeButton(BuildContext context) {
    return ToolbarIconButton(
      icon: Icons.format_size_outlined,
      onTap: widget.viewModel.onPickTextSizeTap,
      tooltip: S.of(context).pickTextSize,
    );
  }

  Widget _buildShapeColorButton(BuildContext context) {
    return ToolbarIconButton(
      icon: Icons.palette_outlined,
      onTap: widget.viewModel.onPickShapeColorTap,
      tooltip: S.of(context).pickShapeColor,
    );
  }

  Widget _buildPickShapeSizeButton(BuildContext context) {
    return ToolbarIconButton(
      icon: Icons.line_weight,
      onTap: widget.viewModel.onPickShapeSizeTap,
      tooltip: S.of(context).selectShapeWidth,
    );
  }

  Widget _buildFillRectangleButton(BuildContext context) {
    return ToolbarIconButton(
      icon: widget.viewModel.shapesFilled
          ? PhosphorIcons.rectangle_fill
          : PhosphorIcons.rectangle_thin,
      onTap: widget.viewModel.onFillShapeTap,
      tooltip: S.of(context).fillRectangle,
    );
  }

  Widget _buildFillCircleButton(BuildContext context) {
    return ToolbarIconButton(
      icon: widget.viewModel.shapesFilled
          ? PhosphorIcons.circle_fill
          : PhosphorIcons.circle_thin,
      onTap: widget.viewModel.onFillShapeTap,
      tooltip: S.of(context).fillCircle,
    );
  }

  Widget _buildUndoButton(BuildContext context) {
    return ToolbarIconButton(
      icon: Icons.undo_outlined,
      onTap: widget.viewModel.onUndoTap,
      tooltip: S.of(context).undoLastAction,
    );
  }

  Widget _buildClearButton(BuildContext context) {
    return ToolbarIconButton(
      icon: Icons.clear_outlined,
      onTap: widget.viewModel.onClearTap,
      tooltip: S.of(context).clearCanvas,
    );
  }
}
