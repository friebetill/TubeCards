import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_painter/flutter_painter.dart';

class DrawImageViewModel {
  const DrawImageViewModel({
    required this.mode,
    required this.controller,
    required this.isEdit,
    required this.backgroundImage,
    required this.shapesFilled,
    required this.isSaving,
    required this.onDrawTap,
    required this.onPickBrushColorTap,
    required this.onPickBrushSizeTap,
    required this.onPickTextSizeTap,
    required this.onPickTextColorTap,
    required this.onPickShapeColorTap,
    required this.onPickShapeSizeTap,
    required this.onTextTap,
    required this.onLineTap,
    required this.onArrowTap,
    required this.onRectangleTap,
    required this.onCircleTap,
    required this.onFillShapeTap,
    required this.onClearTap,
    required this.onEscapePress,
    required this.onUndoTap,
    required this.onClose,
    required this.saveImage,
  });

  final PainterMode mode;
  final PainterController controller;
  final bool isEdit;
  final Image? backgroundImage;
  final bool shapesFilled;
  final bool isSaving;

  final VoidCallback onDrawTap;
  final VoidCallback onPickBrushColorTap;
  final VoidCallback onPickBrushSizeTap;
  final VoidCallback onPickTextSizeTap;
  final VoidCallback onPickTextColorTap;
  final VoidCallback onPickShapeColorTap;
  final VoidCallback onPickShapeSizeTap;

  final VoidCallback onTextTap;
  final VoidCallback onLineTap;
  final VoidCallback onArrowTap;
  final VoidCallback onRectangleTap;
  final VoidCallback onCircleTap;

  final VoidCallback onFillShapeTap;

  final VoidCallback onClearTap;
  final VoidCallback? onUndoTap;
  final VoidCallback onEscapePress;
  final VoidCallback onClose;
  final ValueSetter<Size> saveImage;
}

enum PainterMode {
  draw,
  text,
  line,
  arrow,
  rectangle,
  circle,
}
