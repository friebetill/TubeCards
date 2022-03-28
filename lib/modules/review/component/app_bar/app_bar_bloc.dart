import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/card.dart';
import '../../../../data/models/review_session.dart';
import '../../../../data/preferences/preferences.dart';
import '../../../../data/repositories/review_session_repository.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/permission.dart';
import '../../../upsert_card/upsert_card_page.dart';
import 'app_bar_view_model.dart';

@injectable
class AppBarBloc {
  AppBarBloc(this._reviewSessionRepository, this._preferences);

  final ReviewSessionRepository _reviewSessionRepository;
  final Preferences _preferences;

  Stream<AppBarViewModel>? _viewModel;
  Stream<AppBarViewModel>? get viewModel => _viewModel;

  Stream<AppBarViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest2(
      _reviewSessionRepository.session,
      _preferences.isTextToSpeechEnabled,
      _createViewModel,
    );
  }

  AppBarViewModel _createViewModel(
    ReviewSession reviewSession,
    bool isTextToSpeechEnabled,
  ) {
    final card = reviewSession.card;
    final deck = reviewSession.card?.deck;

    final hasEditPermission = card?.id != null &&
        deck?.id != null &&
        deck?.viewerDeckMember?.role != null &&
        deck!.viewerDeckMember!.role!.hasPermission(Permission.cardUpsert);

    return AppBarViewModel(
      title: reviewSession.title,
      progress: reviewSession.progress,
      isTextToSpeechEnabled: isTextToSpeechEnabled,
      onTextToSpeechToggleTap: Platform.isAndroid || Platform.isIOS
          ? _handleTextToSpeechToggle
          : null,
      onEditTap: hasEditPermission
          ? _handleEditTap(deck?.id, card?.id, reviewSession.isFrontSide)
          : null,
      onBackTap: () => CustomNavigator.getInstance().pop(),
    );
  }

  VoidCallback? _handleEditTap(
    String? deckId,
    String? cardId,
    bool isFrontSide,
  ) {
    if (deckId == null || cardId == null) {
      return null;
    }

    return () async {
      await CustomNavigator.getInstance().pushNamed<Card>(
        UpsertCardPage.routeNameEdit,
        args: UpsertCardArguments(
          deckId: deckId,
          cardId: cardId,
          isFrontSide: isFrontSide,
        ),
      );
    };
  }

  void _handleTextToSpeechToggle() {
    _preferences.isTextToSpeechEnabled
        .setValue(!_preferences.isTextToSpeechEnabled.getValue());
  }
}
