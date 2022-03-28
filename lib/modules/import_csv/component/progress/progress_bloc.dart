import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:ferry/ferry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:retry/retry.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/card.dart';
import '../../../../data/models/deck.dart';
import '../../../../data/models/deck_member.dart';
import '../../../../data/models/unsplash_image.dart';
import '../../../../data/repositories/card_repository.dart';
import '../../../../data/repositories/deck_repository.dart';
import '../../../../graphql/operation_exception.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/progress.dart';
import '../../../../utils/socket_exception_extension.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import '../../../../widgets/import/progress_state.dart';
import '../../../import_csv/data/csv_card.dart';
import '../../../import_csv/data/csv_deck.dart';
import 'progress_component.dart';
import 'progress_view_model.dart';

const String rateLimitedErrorCode = 'RATE_LIMITED';
const String retryAfterExtensionKey = 'retry-after';
const Duration _updateInterval = Duration(seconds: 1);

/// Changing the batch size requires changing the mutation insert10Cards.
const int _batchSize = 10;

/// BLoC for the [ProgressComponent].
@injectable
class ProgressBloc with ComponentLifecycleListener, ComponentBuildContext {
  ProgressBloc(this._deckRepository, this._cardRepository);

  final DeckRepository _deckRepository;
  final CardRepository _cardRepository;

  final _logger = Logger((ProgressBloc).toString());

  Stream<ImportProgressViewModel>? _viewModel;
  Stream<ImportProgressViewModel>? get viewModel => _viewModel;

  final _importState =
      BehaviorSubject<ProgressState>.seeded(ProgressState.isImporting);
  final _importProgress = BehaviorSubject<Progress>.seeded(const Progress(0));
  final _remainingTime = BehaviorSubject<Duration?>.seeded(null);

  late final Timer _timer;
  var _importedCardsCount = 0;
  late final int _totalCardsCount;
  final _stopwatch = Stopwatch()..start();
  bool _isAborted = false;

  Stream<ImportProgressViewModel> createViewModel({
    required CSVDeck deck,
    required AsyncCallback onOpenEmailAppTap,
  }) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    _totalCardsCount = deck.cards.length;
    _timer = Timer.periodic(_updateInterval, _updateProgress);

    () async {
      try {
        await _import(deck);
      } on Exception catch (e, s) {
        _handleImportError(e, s);
        // ignore: avoid_catching_errors
      } finally {
        // A better solution, but much more time consuming, would be to
        // update Ferry so that the isolate is not overloaded with the
        // insert10CardsHandler.
        _deckRepository
          ..getAll(fetchPolicy: FetchPolicy.NetworkOnly)
          ..getAll(
            fetchPolicy: FetchPolicy.NetworkOnly,
            isActive: false,
          );
        _cardRepository
          ..getAll(fetchPolicy: FetchPolicy.NetworkOnly)
          ..getDueCards(fetchPolicy: FetchPolicy.NetworkOnly);
      }
    }();

