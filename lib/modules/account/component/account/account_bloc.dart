import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart' hide AboutDialog;
import 'package:in_app_review/in_app_review.dart';
import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/preferences/preferences.dart';
import '../../../../data/preferences/user_history.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/config.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../developer_options/developer_options_page.dart';
import '../../../feedback/feedback_page.dart';
import '../../../import_export/import_export_page.dart';
import '../../../landing/landing_page.dart';
import '../../../preferences/preferences_page.dart';
import '../../../support_space/support_space_page.dart';
import '../about_dialog.dart';
import '../other_platforms_dialog.dart';
import 'account_component.dart';
import 'account_view_model.dart';

/// BLoC for the [AccountComponent].
@injectable
class AccountBloc with ComponentBuildContext {
  AccountBloc(
    this._userRepository,
    this._preferences,
    this._userHistory,
    this._inAppReview,
  );

  final UserRepository _userRepository;
  final Preferences _preferences;
  final UserHistory _userHistory;
  final InAppReview _inAppReview;

  Stream<AccountViewModel>? _viewModel;
  Stream<AccountViewModel>? get viewModel => _viewModel;

  Stream<AccountViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = _userRepository.viewer().map((user) {
      return AccountViewModel(
        isLoggedIn: user != null && !user.isAnonymous!,
        onAboutTap: _showAboutDialog,
        onImportExportTap: () =>
            CustomNavigator.getInstance().pushNamed(ImportExportPage.routeName),
        onLogOutTap: _handleLogOutTap,
        onPrivacyPolicyTap: () => _launchURL(privacyPolicyURL),
        onRateUsTap: () {
          if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
            _inAppReview.openStoreListing(appStoreId: appStoreId);
          } else if (Platform.isWindows) {
            launchUrl(Uri(
              scheme: 'ms-windows-store',
              host: '/',
              path: '/review/',
              queryParameters: {'ProductId': microsoftStoreId},
            ));
          }
        },
        onDeveloperTap: () => CustomNavigator.getInstance()
            .pushNamed(DeveloperOptionsPage.routeName),
        onFeedbackTap: () =>
            CustomNavigator.getInstance().pushNamed(FeedbackPage.routeName),
        onVoteNextFeaturesTap: () => _launchURL(voteNextFeaturesURL),
        onPreferenceTap: () =>
            CustomNavigator.getInstance().pushNamed(PreferencesPage.routeName),
        onSupportUsTap: () =>
            CustomNavigator.getInstance().pushNamed(SupportSpacePage.routeName),
        onOtherPlatformsTap: _showOtherPlatformsDialog,
        onSourceCodeTap: () => _launchURL(githubRepository),
      );
    });
  }

  Future<void> _launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showErrorSnackBar(
        theme: Theme.of(context),
        text: S.of(context).errorOpenPageText(url),
      );
      throw Exception(S.of(context).couldNotLaunchURL(url));
    }
  }

  void _showAboutDialog() {
    showDialog(context: context, builder: (_) => const AboutDialog());
  }

  void _showOtherPlatformsDialog() {
    showDialog(context: context, builder: (_) => const OtherPlatformsDialog());
  }

  void _handleLogOutTap() {
    /// Wait until the transition finished before deleting all the user-
    /// related data. The reason for this is that otherwise the models will
    /// update while the new route is slowly transitioning into a new screen
    /// and all the user-related Widgets will update before the screen is fully
    /// hidden. This means we might briefly show new content on the screen even
    /// though the user is navigating away.
    unawaited(CustomNavigator.getInstance()
        .pushNamedAndRemoveUntil(LandingPage.routeName, (_) => false));

    const transitionDuration = Duration(milliseconds: 300);
    Future.delayed(transitionDuration, () {
      _userRepository.clear();
      _preferences.clear();
      _userHistory.clear();
      if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
        Purchases.logOut();
      }
    });
  }
}
