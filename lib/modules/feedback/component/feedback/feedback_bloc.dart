import 'dart:async';
import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:mailer/mailer.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/user.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import 'feedback_component.dart';
import 'feedback_view_model.dart';

/// BLoC for the [FeedbackComponent].
///
/// Exposes a [FeedbackViewModel] for that component to use.
@injectable
class FeedbackBloc with ComponentBuildContext, ComponentLifecycleListener {
  FeedbackBloc(this._userRepository);

  final UserRepository _userRepository;

  String _feedback = '';
  String _email = '';

  final _feedbackErrorText = BehaviorSubject<String?>.seeded(null);
  final _emailErrorText = BehaviorSubject<String?>.seeded(null);
  final _isSending = BehaviorSubject<bool>.seeded(false);

  Stream<FeedbackViewModel>? _viewModel;
  Stream<FeedbackViewModel>? get viewModel => _viewModel;

  Stream<FeedbackViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest4(
      _userRepository.viewer(),
      _feedbackErrorText,
      _emailErrorText,
      _isSending,
      _createViewModel,
    );
  }

  FeedbackViewModel _createViewModel(
    User? user,
    String? feedbackErrorText,
    String? emailErrorText,
    bool isSending,
  ) {
    return FeedbackViewModel(
      isUserAnonymous: user!.isAnonymous!,
      isSending: isSending,
      feedbackErrorText: feedbackErrorText,
      emailErrorText: emailErrorText,
      onSendEmailTap: () => _sendEmail(user),
      onFeedbackTextChange: (feedback) => _feedback = feedback,
      onEmailTextChange: (email) => _email = email,
    );
  }

  @override
  void dispose() {
    _feedbackErrorText.close();
    _emailErrorText.close();
    _isSending.close();
    super.dispose();
  }

  Future<void> _sendEmail(User user) async {
    final suggestionErrorText = _validateFeedback();
    final emailErrorText = _validateEmail();
    if (suggestionErrorText != null || emailErrorText != null) {
      _feedbackErrorText.add(suggestionErrorText);
      _emailErrorText.add(emailErrorText);

      return;
    }

    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    _isSending.add(true);

    try {
      await _userRepository
          .sendFeedback(await _addMetadataToFeedback(i18n, user));
      messenger.showSuccessSnackBar(
        theme: theme,
        text: i18n.thankYouForFeedbackText,
      );
      CustomNavigator.getInstance().pop();
    } on SocketException catch (_) {
      messenger.showErrorSnackBar(
        theme: theme,
        text: i18n.errorNoInternetText,
      );
    } on MailerException catch (_) {
      messenger.showErrorSnackBar(
        theme: theme,
        text: i18n.errorSendEmailText,
      );
    } finally {
      _isSending.add(false);
    }
  }

  Future<String> _addMetadataToFeedback(S i18n, User user) async {
    final userEmail = user.isAnonymous! ? _email : user.email!;
    // Fix wrong version number on windows, https://bit.ly/3ylB2Qm
    final packageInfo = await PackageInfo.fromPlatform();

    return '''
$_feedback

Submitted by: ${userEmail.isEmpty ? 'Anonymous' : userEmail} ${user.isAnonymous! ? '(anonymous)' : '(registered)'}
Locale: ${i18n.locale}
TubeCards Version: ${packageInfo.version} (${packageInfo.buildNumber})
OS: ${Platform.operatingSystem}
''';
  }

  String? _validateFeedback() {
    if (_feedback.trim().isEmpty) {
      return S.of(context).missingFeedback;
    }

    return null;
  }

  String? _validateEmail() {
    if (_email.isEmpty) {
      return null;
    }
    if (!EmailValidator.validate(_email.trim())) {
      return S.of(context).enterValidEmailText;
    }

    return null;
  }
}
