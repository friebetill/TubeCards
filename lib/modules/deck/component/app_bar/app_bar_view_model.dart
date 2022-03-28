import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

class AppBarViewModel {
  AppBarViewModel({
    required this.deckName,
    required this.decksCount,
    required this.markedCardsIds,
    required this.showDeleteLoadingIndicator,
    required this.showPopupMenuLoadingIndicator,
    required this.hasEditDeckPermission,
    required this.hasEditCardPermission,
    required this.hasDeleteCardPermission,
    required this.onManageMembersTap,
    required this.onMoveTap,
    required this.onDeleteTap,
    required this.onSettingsTap,
    required this.onOfferTap,
    required this.onBackTap,
    required this.onWillPop,
  });

  final String deckName;
  final int decksCount;
  final BuiltList<String> markedCardsIds;
  final bool showDeleteLoadingIndicator;
  final bool showPopupMenuLoadingIndicator;
  final bool hasEditDeckPermission;
  final bool hasEditCardPermission;
  final bool hasDeleteCardPermission;

  final VoidCallback? onSettingsTap;
  final VoidCallback? onOfferTap;
  final VoidCallback onBackTap;
  final VoidCallback? onManageMembersTap;
  final VoidCallback onMoveTap;
  final VoidCallback onDeleteTap;
  final Future<bool> Function()? onWillPop;
}
