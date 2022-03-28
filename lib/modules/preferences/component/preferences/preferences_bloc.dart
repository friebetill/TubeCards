import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/reminder.dart';
import '../../../../data/models/user.dart';
import '../../../../data/preferences/preferences.dart';
import '../../../../data/preferences/reminders.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/picker/number_picker.dart';
import '../../../account/component/theme_dialog.dart';
import '../../../account_deletion/account_deletion_page.dart';
import '../../../reminder/reminders_page.dart';
import 'preferences_component.dart';
import 'preferences_view_model.dart';

/// BLoC for the [PreferencesComponent].
///
/// Exposes a [PreferencesViewModel] for that component to use.
@injectable
class PreferencesBloc with ComponentBuildContext {
  PreferencesBloc(this._userRepository, this._preferences, this._reminders);

  final UserRepository _userRepository;
  final Preferences _preferences;
  final Reminders _reminders;

  Stream<PreferencesViewModel>? _viewModel;
  Stream<PreferencesViewModel>? get viewModel => _viewModel;

  Stream<PreferencesViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest4(
      _userRepository.viewer(),
      _reminders.get(),
      _preferences.cardsPerSessionLimit,
      _preferences.cardsWithNoReviewDailyLimit,
      _createViewModel,
    );
  }

  PreferencesViewModel _createViewModel(
    User? user,
    List<Reminder> reminders,
    int cardsPerSessionLimit,
    int cardsWithNoReviewDailyLimit,
  ) {
    return PreferencesViewModel(
      isLoggedIn: user != null && !user.isAnonymous!,
      cardsPerSessionLimit: cardsPerSessionLimit,
      cardsWithNoReviewDailyLimit: cardsWithNoReviewDailyLimit,
      isCardLimitPerSessionActive: cardsPerSessionLimit != Preferences.offValue,
      isCardsWithNoReviewDailyLimitActive:
          cardsWithNoReviewDailyLimit != Preferences.offValue,
      activeReminderCount: reminders.where((r) => r.enabled!).length,
      onThemeTap: _handleThemeTap,
      handleNewCardsPerDayTap: () =>
          _onNewCardsPerDayCountEdit(cardsWithNoReviewDailyLimit),
      handleCardsPerSessionLimitTap: () =>
          _onCardsPerSessionLimitTap(cardsPerSessionLimit),
      onDeleteAccountTap: () => CustomNavigator.getInstance()
          .pushNamed(AccountDeletionPage.routeName),
      onReminderTap: () =>
          CustomNavigator.getInstance().pushNamed(RemindersPage.routeName),
    );
  }

  Future<void> _handleThemeTap(BuildContext context) async {
    await showDialog(context: context, builder: (_) => const ThemeDialog());
  }

  Future<void> _onCardsPerSessionLimitTap(int initialValue) async {
    final cardsPerSessionLimit = await showDialog<int>(
      context: context,
      builder: (context) => NumberPicker(
        title: S.of(context).cardsPerSessionLimit,
        explanation: S.of(context).cardsPerSessionLimitExplanation,
        initialValue: initialValue,
        hasOffOption: true,
      ),
    );

    if (cardsPerSessionLimit == null) {
      return;
    }
    await _preferences.cardsPerSessionLimit.setValue(cardsPerSessionLimit);
  }

  Future<void> _onNewCardsPerDayCountEdit(int initialValue) async {
    final editedNewCardsPerDayCount = await showDialog<int>(
      context: context,
      builder: (context) => NumberPicker(
        title: S.of(context).maxNewCardsPerDay,
        initialValue: initialValue,
        hasOffOption: true,
      ),
    );

    if (editedNewCardsPerDayCount == null) {
      return;
    }
    await _preferences.cardsWithNoReviewDailyLimit
        .setValue(editedNewCardsPerDayCount);
  }
}
