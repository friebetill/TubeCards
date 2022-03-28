import 'package:flutter/foundation.dart';

class DeckViewModel {
  DeckViewModel({
    required this.id,
    required this.hasCards,
    required this.strength,
    required this.totalDueCardsCount,
    required this.totalCardsCount,
    required this.hasCardUpsertPermission,
    required this.onEditTap,
    required this.onBackTap,
    required this.onManageMembersTap,
    required this.onLearnTap,
    required this.onPracticeTap,
  });

  final String id;
  final bool hasCards;
  final double strength;
  final int totalDueCardsCount;
  final int totalCardsCount;
  final bool hasCardUpsertPermission;

  final VoidCallback onEditTap;
  final VoidCallback onBackTap;
  final VoidCallback? onManageMembersTap;
  final VoidCallback? onLearnTap;
  final VoidCallback? onPracticeTap;
}
