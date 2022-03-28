import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/locale.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/confidence.dart';
import '../../../../data/models/review_session.dart';
import '../../../../data/preferences/preferences.dart';
import '../../../../data/repositories/deck_repository.dart';
import '../../../../data/repositories/review_session_repository.dart';
import '../../../../graphql/operation_exception.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import '../../../congratulation/congratulation_page.dart';
import '../../../text_to_speech/text_to_speech_runner.dart';
import 'review_component.dart';
import 'review_view_model.dart';

/// BLoC for the [ReviewComponent].
///
/// Exposes a [ReviewViewModel] for that component to use.
@injectable
class ReviewBloc with ComponentLifecycleListener, ComponentBuildContext {
  ReviewBloc(
    this._reviewSessionRepository,
    this._preferences,
    this._deckRepository,
    this._ttsRunner,
  ) {
    _ttsListener = Rx.combineLatest2(
      // TTS should only be triggered for a new card or when the side changed.
      //
      // Also, TTS should only be triggered if we're moving to a new card and
      // the front is displayed. Otherwise, due to small timing differences,
      // the next card is loaded first but the back side is still displayed.
      // In that case the back would also be queued to be used by TTS.
      _reviewSessionRepository.session.distinct((a, b) =>
          a.card == b.card && a.isFrontSide == b.isFrontSide ||
          (a.card != b.card && !b.isFrontSide)),
      _preferences.isTextToSpeechEnabled,
      _handleTextToSpeech,
    ).listen((_) {});
  }

  final ReviewSessionRepository _reviewSessionRepository;
  final Preferences _preferences;
  final DeckRepository _deckRepository;
  final TextToSpeechRunner _ttsRunner;

  final _logger = Logger((ReviewBloc).toString());

  Stream<ReviewViewModel>? _viewModel;
  Stream<ReviewViewModel>? get viewModel => _viewModel;

  final _slideInOnToggle = BehaviorSubject.seeded(true);
  final _slideOutRightOnToggle = BehaviorSubject.seeded(true);
  final _slideOutLeftOnToggle = BehaviorSubject.seeded(true);
  final _emphasizeKnownCardLabelButton = BehaviorSubject.seeded(false);
  final _emphasizeNotKnownCardLabelButton = BehaviorSubject.seeded(false);
  late StreamSubscription _ttsListener;

  Stream<ReviewViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest6(
      _reviewSessionRepository.session,
      _slideInOnToggle,
      _slideOutRightOnToggle,
      _slideOutLeftOnToggle,
      _emphasizeKnownCardLabelButton,
      _emphasizeNotKnownCardLabelButton,
      _createViewModel,
    );
  }

  ReviewViewModel _createViewModel(
    ReviewSession reviewSession,
    bool slideInOnToggle,
    bool slideOutRightOnToggle,
    bool slideOutLeftOnToggle,
    bool emphasizeKnownCardLabelButton,
    bool emphasizeNotKnownCardLabelButton,
  ) {
    return ReviewViewModel(
      frontText: reviewSession.card?.front,
      backText: reviewSession.card?.back,
      isFrontSide: reviewSession.isFrontSide,
      slideInOnToggle: slideInOnToggle,
      slideOutRightOnToggle: slideOutRightOnToggle,
      slideOutLeftOnToggle: slideOutLeftOnToggle,
      onFlipTap: () => reviewSession.setIsFrontSide(!reviewSession.isFrontSide),
      emphasizeKnownCardLabelButton: emphasizeKnownCardLabelButton,
      emphasizeNotKnownCardLabelButton: emphasizeNotKnownCardLabelButton,
      onCardLabeled: (confidence) => _onCardLabeled(
        confidence,
        reviewSession.addRepetition,
        reviewSession.hasNextCard,
        reviewSession.setIsFrontSide,
      ),
      triggerRightCardShift: () {
        _slideOutRightOnToggle.add(!slideOutRightOnToggle);
        _emphasizeKnownCardLabelButton.add(true);
      },
      triggerLeftCardShift: () {
        _slideOutLeftOnToggle.add(!slideOutLeftOnToggle);
        _emphasizeNotKnownCardLabelButton.add(true);
      },
      onLeftDistanceCrossed: _emphasizeNotKnownCardLabelButton.add,
      onRighttDistanceCrossed: _emphasizeKnownCardLabelButton.add,
    );
  }

  @override
  void dispose() {
    _slideInOnToggle.close();
    _slideOutRightOnToggle.close();
    _slideOutLeftOnToggle.close();

    _ttsListener.cancel();
    // Ideally, stopping any current speech output should be done through
    // WillPopScope. This is currently not possible, since it prevents swiping
    // to the previous page on iOS.
    _ttsRunner.stopSpeech();

    super.dispose();
  }

  void _onCardLabeled(
    Confidence confidence,
    Future<void> Function(Confidence) addRepetition,
    bool hasNextCard,
    ValueChanged<bool> setIsFrontSide,
  ) {
    _emphasizeKnownCardLabelButton.add(false);
    _emphasizeNotKnownCardLabelButton.add(false);
    addRepetition(confidence)
        .catchError((e, s) => _handleException(context, e, s as StackTrace));

    if (hasNextCard) {
      setIsFrontSide(true);
      _slideInOnToggle.add(!_slideInOnToggle.value);
    } else {
      CustomNavigator.getInstance().pushReplacementNamed(
        CongratulationPage.routeName,
        type: RouteType.expandingCircle,
      );
    }
  }

  void _handleException(BuildContext context, e, StackTrace s) {
    if (e is OperationException) {
      _handleOperationException(context, e, s);
    } else {
      _logger.severe('Unexpected exception during add repetition', e, s);
      ScaffoldMessenger.of(context).showErrorSnackBar(
        theme: Theme.of(context),
        text: S.of(context).errorUnknownText,
      );
    }
  }

  void _handleOperationException(
    BuildContext context,
    OperationException e,
    StackTrace s,
  ) {
    var exceptionText = S.of(context).errorUnknownText;
    if (e.isNoInternet) {
      exceptionText = S.of(context).errorNoInternetText;
    } else if (e.isServerOffline) {
      exceptionText = S.of(context).errorWeWillFixText;
    } else {
      _logger.severe(
        'Unexpected operation exception during add repetition',
        e,
        s,
      );
    }
    ScaffoldMessenger.of(context).showErrorSnackBar(
      theme: Theme.of(context),
      text: exceptionText,
    );
  }

  Future<void> _handleTextToSpeech(
    ReviewSession session,
    bool isTextToSpeechEnabled,
  ) async {
    if (session.card == null) {
      return;
    }

    if (!isTextToSpeechEnabled) {
      // In case this value just changed, we should also stop all current TTS.
      _ttsRunner.stopSpeech();

      return;
    }

    final card = session.card!;

    final deck = await _deckRepository.get(card.deck!.id!).first;
    final localeString =
        session.isFrontSide ? deck.frontLanguage : deck.backLanguage;
    final locale = Locale.tryParse(localeString ?? '');

    final markdown = session.isFrontSide ? card.front! : card.back!;

    if (localeString != null) {
      _ttsRunner.startSpeechForMarkdown(markdown, locale!);
    }
  }
}
