import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:quiver/core.dart';

class UpsertCardViewModel {
  UpsertCardViewModel({
    required this.frontController,
    required this.backController,
    required this.backTranslation,
    required this.frontTranslation,
    required this.forcedActiveCardSide,
    required this.isEdit,
    required this.isMirrorCard,
    required this.hasEditPermission,
    required this.isLoading,
    required this.onUpsertTap,
    required this.onMoveTap,
    required this.onDeleteTap,
  });

  final QuillController frontController;
  final QuillController backController;
  final String? backTranslation;
  final String? frontTranslation;
  final Optional<CardSide> forcedActiveCardSide;
  final bool isEdit;
  final bool isMirrorCard;
  final bool hasEditPermission;
  final bool isLoading;

  final VoidCallback? onUpsertTap;
  final VoidCallback? onMoveTap;
  final VoidCallback? onDeleteTap;
}

enum CardSide {
  /// Front side of a card, implicit index of 0.
  front,

  /// Back side of a card, implicit index of 1.
  back,
}
