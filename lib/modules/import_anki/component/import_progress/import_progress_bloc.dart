import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:ferry/ferry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' hide context;
import 'package:retry/retry.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/models/card.dart';
import '../../../../data/models/deck.dart';
import '../../../../data/models/deck_member.dart';
import '../../../../data/models/unsplash_image.dart';
import '../../../../data/repositories/card_repository.dart';
import '../../../../data/repositories/deck_repository.dart';
import '../../../../graphql/operation_exception.dart';
import '../../../../i18n/i18n.dart';
import '../../../../main.dart';
import '../../../../utils/card_media_handler.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/progress.dart';
import '../../../../utils/socket_exception_extension.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import '../../../../widgets/editor/editor_utils.dart';
import '../../../../widgets/import/progress_state.dart';
import '../../data/anki_card.dart';
import '../../data/anki_package.dart';
import 'import_progress_component.dart';
import 'import_progress_view_model.dart';

const String rateLimitedErrorCode = 'RATE_LIMITED';
const String retryAfterExtensionKey = 'retry-after';
const Duration _updateInterval = Duration(seconds: 1);

/// Changing the batch size requires changing the mutation insert10Cards.
const int _batchSize = 10;

const _htmlIgnoreTags = ['script', 'style'];
const _htmlStyleOptions = {
  'headingStyle': 'atx',
  'codeBlockStyle': 'fenced',
};

