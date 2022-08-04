import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/preferences/user_history.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import '../../../../widgets/picker/color_picker.dart';
import '../../../../widgets/picker/draw_size_picker.dart';
import '../../../../widgets/picker/text_size_picker.dart';
import '../discard_dialog.dart';
import 'draw_image_view_model.dart';

@injectable
class DrawImageBloc with ComponentBuildContext, ComponentLifecycleListener {
  DrawImageBloc(this._userHistory);

  final UserHistory _userHistory;

  final _logger = Logger((DrawImageBloc).toString());

  Stream<DrawImageViewModel>? _viewModel;
  Stream<DrawImageViewModel>? get viewModel => _viewModel;

  final _controller = PainterController();
  late FocusNode _textFocusNode;

  final _backgroundImage = BehaviorSubject<ui.Image?>();
  final _mode = BehaviorSubject<PainterMode>.seeded(PainterMode.draw);
  final _isSaving = BehaviorSubject<bool>.seeded(false);
  final _shapesFilled = BehaviorSubject<bool>.seeded(false);

  Stream<DrawImageViewModel> createViewModel(String? imageUrl) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    _textFocusNode = FocusNode();

    if (imageUrl != null) {
      GetIt.I
          .get<BaseCacheManager>()
          .getFileFromCache(imageUrl)
          .then((f) => _handleImageLoad(f, imageUrl));
    } else {
      _controller.background = Colors.white.backgroundDrawable;
      _backgroundImage.add(null);
    }

