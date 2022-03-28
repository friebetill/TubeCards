import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/confidence.dart';
import '../../../../data/models/review_session.dart';
import '../../../../data/repositories/review_session_repository.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import 'review_statistic_component.dart';
import 'review_statistic_view_model.dart';

/// BLoC for the [ReviewStatisticComponent].
@injectable
class ReviewStatisticBloc with ComponentLifecycleListener {
  ReviewStatisticBloc(this._reviewSessionRepository);

  final ReviewSessionRepository _reviewSessionRepository;

  Stream<ReviewStatisticViewModel>? _viewModel;
  Stream<ReviewStatisticViewModel>? get viewModel => _viewModel;

  final _logger = Logger((ReviewStatisticBloc).toString());

  final _strengthIncrease = BehaviorSubject<double?>.seeded(null);
  final _isLoading = BehaviorSubject<bool>.seeded(true);
  bool _isLoadingLearningStateTriggered = false;

  Stream<ReviewStatisticViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest3(
      _strengthIncrease,
      _isLoading,
      _reviewSessionRepository.session,
      _createViewModel,
    ).doOnError((error, stackTrace) {
      _logger.severe('Error while creating view model', error, stackTrace);
    });
  }

  ReviewStatisticViewModel _createViewModel(
    double? strengthIncrease,
    bool isLoading,
    ReviewSession reviewSession,
  ) {
    if (!_isLoadingLearningStateTriggered) {
      _isLoadingLearningStateTriggered = true;
      _triggerLearningStateLoad(reviewSession);
    }

    final knownCardsCount = reviewSession.confidences.values
        .where((c) => c.isNotEmpty && c.first == Confidence.known)
        .length;
    final unknownCardsCount = reviewSession.confidences.values
        .where((c) => c.isNotEmpty && c.first == Confidence.unknown)
        .length;

    return ReviewStatisticViewModel(
      showIncreaseStatistic: reviewSession.loadLearningState != null,
      strengthIncrease: strengthIncrease,
      isLoading: isLoading,
      knownCardsCount: knownCardsCount,
      unknownCardsCount: unknownCardsCount,
    );
  }

  @override
  void dispose() {
    _strengthIncrease.close();
    _isLoading.close();
    super.dispose();
  }

  Future<void> _triggerLearningStateLoad(ReviewSession reviewSession) async {
    // Quickfix, wait that addRepetition has time to update the database
    await Future.delayed(const Duration(seconds: 1));

    final learningState = await reviewSession.loadLearningState?.call();

    if (learningState != null) {
      final initialLearningState = reviewSession.initialLearningState!;

      if (!_strengthIncrease.isClosed) {
        _strengthIncrease
            .add(learningState.strength! - initialLearningState.strength!);
        _isLoading.add(false);
      }
    }
  }
}
