import 'package:flutter/material.dart';

import 'event_types.dart';
import 'interaction_logger.dart';

/// This is a navigation observer to log user navigation.
///
/// [Route]s can always be null and their [Route.settings] can also always be
/// null. For example, if the application starts, there is no previous route.
/// The [RouteSettings] is null if a developer has not specified any
/// RouteSettings.
///
/// [CustomNavigatorObserver] must be added to the [navigation observer](https://api.flutter.dev/flutter/material/MaterialApp/navigatorObservers.html) of
/// your used app. This is an example for [MaterialApp](https://api.flutter.dev/flutter/material/MaterialApp/navigatorObservers.html),
/// but the integration for [CupertinoApp](https://api.flutter.dev/flutter/cupertino/CupertinoApp/navigatorObservers.html)
/// and [WidgetsApp](https://api.flutter.dev/flutter/widgets/WidgetsApp/navigatorObservers.html) is the same.
///
/// ```dart
/// MaterialApp(
///   navigatorObservers: [
///     NavigatorObserver(),
///   ],
///   // other parameters ...
/// )
/// ```
///
/// See also:
///   - [RouteObserver](https://api.flutter.dev/flutter/widgets/RouteObserver-class.html)
///   - [Navigating with arguments](https://flutter.dev/docs/cookbook/navigation/navigate-with-arguments)
class CustomNavigatorObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    InteractionLogger.getInstance().logNavigation(
      type: EventTypes.navigationPush,
      from: previousRoute?.settings,
      to: route.settings,
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    InteractionLogger.getInstance().logNavigation(
      type: EventTypes.navigationReplace,
      from: oldRoute?.settings,
      to: newRoute?.settings,
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    InteractionLogger.getInstance().logNavigation(
      type: EventTypes.navigationPop,
      from: route.settings,
      to: previousRoute?.settings,
    );
  }
}
