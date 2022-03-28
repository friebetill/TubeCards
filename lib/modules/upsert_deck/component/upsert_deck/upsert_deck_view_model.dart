import 'package:flutter/foundation.dart';
import 'package:intl/locale.dart';

import '../../../../data/models/unsplash_image.dart';

class UpsertDeckViewModel {
  UpsertDeckViewModel({
    required this.name,
    required this.description,
    required this.isActive,
    required this.coverImage,
    required this.isBidirectionalDeck,
    required this.isEdit,
    required this.hasCardUpsertPermission,
    required this.showUpsertLoadingIndicator,
    required this.showLeaveLoadingIndicator,
    required this.showDeleteLoadingIndicator,
    required this.frontLocale,
    required this.backLocale,
    required this.onNameChanged,
    required this.onDescriptionChange,
    required this.onIsActiveChange,
    required this.onChangeImageTap,
    required this.onCreateMirrorCardChange,
    required this.onUpsertTap,
    required this.onBackTap,
    required this.onTtsLanguagesTap,
    required this.ttsLocales,
    required this.onDeleteTap,
    required this.onLeaveTap,
  });

  final String name;
  final String description;
  final bool isActive;
  final UnsplashImage coverImage;
  final bool isBidirectionalDeck;
  final bool isEdit;
  final bool hasCardUpsertPermission;
  final bool showUpsertLoadingIndicator;
  final bool showLeaveLoadingIndicator;
  final bool showDeleteLoadingIndicator;
  final Locale? frontLocale;
  final Locale? backLocale;
  final List<Locale> ttsLocales;

  final ValueChanged<String>? onNameChanged;
  final ValueChanged<String>? onDescriptionChange;
  final ValueChanged<bool> onIsActiveChange;
  final ValueChanged<UnsplashImage>? onChangeImageTap;
  final VoidCallback onUpsertTap;
  final VoidCallback onBackTap;
  final ValueChanged<bool>? onCreateMirrorCardChange;
  final VoidCallback? onTtsLanguagesTap;
  final VoidCallback? onLeaveTap;
  final VoidCallback? onDeleteTap;
}
