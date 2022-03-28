import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/auth_result.dart';
import '../../../../data/repositories/deck_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../graphql/operation_exception.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/load_during.dart';
import '../../../../utils/logging/interaction_logger.dart';
import '../../../../utils/purchases_helper.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import '../../../home/home_page.dart';
import '../../../reset_password/reset_password_page.dart';
import '../../../sign_up/sign_up_page.dart';
import '../migrate_dialog.dart';
import 'login_form_component.dart';
import 'login_form_view_model.dart';

/// BLoC for the [LoginFormComponent].
///
/// Exposes a [LoginFormViewModel] for that component to use.
@injectable
class LoginFormBloc with ComponentBuildContext, ComponentLifecycleListener {
  LoginFormBloc(
    this._userRepository,
    this._deckRepository,
  );

  final UserRepository _userRepository;
  final DeckRepository _deckRepository;

  final _logger = Logger((LoginFormBloc).toString());

  /// Whether the form should auto-validate the input on changes.
  ///
  /// This will be enabled once the form has been submitted for the first time.
  bool _autoValidate = false;
  String _email = '';
  String _password = '';

  final _obscurePassword = BehaviorSubject.seeded(true);
  final _isLoading = BehaviorSubject.seeded(false);
  final _emailErrorText = BehaviorSubject<String?>.seeded(null);
  final _passwordErrorText = BehaviorSubject<String?>.seeded(null);

  Stream<LoginFormViewModel>? _viewModel;
  Stream<LoginFormViewModel>? get viewModel => _viewModel;