    return _viewModel = Rx.combineLatest4(
      _importState,
      _importProgress,
      _remainingTime,
      Stream.value(onOpenEmailAppTap),
      _createViewModel,
    );
  }

  ImportProgressViewModel _createViewModel(
    ProgressState importState,
    Progress progress,
    Duration? remainingTime,
    AsyncCallback onOpenEmailAppTap,
  ) {
    return ImportProgressViewModel(
      importState: importState,
      // Use squared ease in for improved perceived performance, https://bit.ly/3zxxlYX
      importProgress: Progress(easeInSquared(progress.value)),
      remainingTime: remainingTime,
      onCloseTap: _handleCloseTap,
      onOpenEmailAppTap: onOpenEmailAppTap,
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _importState.close();
    _importProgress.close();
    _remainingTime.close();
    super.dispose();
  }

  void _updateProgress(Timer _) {
    final progress = Progress(_importedCardsCount / _totalCardsCount);
    final oldProgress = _importProgress.value;

    if (progress != oldProgress) {
      _importProgress.add(progress);

      // Calculation based on this answer, https://bit.ly/3q9bHGl
      final timeTaken = _stopwatch.elapsed.inSeconds;
      final progressDone = progress.value;
      final progressLeft = 1 - progress.value;
      final remainingSeconds = timeTaken / progressDone * progressLeft;
      if (remainingSeconds.isFinite) {
        _remainingTime.add(Duration(seconds: remainingSeconds.toInt()));
      }
    } else if (_remainingTime.value != null &&
        _remainingTime.value! >= _updateInterval) {
      _remainingTime.add(_remainingTime.value! - _updateInterval);
    }
  }

  Future<void> _import(CSVDeck importDeck) async {
    final deck = await retry(
      () => _deckRepository.upsert(Deck(
        name: importDeck.name,
        description: '',
        viewerDeckMember: const DeckMember(isActive: true),
        createMirrorCard: false,
        coverImage: defaultCoverImage,
      )),
      retryIf: _retryIf,
      onRetry: _onRetry,
    );

    final remainingCards = List<CSVCard>.from(importDeck.cards);
    while (remainingCards.isNotEmpty) {
      if (_isAborted) {
        return;
      }

      final batch = remainingCards.take(_batchSize).toList();

      if (batch.length == _batchSize) {
        final cards = await _importBatch(batch, deck);
        cards.asMap().forEach((index, card) {
          if (card != null) {
            remainingCards.remove(batch[index]);
            _importedCardsCount += 1;
          }
        });
      } else {
        for (final ankiCard in batch) {
          await _importCard(ankiCard, deck);
          remainingCards.remove(ankiCard);
          _importedCardsCount += 1;
        }
      }
    }
    _importProgress.add(const Progress(1));
    _importState.add(ProgressState.isDone);
  }

  /// Upserts the given batch of cards.
  ///
  /// If a card of the batch was not successfully upserted, null is
  /// returned at the original position in the list.
  Future<List<Card?>> _importBatch(List<CSVCard> batch, Deck deck) async {
    final cardBatch = <Card>[];
    for (final card in batch) {
      cardBatch.add(Card(
        deck: deck,
        front: card.front,
        back: card.back,
      ));
    }

    return retry(
      () => _cardRepository.insert10Cards(cardBatch),
      retryIf: _retryIf,
      onRetry: _onRetry,
    );
  }

  Future<void> _importCard(CSVCard card, Deck deck) async {
    await retry(
      () => _cardRepository.upsert(Card(
        deck: deck,
        front: card.front,
        back: card.back,
      )),
      retryIf: _retryIf,
      onRetry: _onRetry,
    );
  }

  double easeInSquared(double x) => x * x;

  void _handleImportError(Exception e, StackTrace s) {
    if ((e is OperationException && e.isNoInternet) ||
        (e is SocketException && e.isNoInternet)) {
      _importState.add(ProgressState.isInternetError);
    } else {
      // Log any of the following unexpected exception:
      // - OperationException unrelated to the internet
      // - HttpException during image upload
      // - TimeoutException
      _logger.severe('Exception during CSV import', e, s);
      _importState.add(ProgressState.isGeneralError);
    }
  }

  Future<void> _handleCloseTap() async {
    switch (_importState.value) {
      case ProgressState.isDone:
        return CustomNavigator.getInstance().popUntil((r) => r.isFirst);
      case ProgressState.isGeneralError:
      case ProgressState.isInternetError:
        return CustomNavigator.getInstance().popUntil((r) => r.isFirst);
      case ProgressState.isImporting:
        final isAbortComfirmed = await showDialog<bool>(
          context: context,
          builder: _buildConfirmAbortDialog,
        );
        if (isAbortComfirmed != null && isAbortComfirmed) {
          _isAborted = true;
          CustomNavigator.getInstance().pop();
        }
    }
  }

  Widget _buildConfirmAbortDialog(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).importAbort),
      content: Text(S.of(context).importAbortCautionText),
      actions: <Widget>[
        TextButton(
          onPressed: () => CustomNavigator.getInstance().pop(false),
          child: Text(
            S.of(context).continueText.toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyText2!.color,
            ),
          ),
        ),
        TextButton(
          onPressed: () => CustomNavigator.getInstance().pop(true),
          child: Text(
            S.of(context).cancel.toUpperCase(),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    );
  }

  FutureOr<bool> _retryIf(Exception e) {
    return e is OperationException || e is TimeoutException;
  }

  FutureOr<void> _onRetry(Exception e) async {
    if (e is OperationException) {
      final rateLimitedException = e.graphqlErrors.firstWhereOrNull(
        (e) =>
            e.extensions != null &&
            e.extensions!['code'] == rateLimitedErrorCode &&
            e.extensions![retryAfterExtensionKey] != null &&
            e.extensions![retryAfterExtensionKey] is int,
      );
      if (rateLimitedException != null) {
        await Future.delayed(Duration(
          seconds:
              rateLimitedException.extensions![retryAfterExtensionKey] as int,
        ));
      }
    }
  }
}
