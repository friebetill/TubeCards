import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/repositories/user_repository.dart';
import '../../../../graphql/operation_exception.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import '../../../check_email_page/check_email_page.dart';
import 'reset_password_form_component.dart';
import 'reset_password_form_view_model.dart';

/// BLoC for the [ResetPasswordFormComponent].
///
/// Exposes a [ResetPasswordFormViewModel] for that component to use.
@injectable
class ResetPasswordFormBloc
    with ComponentBuildContext, ComponentLifecycleListener {
  ResetPasswordFormBloc(this._userRepository);

  final UserRepository _userRepository;

  final _logger = Logger((ResetPasswordFormBloc).toString());

  /// Whether the form should auto-validate the input on changes.
  ///
  /// This will be enabled once the form has been submitted for the first time.
  bool _autoValidate = false;
  String _email = '';

  final _isLoading = BehaviorSubject.seeded(false);
  final _emailErrorText = BehaviorSubject<String?>.seeded(null);

  Stream<ResetPasswordFormViewModel>? _viewModel;
  Stream<ResetPasswordFormViewModel>? get viewModel => _viewModel;

  Stream<ResetPasswordFormViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest2(
      _isLoading,
      _emailErrorText,
      _createViewModel,
    );
  }

  ResetPasswordFormViewModel _createViewModel(
    bool isLoading,
    String? emailErrorText,
  ) {
    return ResetPasswordFormViewModel(
      isLoading: isLoading,
      emailErrorText: emailErrorText,
      onEmailChange: _handleEmailChange,
      onSendInstructionsTap: _handleSendInstructionsTap,
    );
  }

  @override
  void dispose() {
    _isLoading.close();
    _emailErrorText.close();
    super.dispose();
  }

  void _handleEmailChange(String email) {
    _email = email.trim();

    if (_autoValidate) {
      _emailErrorText.add(_validateEmail());
    }
  }

  String? _validateEmail() {
    if (_email.isEmpty) {
      return S.of(context).enterYourEmail;
    } else if (!EmailValidator.validate(_email)) {
      return S.of(context).enterValidEmailText;
    }

    return null;
  }

  Future<void> _handleSendInstructionsTap() async {
    // Auto-validate as soon as the first submit is in.
    _autoValidate = true;
    if (_hasAnyFieldValidationError()) {
      return;
    }

    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    _isLoading.add(true);
    try {
      await _userRepository.triggerPasswordReset(_email);
      unawaited(CustomNavigator.getInstance().pushReplacementNamed(
        CheckEmailPage.routeName,
        args: _email,
      ));
    } on OperationException catch (e, s) {
      var exceptionText = i18n.errorUnknownText;
      if (e.isNoInternet) {
        exceptionText = i18n.errorNoInternetText;
      } else if (e.isServerOffline) {
        exceptionText = i18n.errorWeWillFixText;
      } else {
        _logger.severe(
          'Operation exception during trigger password reset',
          e,
          s,
        );
      }

      messenger.showErrorSnackBar(theme: theme, text: exceptionText);
    } on TimeoutException {
      messenger.showErrorSnackBar(theme: theme, text: i18n.errorUnknownText);
    } on Exception catch (e, s) {
      _logger.severe(
        'Unexpected exception during trigger password reset',
        e,
        s,
      );
      ScaffoldMessenger.of(context).showErrorSnackBar(
        theme: Theme.of(context),
        text: S.of(context).errorUnknownText,
      );
    } finally {
      _isLoading.add(false);
    }
  }

  bool _hasAnyFieldValidationError() {
    final emailErrorText = _validateEmail();

    _emailErrorText.add(emailErrorText);

    return emailErrorText != null;
  }
}
