import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/models/user.dart';
import '../../../../data/repositories/deck_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../graphql/operation_exception.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import '../../../interactiv_image/interactive_image_page.dart';
import 'export_csv_component.dart';
import 'export_csv_view_model.dart';

/// BLoC for the [ExportCSVComponent].
@injectable
class ExportCSVBloc with ComponentLifecycleListener, ComponentBuildContext {
  ExportCSVBloc(this._userRepository, this._deckRepository);

  final UserRepository _userRepository;
  final DeckRepository _deckRepository;

  Stream<ExportCSVViewModel>? _viewModel;
  Stream<ExportCSVViewModel>? get viewModel => _viewModel;

  bool _autoValidate = false;
  String _email = '';
  final _emailErrorText = BehaviorSubject<String?>.seeded(null);
  final _isLoading = BehaviorSubject<bool>.seeded(false);

  final _logger = Logger((ExportCSVBloc).toString());

  Stream<ExportCSVViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest3(
      _userRepository.viewer(),
      _emailErrorText,
      _isLoading,
      _createViewModel,
    );
  }

  ExportCSVViewModel _createViewModel(
    User? user,
    String? emailErrorText,
    bool isLoading,
  ) {
    if (!user!.isAnonymous!) {
      _email = user.email!;
    }

    return ExportCSVViewModel(
      onEmailChanged: _handleEmailChanged,
      showEmailField: user.isAnonymous!,
      emailErrorText: emailErrorText,
      isLoading: isLoading,
      onExportTap: _handleExportTap,
      onImageTap: _handleImageTap,
      onLinkTap: _handleLinkTap,
    );
  }

  @override
  void dispose() {
    _emailErrorText.close();
    _isLoading.close();
    super.dispose();
  }

  Future<void> _handleExportTap() async {
    if (_isLoading.value) {
      return;
    }

    // Auto-validate as soon as the first submit is in.
    _autoValidate = true;
    _emailErrorText.add(_validateEmail());
    if (_emailErrorText.value != null) {
      return;
    }

    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    _isLoading.add(true);
    try {
      await _deckRepository.exportDecks(_email);
      messenger.showSuccessSnackBar(
        theme: theme,
        text: i18n.exportDeckSendEmailText(_email),
      );
    } on OperationException catch (e, s) {
      _handleOperationException(messenger, theme, i18n, e, s);
    } on TimeoutException {
      messenger.showErrorSnackBar(
        theme: theme,
        text: i18n.errorUnknownText,
      );
    } on Exception catch (e, s) {
      _logger.severe('Unexpected exception during deck export', e, s);
      messenger.showErrorSnackBar(
        theme: theme,
        text: i18n.errorUnknownText,
      );
    } finally {
      _isLoading.add(false);
    }
  }

  Future<void> _handleLinkTap(String text, String? url, String title) async {
    if (url == null) {
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final i18n = S.of(context);

    if (!(await canLaunchUrl(uri))) {
      return messenger.showErrorSnackBar(
        theme: theme,
        text: i18n.errorOpenPageText(url),
      );
    }
    await launchUrl(uri);
  }

  void _handleImageTap(String imageUrl) {
    CustomNavigator.getInstance().pushNamed(
      InteractiveImagePage.routeName,
      args: imageUrl,
    );
  }

  void _handleOperationException(
    ScaffoldMessengerState messenger,
    ThemeData theme,
    S i18n,
    OperationException e,
    StackTrace s,
  ) {
    var exceptionText = i18n.errorUnknownText;
    if (e.isNoInternet) {
      exceptionText = i18n.errorNoInternetText;
    } else if (e.isServerOffline) {
      exceptionText = i18n.errorWeWillFixText;
    } else {
      _logger.severe('Operation exception during deck export', e, s);
    }

    messenger.showErrorSnackBar(theme: theme, text: exceptionText);
  }

  void _handleEmailChanged(String email) {
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
}
