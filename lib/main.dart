import 'dart:async';
import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'data/preferences/reminders.dart';
import 'data/preferences/user_history.dart';
import 'graphql/graph_ql_runner.dart';
import 'i18n/i18n.dart';
import 'main.config.dart';
import 'modules/reminder/system_notification_manager.dart';
import 'modules/text_to_speech/text_to_speech_runner.dart';
import 'utils/assets.dart';
import 'utils/certificate.dart';
import 'utils/config.dart';
import 'utils/custom_navigator.dart';
import 'utils/launch_intent_util.dart';
import 'utils/locale_utils.dart';
import 'utils/logging.dart';
import 'utils/logging/custom_navigator_observer.dart';
import 'utils/logging/interaction_logger.dart';
import 'utils/sizes.dart';
import 'utils/themes/dark_theme.dart';
import 'utils/themes/light_theme.dart';

void main() {
  // Necessary to catch unexpected errors from async code, https://bit.ly/328SGZg
  runZonedGuarded<Future<void>>(
    () async {
      // Initializes the WidgetBinding which is needed for Firebase to
      // use the PlatformChannel to execute native code.
      WidgetsFlutterBinding.ensureInitialized();

      if (Platform.isAndroid) {
        trustLetsEncryptCertificate();
      }

      await SentryFlutter.init(
        (options) => options
          ..dsn = sentryDSN
          ..debug = false,
      );
      FlutterError.onError =
          (e) => _logger.severe('Unexpected exception', e.exception, e.stack);

      await setupLogging();

      sqfliteFfiInit();

      await initDependencyInjection();
      if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
        await Purchases.setup(Platform.isAndroid
            ? revenueCatGoogleApiKey
            : revenueCatAppleApiKey);
      }

      final graphQLRunner = getIt<GraphQLRunner>();
      await graphQLRunner.spawn();

      InteractionLogger.getInstance().init();

      // Add more platforms when this issue is closed, https://bit.ly/3eIB9NL
      if ((Platform.isAndroid || Platform.isIOS) &&
          // There are problems with hot reload, https://bit.ly/3oLMmTW
          isProduction) {
        await getIt<TextToSpeechRunner>().spawn();
      }

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      );
      final savedThemeMode = await AdaptiveTheme.getThemeMode();

      unawaited(Assets.initDefaultCoverImage());
      unawaited(_initReminders());
      getIt<UserHistory>().incrementLaunchCounterByOne();

      EquatableConfig.stringify = true;

      final launchIntent = await resolveLaunchIntent(
        isLoggedIn: await graphQLRunner.isLoggedIn(),
      );
      final firstScreen = await launchIntent.getInitialScreen();

      runApp(
        SpaceApp(
          savedThemeMode: savedThemeMode,
          firstScreen: firstScreen,
        ),
      );

      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        doWhenWindowReady(() {
          appWindow
            ..minSize = const Size(minimumScreenWidth, minimumScreenHeight)
            ..title = 'TubeCards'
            ..show();
        });
      }
    },
    (e, s) => _logger.severe('Unexpected exception', e, s),
  );
}

// Global instance to easily access the GetIt service locator.
final getIt = GetIt.instance;

final _logger = Logger('main.dart');

@InjectableInit()
Future<void> initDependencyInjection() {
  return $initGetIt(getIt, environment: 'graphql_isolate'); // graphql_main
}

Future<void> _initReminders() async {
  if (Platform.isAndroid || Platform.isIOS) {
    await getIt<SystemNotificationManager>().initialize();
    final reminders = await getIt<Reminders>().get().first;
    await getIt<SystemNotificationManager>().rescheduleNotifications(reminders);
  }
}

class SpaceApp extends StatelessWidget {
  const SpaceApp({
    required this.savedThemeMode,
    required this.firstScreen,
    Key? key,
  }) : super(key: key);

  final AdaptiveThemeMode? savedThemeMode;
  final Widget firstScreen;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: lightTheme,
      dark: darkTheme,
      initial: savedThemeMode ?? AdaptiveThemeMode.system,
      builder: (theme, darkTheme) {
        return MaterialApp(
          title: 'TubeCards',
          home: firstScreen,
          theme: theme,
          darkTheme: darkTheme,
          navigatorObservers: [
            CustomNavigatorObserver(),
            SentryNavigatorObserver(),
          ],
          navigatorKey: CustomNavigator.getInstance().navigatorKey,
          localeListResolutionCallback: getBestMatchingSupportedLocale,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            LocaleNamesLocalizationsDelegate(),
          ],
          supportedLocales: S.delegate.supportedLocales,
        );
      },
    );
  }
}
