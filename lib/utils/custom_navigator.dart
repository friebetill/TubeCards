import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../modules/account/account_page.dart';
import '../modules/account_deletion/account_deletion_page.dart';
import '../modules/check_email_page/check_email_page.dart';
import '../modules/congratulation/congratulation_page.dart';
import '../modules/deck/deck_page.dart';
import '../modules/developer_options/developer_options_page.dart';
import '../modules/draw_image/draw_image_page.dart';
import '../modules/export_csv/export_csv_page.dart';
import '../modules/feedback/feedback_page.dart';
import '../modules/home/home_page.dart';
import '../modules/import_anki/import_anki_page.dart';
import '../modules/import_csv/import_csv_page.dart';
import '../modules/import_excel/import_excel_page.dart';
import '../modules/import_export/import_export_page.dart';
import '../modules/import_google_sheets/import_google_sheets_page.dart';
import '../modules/interactiv_image/interactive_image_page.dart';
import '../modules/join_shared_deck/join_shared_deck_page.dart';
import '../modules/landing/landing_page.dart';
import '../modules/login/login_page.dart';
import '../modules/manage_members/manage_members_page.dart';
import '../modules/offer/offer_page.dart';
import '../modules/offer_preview/offer_preview_page.dart';
import '../modules/preferences/preferences_page.dart';
import '../modules/reminder/reminders_page.dart';
import '../modules/reminder_add/reminder_add_page.dart';
import '../modules/reset_password/reset_password_page.dart';
import '../modules/review/review_page.dart';
import '../modules/select_deck/select_deck_page.dart';
import '../modules/sign_up/sign_up_page.dart';
import '../modules/support_space/support_space_page.dart';
import '../modules/upsert_card/upsert_card_page.dart';
import '../modules/upsert_deck/page/upsert_deck_page.dart';
import '../modules/whats_new_page/whats_new_page.dart';
import 'page_routes.dart';

/// Wrapper around the [Navigator] Widget that allows to specify the type of
/// route.
class CustomNavigator {
  /// Returns an singleton instance of [CustomNavigator].
  factory CustomNavigator.getInstance() => _instance ??= CustomNavigator._();

  CustomNavigator._();

  static CustomNavigator? _instance;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final _routeNameToWidgetFunction = {
    HomePage.routeName: (_) => const HomePage(),
    LandingPage.routeName: (_) => const LandingPage(),
    SignUpPage.routeName: (_) => const SignUpPage(),
    LoginPage.routeName: (_) => const LoginPage(),
    ResetPasswordPage.routeName: (_) => const ResetPasswordPage(),
    CheckEmailPage.routeName: (args) => CheckEmailPage(email: args as String),
    DeckPage.routeName: (args) => DeckPage(args as DeckArguments),
    JoinSharedDeckPage.routeName: (_) => const JoinSharedDeckPage(),
    InteractiveImagePage.routeName: (args) =>
        InteractiveImagePage(imageUrl: args as String),
    UpsertDeckPage.routeNameAdd: (_) => const UpsertDeckPage(),
    UpsertDeckPage.routeNameEdit: (args) =>
        UpsertDeckPage(deckId: args as String?),
    UpsertCardPage.routeNameAdd: (args) =>
        UpsertCardPage(args as UpsertCardArguments),
    UpsertCardPage.routeNameEdit: (args) =>
        UpsertCardPage(args as UpsertCardArguments),
    DrawImagePage.routeName: (args) => DrawImagePage(imageUrl: args as String?),
    ManageMembersPage.routeName: (deckId) =>
        ManageMembersPage(deckId as String),
    AccountPage.routeName: (_) => const AccountPage(),
    ImportExportPage.routeName: (_) => const ImportExportPage(),
    ImportAnkiPage.routeName: (_) => const ImportAnkiPage(),
    ImportCSVPage.routeName: (_) => const ImportCSVPage(),
    ImportExcelPage.routeName: (_) => const ImportExcelPage(),
    ExportCSVPage.routeName: (_) => const ExportCSVPage(),
    OfferPage.routeName: (args) => OfferPage(offerId: args as String),
    OfferPreviewPage.routeName: (args) =>
        OfferPreviewPage(deckId: args as String),
    ImportGoogleSheetsPage.routeName: (_) => const ImportGoogleSheetsPage(),
    DeveloperOptionsPage.routeName: (_) => const DeveloperOptionsPage(),
    AccountDeletionPage.routeName: (_) => const AccountDeletionPage(),
    ReviewPage.routeName: (_) => const ReviewPage(),
    PreferencesPage.routeName: (_) => const PreferencesPage(),
    SupportSpacePage.routeName: (_) => const SupportSpacePage(),
    SelectDeckPage.routeName: (_) => const SelectDeckPage(),
    RemindersPage.routeName: (_) => const RemindersPage(),
    ReminderAddPage.routeName: (_) => const ReminderAddPage(),
    FeedbackPage.routeName: (_) => const FeedbackPage(),
    CongratulationPage.routeName: (_) => const CongratulationPage(),
    WhatsNewPage.routeName: (args) =>
        WhatsNewPage(args as WhatsNewPageArguments),
  };

