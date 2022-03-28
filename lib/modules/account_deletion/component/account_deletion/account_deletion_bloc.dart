import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/preferences/preferences.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../graphql/operation_exception.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import '../../../deck/component/delete_dialog.dart';
import '../../../landing/landing_page.dart';
import 'account_deletion_component.dart';
import 'account_deletion_view_model.dart';

/// BLoC for the [AccountDeletionComponent].
@injectable
class AccountDeletionBloc
    with ComponentBuildContext, ComponentLifecycleListener {
  AccountDeletionBloc(this._userRepository, this._preferences);

  final UserRepository _userRepository;
  final Preferences _preferences;

  Stream<AccountDeletionViewModel>? _viewModel;
  Stream<AccountDeletionViewModel>? get viewModel => _viewModel;

  late BehaviorSubject<bool> _isDeleting;

  Stream<AccountDeletionViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    _isDeleting = BehaviorSubject.seeded(false);

    return _viewModel = _isDeleting.map((isDeleting) {
      return AccountDeletionViewModel(
        isDeleting: isDeleting,
        onDeleteAccountTap: _onDeleteAccountTap,
        onKeepAccountTap: CustomNavigator.getInstance().pop,
      );
    });
  }

  @override
  void dispose() {
    _isDeleting.close();
    super.dispose();
  }

  Future<void> _onDeleteAccountTap() async {
    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    final isUserSure = await showDialog<bool?>(
      context: context,
      builder: (context) => DeleteDialog(
        title: S.of(context).deleteAccount,
        content: S.of(context).areYouSureText,
      ),
    );
    if (isUserSure == null || !isUserSure) {
      return;
    }

    _isDeleting.add(true);
    try {
      await _userRepository.deleteCurrentUser();
    } on OperationException catch (e) {
      if (e.linkException != null) {
        return messenger.showErrorSnackBar(
          theme: theme,
          text: i18n.errorNoInternetText,
        );
      }
      _isDeleting.add(false);

      return messenger.showErrorSnackBar(
        theme: theme,
        text: i18n.errorSendEmailText,
      );
    }
    await _userRepository.clear();
    await _preferences.clear();

    await CustomNavigator.getInstance()
        .pushNamedAndRemoveUntil(LandingPage.routeName, (_) => false);
    _isDeleting.add(false);
  }
}
