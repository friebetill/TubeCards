import 'package:flutter/widgets.dart';

import '../modules/home/home_page.dart';
import '../modules/landing/landing_page.dart';

/// Returns the initial screen of the app based on the launch intent.
Future<LaunchIntent> resolveLaunchIntent({required bool isLoggedIn}) async {
  final orderedLaunchIntents = [
    DefaultIntent(isLoggedIn: isLoggedIn),
  ];

  for (final intent in orderedLaunchIntents) {
    if (await intent.isApplicable()) {
      return intent;
    }
  }

  return orderedLaunchIntents.last;
}

/// Represents a launch intent for the app.
///
/// Examples of a launch intent are intents to share resources with the app
/// like text or images.
///
/// Example of how a LaunchIntent should be used:
///
/// final launchIntent = ConcreteLaunchIntent();
/// if (launchIntent.isApplicable()) {
///   Widget initialScreen = launchIntent.getInitialScreen();
/// }
abstract class LaunchIntent {
  /// Determines and returns whether the app was launched with this specific
  /// intent.
  Future<bool> isApplicable();

  /// Returns the desired initial screen to properly handle this launch intent.
  ///
  /// Before calling [getInitialScreen], [isApplicable] needs to be called since
  /// it might conduct some initialization.
  Future<Widget> getInitialScreen();
}

/// Default intent representing the user manually opening the app.
///
/// In this case, the initial screen is entirely determined by whether the user
/// is logged in.
class DefaultIntent implements LaunchIntent {
  /// Creates a new [DefaultIntent] instance.
  DefaultIntent({required this.isLoggedIn});

  /// Indicates whether the user is logged into an account.
  final bool isLoggedIn;

  @override
  Future<bool> isApplicable() async {
    // Note: Ideally we would determine whether the user actually manually
    //       opened the app instead of just returning true.
    return true;
  }

  @override
  Future<Widget> getInitialScreen() async {
    return isLoggedIn ? const HomePage() : const LandingPage();
  }
}
