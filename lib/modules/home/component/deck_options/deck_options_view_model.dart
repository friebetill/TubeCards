import 'package:flutter/foundation.dart';

class DeckOptionsViewModel {
  DeckOptionsViewModel({
    required this.deckName,
    required this.isActive,
    required this.hasDeletePermission,
    required this.showIsActiveLoadingIndicator,
    required this.showDeleteLoadingIndicator,
    required this.showLeaveLoadingIndicator,
    required this.onIsActiveTap,
    required this.onDeleteTap,
    required this.onLeaveTap,
  });

  final String deckName;
  final bool isActive;
  final bool showIsActiveLoadingIndicator;
  final bool showDeleteLoadingIndicator;
  final bool showLeaveLoadingIndicator;
  final bool hasDeletePermission;

  final VoidCallback onIsActiveTap;
  final VoidCallback onDeleteTap;
  final VoidCallback onLeaveTap;
}
