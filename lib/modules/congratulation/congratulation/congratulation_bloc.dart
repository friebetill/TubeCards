import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/confidence.dart';
import '../../../data/models/review_session.dart';
import '../../../data/preferences/user_history.dart';
import '../../../data/repositories/review_session_repository.dart';
import '../../../utils/custom_navigator.dart';
import '../../../widgets/component/component_build_context.dart';
import '../component/rate_space_dialog.dart';
import 'congratulation_view_model.dart';

/// BLoC for the [CongratulationComponent].
///
/// Exposes a [CongratulationViewModel] for that component to use.
@injectable
class CongratulationBloc with ComponentBuildContext {
  CongratulationBloc(
    this._userHistory,
    this._reviewSessionRepository,
  );
  final UserHistory _userHistory;
  final ReviewSessionRepository _reviewSessionRepository;

  Stream<CongratulationViewModel>? _viewModel;
  Stream<CongratulationViewModel>? get viewModel => _viewModel;

  Stream<CongratulationViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = _reviewSessionRepository.session.map(_createViewModel);
  }

  CongratulationViewModel _createViewModel(ReviewSession reviewSession) {
    return CongratulationViewModel(
      onContinueTap: () => _handleContinueButtonTap(reviewSession),
    );
  }

  Future<void> _handleContinueButtonTap(ReviewSession reviewSession) async {
    final knownCardsCount = reviewSession.confidences.values
        .where((c) => c.isNotEmpty && c.first == Confidence.known)
        .length;
    final unknownCardsCount = reviewSession.confidences.values
        .where((c) => c.isNotEmpty && c.first == Confidence.unknown)
        .length;

    final isPlatformSupported = Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isMacOS ||
        Platform.isWindows;
    final isInAppReviewAvailable =
        Platform.isWindows || await InAppReview.instance.isAvailable();
    final hasEnoughTimePassed = DateTime.now()
        .isAfter(_userHistory.nextShowRateAppDialogDate.getValue());
    final hasEnoughLaunches = _userHistory.appLaunchCount.getValue() > 25;
    final isEnoughCards = knownCardsCount + unknownCardsCount > 20;
    final isEnoughKnownCards = knownCardsCount > unknownCardsCount * 4;

    if (isPlatformSupported &&
        isInAppReviewAvailable &&
        hasEnoughTimePassed &&
        hasEnoughLaunches &&
        isEnoughCards &&
        isEnoughKnownCards) {
      await _buildRatingDialog();
    } else {
      CustomNavigator.getInstance().pop();
    }
  }

  Future<void> _buildRatingDialog() async {
    await _userHistory.nextShowRateAppDialogDate.setValue(
      DateTime.now().add(const Duration(days: 21)),
    );

    await showDialog(
      context: context,
      builder: (context) => RateSpaceDialog(_userHistory),
    );
  }
}
