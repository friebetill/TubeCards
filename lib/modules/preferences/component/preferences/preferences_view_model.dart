import 'package:flutter/widgets.dart';

class PreferencesViewModel {
  PreferencesViewModel({
    required this.isLoggedIn,
    required this.isCardLimitPerSessionActive,
    required this.cardsPerSessionLimit,
    required this.isCardsWithNoReviewDailyLimitActive,
    required this.cardsWithNoReviewDailyLimit,
    required this.activeReminderCount,
    required this.onThemeTap,
    required this.onReminderTap,
    required this.onDeleteAccountTap,
    required this.handleCardsPerSessionLimitTap,
    required this.handleNewCardsPerDayTap,
  });
  final bool isLoggedIn;
  final bool isCardLimitPerSessionActive;
  final int cardsPerSessionLimit;
  final bool isCardsWithNoReviewDailyLimitActive;
  final int cardsWithNoReviewDailyLimit;
  final int activeReminderCount;

  final Future<void> Function(BuildContext context) onThemeTap;
  final VoidCallback handleNewCardsPerDayTap;
  final VoidCallback handleCardsPerSessionLimitTap;
  final VoidCallback onDeleteAccountTap;
  final VoidCallback onReminderTap;
}
