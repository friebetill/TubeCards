import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/auth_result.dart';
import '../../../../data/models/user.dart';
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
import 'sign_up_form_component.dart';
import 'sign_up_form_view_model.dart';

/// BLoC for the [SignUpFormComponent].
///
/// Exposes a [SignUpFormViewModel] for that component to use.
@injectable
class SignUpFormBloc with ComponentBuildContext, ComponentLifecycleListener {
  SignUpFormBloc(this._userRepository);

  final UserRepository _userRepository;
  final _logger = Logger((SignUpFormBloc).toString());

  /// Whether the form should auto-validate the input on changes.
  ///
  /// This will be enabled once the form has been submitted for the first time.
  bool _autoValidate = false;
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';

  final _isLoading = BehaviorSubject<bool>.seeded(false);
  final _obscurePassword = BehaviorSubject<bool>.seeded(true);
  final _firstNameErrorText = BehaviorSubject<String?>.seeded(null);
  final _lastNameErrorText = BehaviorSubject<String?>.seeded(null);
  final _emailErrorText = BehaviorSubject<String?>.seeded(null);
  final _passwordErrorText = BehaviorSubject<String?>.seeded(null);

  Stream<SignUpFormViewModel>? _viewModel;
  Stream<SignUpFormViewModel>? get viewModel => _viewModel;