  /// Wraps the [Navigator.pushNamed].
  ///
  /// The wrap allows to specify the type of the route.
  Future<T?> pushNamed<T>(
    String routeName, {
    Object? args,
    RouteType? type,
  }) {
    return navigatorKey.currentState!.push<T>(_routeTypeToRoute(
      routeName,
      type ?? (Platform.isMacOS ? RouteType.immediate : RouteType.material),
      args,
    ));
  }

  /// Wraps the [Navigator.pushNamedAndRemoveUntil].
  ///
  /// The wrap allows to specify the type of the route.
  Future<void> pushNamedAndRemoveUntil(
    String routeName,
    RoutePredicate predicate, {
    Object? args,
    RouteType type = RouteType.material,
  }) {
    return navigatorKey.currentState!.pushAndRemoveUntil(
      _routeTypeToRoute(routeName, type, args),
      predicate,
    );
  }

  /// Wraps the [Navigator.pushReplacementNamed].
  ///
  /// The wrap allows to specify the type of the route.
  Future<void> pushReplacementNamed(
    String routeName, {
    Object? args,
    RouteType type = RouteType.material,
  }) {
    return navigatorKey.currentState!.pushReplacement(
      _routeTypeToRoute(routeName, type, args),
    );
  }

  PageRoute<T> _routeTypeToRoute<T>(
    String routeName,
    RouteType routeType,
    Object? args,
  ) {
    final builder =
        _routeNameToWidgetFunction[routeName] ?? (args) => const HomePage();
    switch (routeType) {
      case RouteType.material:
        return MaterialPageRoute<T>(
          builder: (context) => builder(args),
          settings: RouteSettings(name: routeName),
        );
      case RouteType.cupertino:
        return CupertinoPageRoute<T>(
          builder: (context) => builder(args),
          settings: RouteSettings(name: routeName),
        );
      case RouteType.expandingCircle:
        return PageRoutes.expandingCircle(
          builder(args),
          settings: RouteSettings(name: routeName),
        );
      case RouteType.immediate:
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => builder(args),
          transitionDuration: Duration.zero,
        );
      default:
        return MaterialPageRoute<T>(
          builder: (context) => builder(args),
          settings: RouteSettings(name: routeName),
        );
    }
  }

  /// Pop the top-most route off the navigator.
  ///
  /// If the top route cannot be popped, the app will quit
  /// instead of displaying a black screen. Showing the
  /// black screen is the default behavior of [Navigator.pop].
  void pop<T extends Object?>([T? result]) {
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop(result);
    } else {
      SystemNavigator.pop();
    }
  }

  /// Calls [pop] repeatedly until the predicate returns true.
  ///
  /// If the top route cannot be popped, the app will quit
  /// instead of displaying a black screen. Showing the
  /// black screen is the default behavior of [Navigator.pop].
  void popUntil(RoutePredicate predicate) {
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.popUntil(predicate);
    } else {
      SystemNavigator.pop();
    }
  }
}

/// The route type with which a page transition is performed.
enum RouteType {
  /// This route type represents the [MaterialPageRoute].
  material,

  /// This route type represents the [CupertinoPageRoute].
  cupertino,

  /// This route type represents the [PageRoutes.expandingCircle].
  expandingCircle,

  immediate,
}
