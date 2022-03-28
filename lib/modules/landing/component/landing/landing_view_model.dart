import 'package:flutter/foundation.dart';

class LandingViewModel {
  LandingViewModel({
    required this.isLoading,
    required this.initDeepLinkSubscription,
    required this.onGetStartedTap,
    required this.onSignUpTap,
    required this.onAlreadyRegisteredTap,
  });

  /// Indicates whether the screen is in a loading state due to API requests.
  final bool isLoading;

  final VoidCallback initDeepLinkSubscription;
  final VoidCallback onGetStartedTap;
  final VoidCallback onSignUpTap;
  final VoidCallback onAlreadyRegisteredTap;
}