    return _viewModel = Rx.combineLatest9(
      _mode,
      _backgroundImage,
      _userHistory.brushSize,
      _userHistory.textSize,
      _userHistory.recentTextColors,
      _userHistory.recentShapeColors,
      _userHistory.shapeStrokeSize,
      _shapesFilled,
      _isSaving,
      _createViewModel,
    );
  }

  DrawImageViewModel _createViewModel(
    PainterMode mode,
    ui.Image? backgroundImage,
    double brushSize,
    double textSize,
    List<Color> textColors,
    List<Color> shapeColors,
    double shapeStrokeSize,
    bool shapesFilled,
    bool isSaving,
  ) {
    _controller.settings = _controller.settings.copyWith(
      freeStyle: FreeStyleSettings(
        mode:
            mode == PainterMode.draw ? FreeStyleMode.draw : FreeStyleMode.none,
        color: _userHistory.recentBrushColors.getValue().first,
        strokeWidth: brushSize,
      ),
      text: TextSettings(
        focusNode: _textFocusNode,
        textStyle: TextStyle(
          color: textColors.first,
          fontSize: textSize,
        ),
      ),
      shape: _controller.shapeSettings.copyWith(
        drawOnce: false,
        paint: Paint()
          ..color = shapeColors.first
          ..style = shapesFilled ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = shapeStrokeSize,
      ),
    );

    return DrawImageViewModel(
      mode: mode,
      controller: _controller,
      isEdit: backgroundImage != null,
      isSaving: isSaving,
      shapesFilled: shapesFilled,
      backgroundImage: backgroundImage,
      onDrawTap: _handleDrawTap,
      onPickBrushColorTap: _handlePickBrushColorTap,
      onPickBrushSizeTap: () => _handlePickBrushSizeTap(brushSize),
      onPickTextSizeTap: () => _handlePickTextSizeTap(textSize),
      onPickTextColorTap: () => _handlePickTextColorTap(textColors),
      onPickShapeColorTap: () => _handlePickShapeColorTap(shapeColors),
      onPickShapeSizeTap: () => _handlePickShapeStrokeSizeTap(shapeStrokeSize),
      onTextTap: _handleTextTap,
      onLineTap: _handleLineTap,
      onArrowTap: _handleArrowTap,
      onRectangleTap: _handleRectangleTap,
      onCircleTap: _handleCircleTap,
      onFillShapeTap: () => _handleFillShapeTap(shapesFilled),
      onUndoTap: _handleUndoTap,
      onClearTap: _handleClearTap,
      onEscapePress: _handleEscapePress,
      saveImage: _saveImage,
      onClose: _handleClose,
    );
  }

  @override
  void dispose() {
    _backgroundImage.close();
    _mode.close();
    _isSaving.close();
    super.dispose();
  }

  Future<void> _handleImageLoad(FileInfo? fileInfo, String imageUrl) async {
    if (fileInfo == null) {
      _logger.severe(
        "Opening the image with url $imageUrl for drawing didn't work.",
        null,
        StackTrace.current,
      );

      ScaffoldMessenger.of(context).showErrorSnackBar(
        theme: Theme.of(context),
        text: S.of(context).errorUnknownText,
      );

      return CustomNavigator.getInstance().pop();
    }

    final imageBytes = fileInfo.file.readAsBytesSync();
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frameInfo = await codec.getNextFrame();

    _controller.background = ImageBackgroundDrawable(image: frameInfo.image);
    _backgroundImage.add(frameInfo.image);
  }

  Future<void> _saveImage(Size canvasSize) async {
    if (_controller.drawables.isEmpty) {
      return CustomNavigator.getInstance().pop();
    }

    _isSaving.add(true);

    final size = _backgroundImage.value != null
        ? Size(
            _backgroundImage.value!.width.toDouble(),
            _backgroundImage.value!.height.toDouble(),
          )
        : canvasSize;
    final renderedImage = await _controller.renderImage(size);
    final pngBytes = await renderedImage.pngBytes;

    _isSaving.add(false);
    CustomNavigator.getInstance().pop(pngBytes);
  }

  Future<void> _handleClose() async {
    if (_controller.drawables.isEmpty) {
      return CustomNavigator.getInstance().pop();
    }

    final shouldDiscardImage = await showDialog<bool>(
      context: context,
      builder: (_) => DiscardDialog(isEdit: _backgroundImage.value != null),
    );
    if (shouldDiscardImage != null && shouldDiscardImage) {
      CustomNavigator.getInstance().pop();
    }
  }

  Future<void> _handlePickBrushColorTap() async {
    final newColor = await showDialog<Color>(
      context: context,
      builder: (context) => ColorPicker(
        initialColor: _userHistory.recentBrushColors.getValue().first,
        suggestionColors: _userHistory.recentBrushColors.getValue(),
      ),
    );

    if (newColor == null) {
      return;
    }
    _userHistory.addRecentBrushColor(newColor);
    _controller.freeStyleSettings = _controller.freeStyleSettings.copyWith(
      color: newColor,
    );
  }

  Future<void> _handlePickTextColorTap(List<Color> colors) async {
    final newColor = await showDialog<Color>(
      context: context,
      builder: (context) => ColorPicker(
        initialColor: colors.first,
        suggestionColors: colors,
      ),
    );

    if (newColor == null) {
      return;
    }
    _userHistory.addRecentTextColor(newColor);
  }

  Future<void> _handlePickShapeColorTap(List<Color> shapeColors) async {
    final newColor = await showDialog<Color>(
      context: context,
      builder: (context) => ColorPicker(
        initialColor: _userHistory.recentShapeColors.getValue().first,
        suggestionColors: _userHistory.recentShapeColors.getValue(),
      ),
    );

    if (newColor == null) {
      return;
    }
    _userHistory.addRecentShapeColor(newColor);
  }

  Future<void> _handlePickShapeStrokeSizeTap(double size) async {
    final newSize = await showDialog<double>(
        context: context,
        builder: (context) => DrawSizePicker(
              initialSize: size,
            ));
    if (newSize == null) {
      return;
    }
    await _userHistory.shapeStrokeSize.setValue(newSize);
  }

  Future<void> _handlePickBrushSizeTap(double size) async {
    final newSize = await showDialog<double>(
      context: context,
      builder: (context) => DrawSizePicker(initialSize: size),
    );
    if (newSize == null) {
      return;
    }
    await _userHistory.brushSize.setValue(newSize);
  }

  Future<void> _handlePickTextSizeTap(double size) async {
    final newSize = await showDialog<double>(
      context: context,
      builder: (context) => TextSizePicker(initialSize: size),
    );
    if (newSize == null) {
      return;
    }
    await _userHistory.textSize.setValue(newSize);
  }

  void _handleDrawTap() {
    _mode.add(PainterMode.draw);
    _controller.shapeSettings = const ShapeSettings();
  }

  void _handleTextTap() {
    _controller.addText();
    _mode.add(PainterMode.text);
    _controller.shapeSettings = const ShapeSettings();
  }

  void _handleLineTap() {
    _mode.add(PainterMode.line);
    _controller.shapeSettings = ShapeSettings(
      factory: LineFactory(),
    );
  }

  void _handleArrowTap() {
    _mode.add(PainterMode.arrow);
    _controller.shapeSettings = ShapeSettings(
      factory: ArrowFactory(),
    );
  }

  void _handleRectangleTap() {
    _mode.add(PainterMode.rectangle);
    _controller.shapeSettings = ShapeSettings(
      factory: RectangleFactory(),
    );
  }

  void _handleCircleTap() {
    _mode.add(PainterMode.circle);
    _controller.shapeSettings = ShapeSettings(
      factory: OvalFactory(),
    );
  }

  void _handleFillShapeTap(bool currentValue) {
    _shapesFilled.add(!currentValue);
  }

  void _handleUndoTap() => _controller.removeLastDrawable();

  void _handleClearTap() => _controller.clearDrawables();

  void _handleEscapePress() {
    if (_textFocusNode.hasFocus) {
      _textFocusNode.unfocus();
    } else {
      _handleClose();
    }
  }
}