  Stream<SignUpFormViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest6(
      _isLoading,
      _obscurePassword,
      _firstNameErrorText,
      _lastNameErrorText,
      _emailErrorText,
      _passwordErrorText,
      _createViewModel,
    );
  }

  SignUpFormViewModel _createViewModel(
    bool isLoading,
    bool obscurePassword,
    String? firstNameErrorText,
    String? lastNameErrorText,
    String? emailErrorText,
    String? passwordErrorText,
  ) {
    return SignUpFormViewModel(
      isLoading: isLoading,
      obscurePassword: obscurePassword,
      firstNameErrorText: firstNameErrorText,
      lastNameErrorText: lastNameErrorText,
      emailErrorText: emailErrorText,
      passwordErrorText: passwordErrorText,
      onFirstNameChanged: _handleFirstNameChanged,
      onLastNameChanged: _handleLastNameChanged,
      onEmailChanged: _handleEmailChanged,
      onPasswordChanged: _handlePasswordChanged,
      onObscureTap: () => _obscurePassword.add(!_obscurePassword.value),
      onSignUpTap: () => !_isLoading.value
          ? loadDuring(_handleSignUpTap, setLoading: _isLoading.add)
          : null,
    );
  }

  @override
  void dispose() {
    _isLoading.close();
    _obscurePassword.close();
    _firstNameErrorText.close();
    _lastNameErrorText.close();
    _emailErrorText.close();
    _passwordErrorText.close();
    super.dispose();
  }

  void _handleFirstNameChanged(String firstName) {
    _firstName = firstName;
    if (_autoValidate) {
      _firstNameErrorText.add(_validateFirstName());
    }
  }

  void _handleLastNameChanged(String lastName) {
    _lastName = lastName;
    if (_autoValidate) {
      _lastNameErrorText.add(_validateLastName());
    }
  }

  void _handleEmailChanged(String email) {
    _email = email.trim();
    if (_autoValidate) {
      _emailErrorText.add(_validateEmail());
    }
  }

  void _handlePasswordChanged(String password) {
    _password = password;
    if (_autoValidate) {
      _passwordErrorText.add(_validatePassword());
    }
  }

  /// Handles the sign up process.
  ///
  /// There two different situations in which a sign up can occur.
  ///
  /// The first is directly after the app is opened for the first time. There
  /// is no account yet and the user would like to create one. This case is
  /// straight forward.
  ///
  /// In the second case, the user opts to try the app without creating an
  /// account. After creating decks and cards, the user decides to sign up.
  /// In this case, we need to update the existing account into a
  /// non-anonymous account.
  Future<void> _handleSignUpTap() async {
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

    User? updateUserResult;
    AuthResult? signUpResult;
    if (user != null && user.isAnonymous!) {
      // There is already an anonymous account. Upgrade it using the provided
      // personal data.
      updateUserResult = await _tryUpdateUser(i18n, messenger, theme);
    } else {
      signUpResult = await _trySignUp(i18n, messenger, theme);
    }

    if (updateUserResult == null && signUpResult == null) {
      return;
    }

    final userId = updateUserResult?.id ?? signUpResult!.user!.id!;
    unawaited(identifyForPurchases(userId));
    InteractionLogger.getInstance().setUserId(userId);

    // Make sure to pop all routes so that the user cannot navigate back to
    // this or any previous screens.
    await CustomNavigator.getInstance().pushNamedAndRemoveUntil(
      HomePage.routeName,
      (_) => false,
    );
  }

  Future<AuthResult?> _trySignUp(
    S i18n,
    ScaffoldMessengerState messenger,
    ThemeData theme,
  ) async {
    AuthResult? authResult;
    try {
      authResult = await _userRepository.signUp(
        email: _email,
        password: _password,
        firstName: _firstName,
        lastName: _lastName,
      );
    } on OperationException catch (e, s) {
      _handleOperationException(i18n, messenger, theme, e, s);
    } on TimeoutException {
      _handleTimeoutException(i18n, messenger, theme);
    } on Exception catch (e, s) {
      _logger.severe('Unexpected exception during sign up', e, s);
      ScaffoldMessenger.of(context).showErrorSnackBar(
        theme: Theme.of(context),
        text: S.of(context).errorUnknownText,
      );
    }

    return authResult;
  }

  /// Updates the currently logged in user with the given parameters and
  /// returns the updated [User].
  ///
  /// The user is first updated on the server and in case of success the
  /// local user copy is updated as well.
  Future<User?> _tryUpdateUser(
    S i18n,
    ScaffoldMessengerState messenger,
    ThemeData theme,
  ) async {
    User? updatedUser;
    try {
      updatedUser = await _userRepository.updateCurrentUser(
        firstName: _firstName,
        lastName: _lastName,
        email: _email,
        password: _password,
        isAnonymous: false,
      );
    } on OperationException catch (e, s) {
      _handleOperationException(i18n, messenger, theme, e, s);
    } on TimeoutException {
      _handleTimeoutException(i18n, messenger, theme);
    } on Exception catch (_) {
      ScaffoldMessenger.of(context).showErrorSnackBar(
        theme: Theme.of(context),
        text: S.of(context).errorUnknownText,
      );
    }

    return updatedUser;
  }

  bool _hasAnyFieldValidationError() {
    _firstNameErrorText.add(_validateFirstName());
    _lastNameErrorText.add(_validateLastName());
    _emailErrorText.add(_validateEmail());
    _passwordErrorText.add(_validatePassword());

    return _firstNameErrorText.value != null ||
        _lastNameErrorText.value != null ||
        _emailErrorText.value != null ||
        _passwordErrorText.value != null;
  }

  void _handleOperationException(
    S i18n,
    ScaffoldMessengerState messenger,
    ThemeData theme,
    OperationException e,
    StackTrace s,
  ) {
    var exceptionText = i18n.errorUnknownText;
    if (e.isNoInternet) {
      exceptionText = i18n.errorNoInternetText;
    } else if (e.isServerOffline) {
      exceptionText = i18n.errorWeWillFixText;
    } else if (e.doesUserAlreadyExists) {
      exceptionText = i18n.thisUserAlreadyExists;
    } else {
      _logger.severe('Unexpected operation exception during sign up', e, s);
    }
    messenger.showErrorSnackBar(theme: theme, text: exceptionText);
  }

  void _handleTimeoutException(
    S i18n,
    ScaffoldMessengerState messenger,
    ThemeData theme,
  ) {
    messenger.showErrorSnackBar(theme: theme, text: i18n.errorUnknownText);
  }

  String? _validateFirstName() =>
      _firstName.isEmpty ? S.of(context).firstNameEnter : null;

  String? _validateLastName() =>
      _lastName.isEmpty ? S.of(context).lastNameEnter : null;

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
}
