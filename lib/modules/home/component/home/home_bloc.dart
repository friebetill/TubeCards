import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:ferry/ferry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter/scheduler.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:recase/recase.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/average_learning_state.dart';
import '../../../../data/models/card.dart';
import '../../../../data/models/connection.dart';
import '../../../../data/models/deck.dart';
import '../../../../data/preferences/app_properties.dart';
import '../../../../data/repositories/card_repository.dart';
import '../../../../data/repositories/deck_repository.dart';
import '../../../../data/repositories/review_session_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/deep_link_helper.dart';
import '../../../../utils/release_notes.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_dialog.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import '../../../review/review_page.dart';
import '../../../whats_new_page/whats_new_page.dart';
import '../deck_invitation/accept_deck_invite_component.dart';
import 'home_component.dart';
import 'home_view_model.dart';

/// BLoC for the [HomeComponent].
///
/// Exposes a [HomeViewModel] for that component to use.
@injectable
class HomeBloc
    with ComponentBuildContext, ComponentLifecycleListener, ComponentDialog {
  HomeBloc(
    this._userRepository,
    this._deckRepository,
    this._cardRepository,
    this._deepLinkHelper,
    this._appProperties,
    this._reviewSessionRepository,
  );

  final UserRepository _userRepository;
  final DeckRepository _deckRepository;
  final CardRepository _cardRepository;
  final DeepLinkHelper _deepLinkHelper;
  final AppProperties _appProperties;
  final ReviewSessionRepository _reviewSessionRepository;

  final _logger = Logger((HomeBloc).toString());

  final _activeDeckState = BehaviorSubject.seeded(ActiveState.active);
  final _isLoading = BehaviorSubject.seeded(false);
  // Is null on Windows, macOS and Linux.
  StreamSubscription? _deepLinkSubscription;
  late ValueStream<Connection<Card>> _dueCardConnection;

  var _isDialogShown = false;

  Stream<HomeViewModel>? _viewModel;
  Stream<HomeViewModel>? get viewModel => _viewModel;

  Stream<HomeViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    _dueCardConnection = _cardRepository.getDueCards().shareValue();

    return _viewModel = Rx.combineLatest7(
      _userRepository.getLearningState(
        fetchPolicy: FetchPolicy.CacheAndNetwork,
      ),
      _activeDeckState,
      _deckRepository.getAll(fetchPolicy: FetchPolicy.CacheAndNetwork),
      _deckRepository.getAll(
        fetchPolicy: FetchPolicy.CacheAndNetwork,
        isActive: false,
      ),
      _dueCardConnection,
      _cardRepository.getAll(fetchPolicy: FetchPolicy.CacheAndNetwork),
      _isLoading,
      _createViewModel,
    ).doOnError((error, stackTrace) {
      _logger.severe('Error while creating view model', error, stackTrace);
    });
  }

  HomeViewModel _createViewModel(
    AverageLearningState learningState,
    ActiveState activeDeckState,
    Connection<Deck> activeDeckConnection,
    Connection<Deck> inactiveDeckConnection,
    Connection<Card> dueCardConnection,
    Connection<Card> cardsConnection,
    bool isLoading,
  ) {
    return HomeViewModel(
      strength: learningState.strength!,
      totalDueCardsCount: dueCardConnection.totalCount!,
      totalCardsCount: cardsConnection.totalCount!,
      activeDecks: activeDeckConnection.nodes!,
      inactiveDecks: inactiveDeckConnection.nodes!,
      onReviewTap: dueCardConnection.totalCount! > 0 ? _handleReviewTap : null,
      showLoadingIndicator: activeDeckState == ActiveState.active
          ? activeDeckConnection.pageInfo!.hasNextPage!
          : inactiveDeckConnection.pageInfo!.hasNextPage!,
      activeDeckState: activeDeckState,
      onActiveStateChanged: _handleActiveStateChanged,
      refresh: () async {
        await Future.wait([
          _userRepository
              .getLearningState(fetchPolicy: FetchPolicy.NetworkOnly)
              .first,
          activeDeckConnection.refetch!(),
          inactiveDeckConnection.refetch!(),
          dueCardConnection.refetch!(),
          cardsConnection.refetch!(),
        ]);
      },
      fetchMore: _activeDeckState.value == ActiveState.active
          ? () => _fetchMore(
                activeDeckConnection.fetchMore!,
                activeDeckConnection.pageInfo!.hasNextPage!,
              )
          : () => _fetchMore(
                inactiveDeckConnection.fetchMore!,
                inactiveDeckConnection.pageInfo!.hasNextPage!,
              ),
    );
  }

  @override
  void dispose() {
    _activeDeckState.close();
    _isLoading.close();
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  @override
  void onDialog() {
    if (!Platform.isLinux && !Platform.isFuchsia) {
      _initDeepLinkSubscription();
    }
    _handleWhatsNewPage();
  }

  Future<void> _initDeepLinkSubscription() async {
    final appLinks = AppLinks();

    final uri = await appLinks.getInitialAppLink();
    if (uri != null) {
      await _handleDeepLink(uri);
    }

    _deepLinkSubscription = appLinks.uriLinkStream.listen(
      _handleDeepLink,
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

  Future<void> _handleDeepLink(Uri uri) async {
    final deckInviteId = uri.pathSegments.last;

    _isDialogShown = true;
    await showModalBottomSheet(
      context: context,
      builder: (_) => AcceptDeckInviteComponent(deckInviteId),
    );
    _deepLinkHelper.clear();
  }

  Future<void> _handleWhatsNewPage() async {
    final lastBuildNumber =
        _appProperties.whatsNewModalShownBuildNumber.getValue();
    final buildNumber =
        int.parse((await PackageInfo.fromPlatform()).buildNumber);

    final isFirstTimeInitialization = lastBuildNumber == 0;
    if (isFirstTimeInitialization) {
      /// Don't show the dialog when the user opens the app for the first time
      /// to avoid overwhelming the new user.
      await _appProperties.whatsNewModalShownBuildNumber.setValue(buildNumber);

      return;
    }

    if (_isDialogShown || lastBuildNumber == buildNumber) {
      return;
    }

    final newReleaseNotes = releaseNotes
        .where(
          (rn) => rn.buildNumber > lastBuildNumber && rn.whatsNewText != null,
        )
        .toList()
      ..sort((a, b) => b.buildNumber.compareTo(a.buildNumber));

    if (newReleaseNotes.isEmpty) {
      return;
    }

    void onContinueTap(List<ReleaseNote> releaseNotes) {
      if (releaseNotes.isEmpty) {
        return CustomNavigator.getInstance().pop();
      }

      final oldestReleaseNote = releaseNotes.removeLast();
      _appProperties.whatsNewModalShownBuildNumber
          .setValue(oldestReleaseNote.buildNumber);

      CustomNavigator.getInstance().pushReplacementNamed(
        WhatsNewPage.routeName,
        args: WhatsNewPageArguments(
          releaseNote: oldestReleaseNote,
          onContinueTap: () => onContinueTap(releaseNotes),
        ),
      );
    }

    _isDialogShown = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final oldestReleaseNote = newReleaseNotes.removeLast();
      _appProperties.whatsNewModalShownBuildNumber
          .setValue(oldestReleaseNote.buildNumber);

      CustomNavigator.getInstance().pushNamed(
        WhatsNewPage.routeName,
        args: WhatsNewPageArguments(
          releaseNote: oldestReleaseNote,
          onContinueTap: () => onContinueTap(newReleaseNotes),
        ),
      );
    });
  }

  Future<void> _fetchMore(AsyncCallback fetchMore, bool hasNextPage) async {
    if (_isLoading.value || !hasNextPage) {
      return;
    }

    _isLoading.add(true);
    await fetchMore();
    _isLoading.add(false);
  }

  Future<void> _handleReviewTap() async {
    _reviewSessionRepository.createSession(
      connectionStream: _dueCardConnection,
      dryRun: false,
      title: S.of(context).dueCards.titleCase,
      loadLearningState: () {
        return _userRepository
            .getLearningState(fetchPolicy: FetchPolicy.NetworkOnly)
            .first;
      },
    );
    await CustomNavigator.getInstance().pushNamed(ReviewPage.routeName);
  }

  void _handleActiveStateChanged(ActiveState? value) {
    if (value == null || value == _activeDeckState.value) {
      return;
    } else {
      _activeDeckState.add(value);
    }
  }
}