/// BLoC for the [ImportProgressComponent].
@injectable
class ImportProgressBloc
    with ComponentLifecycleListener, ComponentBuildContext {
  ImportProgressBloc(
    this._deckRepository,
    this._cardRepository,
    this._mediaHandler,
  );

  final DeckRepository _deckRepository;
  final CardRepository _cardRepository;
  final CardMediaHandler _mediaHandler;

  final _logger = Logger((ImportProgressBloc).toString());

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
    required AnkiPackage package,
    required AsyncCallback onOpenEmailAppTap,
  }) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    _totalCardsCount = package.decks.fold<int>(0, (p, d) => p + d.cards.length);
    _timer = Timer.periodic(_updateInterval, _updateProgress);

    () async {
      try {
        await _import(package);
      } on Exception catch (e, s) {
        _handleImportError(e, s);
        // ignore: avoid_catching_errors
      } finally {
        // A better solution, but much more time consuming, would be to
        // update Ferry so that the isolate is not overloaded with the
        // insert10CardsHandler.
        _deckRepository.getAll(fetchPolicy: FetchPolicy.NetworkOnly);
        _cardRepository.getDueCards(fetchPolicy: FetchPolicy.NetworkOnly);
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
      // Use cubic ease in for improved perceived performance, https://bit.ly/3zxxlYX
      importProgress: Progress(easeInCubic(progress.value)),
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

  Future<void> _import(AnkiPackage package) async {
    for (final ankiDeck in package.decks) {
      final deck = await retry(
        () => _deckRepository.upsert(Deck(
          name: ankiDeck.name,
          description: '',
          viewerDeckMember: const DeckMember(isActive: true),
          createMirrorCard: false,
          coverImage: defaultCoverImage,
        )),
        retryIf: _retryIf,
        onRetry: _onRetry,
      );

      final remainingCards = List<AnkiCard>.from(ankiDeck.cards);
      while (remainingCards.isNotEmpty) {
        if (_isAborted) {
          return;
        }

        final batch = remainingCards.take(_batchSize).toList();

        if (batch.length == _batchSize) {
          final cards = await _importBatch(batch, deck, package);
          cards.asMap().forEach((index, card) {
            if (card != null) {
              remainingCards.remove(batch[index]);
              _importedCardsCount += 1;
            }
          });
        } else {
          for (final ankiCard in batch) {
            await _importCard(ankiCard, deck, package);
            remainingCards.remove(ankiCard);
            _importedCardsCount += 1;
          }
        }
      }
    }
    _importState.add(ProgressState.isDone);
  }

  /// Upserts the given batch of cards.
  ///
  /// If a card of the batch was not successfully upserted, null is
  /// returned at the original position in the list.
  Future<List<Card?>> _importBatch(
    List<AnkiCard> batch,
    Deck deck,
    AnkiPackage package,
  ) async {
    final cardBatch = <Card>[];
    for (final ankiCard in batch) {
      var card = _CardContent(
        front: html2md.convert(
          ankiCard.front,
          styleOptions: _htmlStyleOptions,
          ignore: _htmlIgnoreTags,
        ),
        back: html2md.convert(
          ankiCard.back,
          styleOptions: _htmlStyleOptions,
          ignore: _htmlIgnoreTags,
        ),
      );
      card = await _uploadLocalImages(card, package);
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

  Future<void> _importCard(
    AnkiCard ankiCard,
    Deck deck,
    AnkiPackage package,
  ) async {
    var card = _CardContent(
      front: html2md.convert(
        ankiCard.front,
        styleOptions: _htmlStyleOptions,
        ignore: _htmlIgnoreTags,
      ),
      back: html2md.convert(
        ankiCard.back,
        styleOptions: _htmlStyleOptions,
        ignore: _htmlIgnoreTags,
      ),
    );
    card = await _uploadLocalImages(card, package);

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

  final Map<String, String> _ankiImageUrlToLocalUrl = {};
  final Map<String, String> _localUrlToRemoteUrl = {};

  /// Uploads the images from the given [card].
  ///
  /// In the process, the local URL of the images is replaced with the
  /// URL of the uploaded images.
  Future<_CardContent> _uploadLocalImages(
    _CardContent content,
    AnkiPackage package,
  ) async {
    var updatedContent = await _addImagesToCardMediaHandler(content, package);

    final frontUrls = _mediaHandler.getImagesURLs(updatedContent.front);
    final backUrls = _mediaHandler.getImagesURLs(updatedContent.back);
    final urls = [...frontUrls, ...backUrls];

    // Replace all local urls with already uploaded remote urls
    final urlsToRemove = <String>[];
    for (final imageUrl in urls) {
      if (_localUrlToRemoteUrl.containsKey(imageUrl!)) {
        final remoteUrl = _localUrlToRemoteUrl[imageUrl]!;
        updatedContent = _CardContent(
          front: updatedContent.front.replaceAll(imageUrl, remoteUrl),
          back: updatedContent.back.replaceAll(imageUrl, remoteUrl),
        );
        urlsToRemove.add(imageUrl);
      }
    }
    urlsToRemove.forEach(urls.remove);

    final filteredImageUrls = await _getUploadableImageUrls(urls);

    for (final imageUrl in filteredImageUrls) {
      final remoteUrl = await retry(
        () => _mediaHandler.uploadImage(imageUrl),
        retryIf: (e) =>
            e is SocketException ||
            e is HttpException ||
            e is OperationException,
      );

      updatedContent = _CardContent(
        front: updatedContent.front.replaceAll(imageUrl, remoteUrl),
        back: updatedContent.back.replaceAll(imageUrl, remoteUrl),
      );
      _localUrlToRemoteUrl[imageUrl] = remoteUrl;
    }

    return updatedContent;
  }

  Future<_CardContent> _addImagesToCardMediaHandler(
    _CardContent content,
    AnkiPackage package,
  ) async {
    final reversedJsonMedia = package.jsonMedia.map((k, v) => MapEntry(v, k));

    final frontUrls = _mediaHandler.getImagesURLs(content.front);
    final backUrls = _mediaHandler.getImagesURLs(content.back);
    final urls = {...frontUrls, ...backUrls};

    var updatedContent = content;
    for (final url in urls) {
      if (url == null) {
        continue;
      }
      if (_ankiImageUrlToLocalUrl.containsKey(url)) {
        final uri = _ankiImageUrlToLocalUrl[url]!;
        updatedContent = _CardContent(
          front: updatedContent.front.replaceAll(url, uri),
          back: updatedContent.back.replaceAll(url, uri),
        );
        continue;
      }

      final fileExtension = extension(url).toLowerCase().replaceAll('.', '');
      final uriPath = buildUriPath('${const Uuid().v1()}.$fileExtension');

      final filePath = reversedJsonMedia[url];
      if (filePath == null) {
        continue;
      }
      final image = File('${package.extractionPath}/$filePath');

      await getIt<BaseCacheManager>().putFile(
        uriPath,
        image.readAsBytesSync(),
        fileExtension: fileExtension,
      );

      updatedContent = _CardContent(
        front: updatedContent.front.replaceAll(url, uriPath),
        back: updatedContent.back.replaceAll(url, uriPath),
      );
      _ankiImageUrlToLocalUrl[url] = uriPath;
    }

    return updatedContent;
  }

  /// Returns a list of image urls that point to images that should be uploaded.
  ///
  /// Whether an image should be uploaded depends on whether it is only stored
  /// locally, the file size does not exceed any limits, and the given path
  /// points to an image that exists and is supported.
  Future<Set<String>> _getUploadableImageUrls(List<String?> imageUrls) async {
    final filteredImageUrls = Set<String>.from(imageUrls);

    _mediaHandler.removeURLsToUnsupportedFiles(filteredImageUrls);
    await _mediaHandler.removeURLsToTooLargeFiles(filteredImageUrls);

    return filteredImageUrls;
  }

  double easeInCubic(double x) => x * x * x;

  void _handleImportError(Exception e, StackTrace s) {
    if ((e is OperationException && e.isNoInternet) ||
        (e is SocketException && e.isNoInternet)) {
      _importState.add(ProgressState.isInternetError);
    } else {
      // Log any of the following unexpected exception:
      // - OperationException unrelated to the internet
      // - HttpException during image upload
      // - TimeoutException
      _logger.severe('Exception during Anki import', e, s);
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

/// Represents the plain text contents of a single card.
class _CardContent {
  const _CardContent({required this.front, required this.back});

  final String front;
  final String back;
}
