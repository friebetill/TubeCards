import 'package:flutter/foundation.dart';

class AccountViewModel {
  const AccountViewModel({
    required this.isLoggedIn,
    required this.onAboutTap,
    required this.onImportExportTap,
    required this.onDeveloperTap,
    required this.onOtherPlatformsTap,
    required this.onFeedbackTap,
    required this.onVoteNextFeaturesTap,
    required this.onLogOutTap,
    required this.onPreferenceTap,
    required this.onPrivacyPolicyTap,
    required this.onRateUsTap,
    required this.onSupportUsTap,
    required this.onSourceCodeTap,
  });

  final bool isLoggedIn;

  final VoidCallback onAboutTap;
  final VoidCallback onImportExportTap;
  final VoidCallback onDeveloperTap;
  final VoidCallback onOtherPlatformsTap;
  final VoidCallback onFeedbackTap;
  final VoidCallback onVoteNextFeaturesTap;
  final VoidCallback onLogOutTap;
  final VoidCallback onPreferenceTap;
  final VoidCallback onPrivacyPolicyTap;
  final VoidCallback onRateUsTap;
  final VoidCallback onSupportUsTap;
  final VoidCallback onSourceCodeTap;
}
