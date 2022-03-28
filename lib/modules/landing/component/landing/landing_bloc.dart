import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/auth_result.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../graphql/operation_exception.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/deep_link_helper.dart';
import '../../../../utils/load_during.dart';
import '../../../../utils/logging/interaction_logger.dart';
import '../../../../utils/purchases_helper.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import '../../../home/home_page.dart';
import '../../../login/login_page.dart';
import '../../../sign_up/sign_up_page.dart';
import 'landing_component.dart';
import 'landing_view_model.dart';

/// BLoC for the [LandingComponent].
///
/// Exposes a [LandingViewModel] for that component to use.
@injectable
class LandingBloc with ComponentBuildContext, ComponentLifecycleListener {
  LandingBloc(this._userRepository, this._deepLinkHelper);

  final UserRepository _userRepository;
  final DeepLinkHelper _deepLinkHelper;

  final _logger = Logger((LandingBloc).toString());

  final _isLoading = BehaviorSubject.seeded(false);
  late StreamSubscription _deepLinkSubscription;

  Stream<LandingViewModel>? _viewModel;
  Stream<LandingViewModel>? get viewModel => _viewModel;

  Stream<LandingViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = _isLoading.map(
      (isLoading) => LandingViewModel(
        isLoading: isLoading,
        onGetStartedTap: () => !_isLoading.value
            ? loadDuring(
                _handleGetStartedTap,
                setLoading: _isLoading.add,
              )
            : null,
        initDeepLinkSubscription: _initDeepLinkSubscription,
        onSignUpTap: () =>
            CustomNavigator.getInstance().pushNamed(SignUpPage.routeName),
        onAlreadyRegisteredTap: () =>
            CustomNavigator.getInstance().pushNamed(LoginPage.routeName),
      ),
    );
  }

  @override
  void dispose() {
    _isLoading.close();
    _deepLinkSubscription.cancel();
    super.dispose();
  }

  Future<void> _handleGetStartedTap() async {
    final authResult = await _tryCreateAnonymousUser();

    if (authResult == null) {
      return;
    }

    unawaited(identifyForPurchases(authResult.user!.id!));
    InteractionLogger.getInstance().setUserId(authResult.user!.id!);

    await CustomNavigator.getInstance()
        .pushReplacementNamed(HomePage.routeName);
  }

  Future<AuthResult?> _tryCreateAnonymousUser() async {
    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    try {
      // The await is deliberately set to catch possible exceptions.
      return await _userRepository.createAnonymousUser();
    } on OperationException catch (e, s) {
      var exceptionText = i18n.errorUnknownText;
      if (e.isNoInternet) {
        exceptionText = i18n.errorNoInternetText;
      } else if (e.isServerOffline) {
        exceptionText = i18n.errorWeWillFixText;
      } else {
        _logger.severe(
          'Unexpected operation exception during get started',
          e,
          s,
        );
      }
      messenger.showErrorSnackBar(theme: theme, text: exceptionText);
    } on TimeoutException {
      messenger.showErrorSnackBar(theme: theme, text: i18n.errorUnknownText);
    } on Exception catch (e, s) {
      _logger.severe('Unexpected exception during "Get started"', e, s);
      ScaffoldMessenger.of(context).showErrorSnackBar(
        theme: Theme.of(context),
        text: S.of(context).errorUnknownText,
      );
    }

    return null;
  }

  Future<void> _initDeepLinkSubscription() async {
    // Attach a listener to the links stream
    _deepLinkSubscription = _deepLinkHelper.deepLinks.listen(
      (link) async {
        if (link == null) {
          return;
        }
        ScaffoldMessenger.of(context).showErrorSnackBar(
          theme: Theme.of(context),
          text: S.of(context).signUpToJoinADeck,
        );
      },
      onError: (e, s) {
        _logger.severe(
          'Exception during init of deep link subscription.',
          e,
          s as StackTrace,
        );
        ScaffoldMessenger.of(context).showErrorSnackBar(
          theme: Theme.of(context),
          text: S.of(context).errorUnknownText,
        );
      },
    );
  }
}