  Stream<LoginFormViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest4(
      _obscurePassword,
      _isLoading,
      _emailErrorText,
      _passwordErrorText,
      _createViewModel,
    );
  }

  LoginFormViewModel _createViewModel(
    bool obscurePassword,
    bool isLoading,
    String? emailErrorText,
    String? passwordErrorText,
  ) {
    return LoginFormViewModel(
      obscurePassword: obscurePassword,
      isLoading: isLoading,
      emailErrorText: emailErrorText,
      passwordErrorText: passwordErrorText,
      onClose: CustomNavigator.getInstance().pop,
      onLogInTap: () => !_isLoading.value
          ? loadDuring(_handleLogIn, setLoading: _isLoading.add)
          : null,
      onResetPassword: () =>
          CustomNavigator.getInstance().pushNamed(ResetPasswordPage.routeName),
      onToggleObscurePassword: _handleToggleObscurePassword,
      onEmailChange: _handleEmailChange,
      onPasswordChange: _handlePasswordChange,
      onSignUpTap: () => CustomNavigator.getInstance()
          .pushReplacementNamed(SignUpPage.routeName),
    );
  }

  @override
  void dispose() {
    _obscurePassword.close();
    _isLoading.close();
    _emailErrorText.close();
    _passwordErrorText.close();
    super.dispose();
  }

  void _handleToggleObscurePassword() =>
      _obscurePassword.add(!_obscurePassword.value);

  void _handleEmailChange(String email) {
    _email = email.trim();

    if (_autoValidate) {
      _emailErrorText.add(_validateEmail());
    }
  }

  void _handlePasswordChange(String password) {
    _password = password;

    if (_autoValidate) {
      _passwordErrorText.add(_validatePassword());
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

  String? _validatePassword() {
    if (_password.isEmpty) {
      return S.of(context).passwordEnter;
    } else if (_password.length < 8) {
      return S.of(context).passwordRequirements;
    }

    return null;
  }

  Future<void> _handleLogIn() async {
    // Auto-validate as soon as the first submit is in.
    _autoValidate = true;
    if (_hasAnyFieldValidationError()) {
      return;
    }

    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    final user =
        await _userRepository.viewer(fetchPolicy: FetchPolicy.CacheOnly).first;
    final authResult =
        await _tryLogin(i18n, messenger, theme, dryRun: user != null);

    if (authResult == null) {
      return;
    }

    // We are done in case there was no (anonymous) user logged in beforehand.
    if (user == null || !user.isAnonymous!) {
      return _finishLogIn(i18n, messenger, theme, authResult);
    }

    final decks =
        await _deckRepository.getAll(fetchPolicy: FetchPolicy.NoCache).first;

    // Check whether we need to ask the user whether they want to migrate data
    // to the new user.
    if (decks.totalCount != 0) {
      final shouldMigrate = (await showDialog<bool>(
        barrierDismissible: false,
        context: context,
        builder: (_) => const MigrateDialog(),
      ))!;

      if (shouldMigrate) {
        if (await _transferDecks(authResult.token!)) {
          await _deleteUser();
          await _userRepository.clear();
          unawaited(_finishLogIn(i18n, messenger, theme, authResult));
        } else {
          return messenger.showErrorSnackBar(
            theme: theme,
            text: i18n.errorMigrateText,
          );
        }
      } else {
        await _deleteUser();
        await _userRepository.clear();
        await _finishLogIn(i18n, messenger, theme, authResult);
      }
    } else {
      await _deleteUser();
      await _finishLogIn(i18n, messenger, theme, authResult);
    }
  }

  Future<AuthResult?> _tryLogin(
    S i18n,
    ScaffoldMessengerState messenger,
    ThemeData theme, {
    required bool dryRun,
  }) async {
    AuthResult? authResult;
    try {
      authResult = await _userRepository.logIn(
        email: _email.trim(),
        password: _password,
        dryRun: dryRun,
      );
    } on OperationException catch (e, s) {
      _handleOperationException(e, s, i18n, messenger, theme);
    } on TimeoutException {
      _handleTimeoutException(i18n, messenger, theme);
    } on Exception catch (e, s) {
      _logger.severe('Unexpected exception during login', e, s);
      messenger.showErrorSnackBar(
        theme: theme,
        text: i18n.errorUnknownText,
      );
    }

    return authResult;
  }

  /// Persist the new logged in user and transition to the home screen if the
  /// log in attempt is a success.
  Future<void> _finishLogIn(
    S i18n,
    ScaffoldMessengerState messenger,
    ThemeData theme,
    AuthResult authResult,
  ) async {
    // Overwrite existing user data with data from the newly logged in user.
    await _userRepository.setAuthToken(authResult.token!);

    unawaited(identifyForPurchases(authResult.user!.id!));
    InteractionLogger.getInstance().setUserId(authResult.user!.id!);

    // Make sure to pop all routes so that the user cannot navigate back to
    // the landing screen or any previous screens.
    await CustomNavigator.getInstance()
        .pushNamedAndRemoveUntil(HomePage.routeName, (_) => false);
  }

  void _handleOperationException(
    OperationException e,
    StackTrace s,
    S i18n,
    ScaffoldMessengerState messenger,
    ThemeData theme,
  ) {
    var exceptionText = i18n.errorUnknownText;
    if (e.isNoInternet) {
      exceptionText = i18n.errorNoInternetText;
    } else if (e.isServerOffline) {
      exceptionText = i18n.errorWeWillFixText;
    } else if (e.isIncorrectEmailPassword) {
      exceptionText = i18n.errorIncorrectEmailPasswordText;
    } else {
      _logger.severe('Unexpected operation exception during log in', e, s);
    }

    messenger.showErrorSnackBar(
      theme: theme,
      text: exceptionText,
    );
  }

  void _handleTimeoutException(
    S i18n,
    ScaffoldMessengerState messenger,
    ThemeData theme,
  ) {
    final exceptionText = i18n.errorUnknownText;
    messenger.showErrorSnackBar(
      theme: theme,
      text: exceptionText,
    );
  }

  /// Transfers ownership of all decks that have been created on the anonymous
  /// account before the log in.
  Future<bool> _transferDecks(String recipientAuthToken) async {
    try {
      await _deckRepository.transferDecks(recipientAuthToken);

      return true;
    } on Exception catch (e, s) {
      _logger.severe(e, s);
    }

    return false;
  }

  /// Delete the current user from the server.
  Future<void> _deleteUser() async {
    try {
      await _userRepository.deleteCurrentUser();
    } on Exception catch (e, s) {
      // Swallow it. It is not a deal breaker for the user and we should still
      // log into the new account.
      _logger.severe(e, s);
    }
  }

  bool _hasAnyFieldValidationError() {
    final emailErrorText = _validateEmail();
    final passwordErrorText = _validatePassword();

    _emailErrorText.add(emailErrorText);
    _passwordErrorText.add(passwordErrorText);

    return emailErrorText != null || passwordErrorText != null;
  }
}
