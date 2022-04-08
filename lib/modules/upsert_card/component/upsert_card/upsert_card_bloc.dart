import 'dart:async';
import 'dart:convert';

import 'package:delta_markdown/delta_markdown.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:quiver/core.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/card.dart';
import '../../../../data/models/deck.dart';
import '../../../../data/repositories/card_repository.dart';
import '../../../../data/repositories/deck_repository.dart';
import '../../../../graphql/operation_exception.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/card_media_handler.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/permission.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import '../../../deck/component/delete_dialog.dart';
import '../../../deck/component/select_deck_dialog/select_deck_dialog_component.dart';
import 'upsert_card_component.dart';
import 'upsert_card_view_model.dart';

/// BLoC for the [UpsertCardComponent].
///
/// Exposes a [UpsertCardViewModel] for that component to use.
@injectable
class UpsertCardBloc with ComponentBuildContext, ComponentLifecycleListener {
  UpsertCardBloc(
    this._deckRepository,
    this._cardRepository,
    this._mediaHandler,
  );

  /// Card content where front and back are empty.
  static const emptyCardContent = _CardContent(front: '', back: '');

  final DeckRepository _deckRepository;
  final CardRepository _cardRepository;
  final CardMediaHandler _mediaHandler;
  final _logger = Logger((UpsertCardBloc).toString());

  final _cardStream = BehaviorSubject<Card>();
  StreamSubscription<Card>? _cardSubscription;
  final _initialCardContent = BehaviorSubject.seeded(emptyCardContent);
  final _forcedActiveCardSide =
      BehaviorSubject<Optional<CardSide>>.seeded(const Optional.absent());
  final _isLoading = BehaviorSubject.seeded(false);

  final _frontController = QuillController.basic();
  final _backController = QuillController.basic();

  Stream<UpsertCardViewModel>? _viewModel;
  Stream<UpsertCardViewModel>? get viewModel => _viewModel;

  Stream<UpsertCardViewModel> createViewModel({
    required String deckId,
    String? cardId,
    bool isFrontSide = true,
  }) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    final isEdit = cardId != null;
    if (isEdit) {
      _cardSubscription = _cardRepository
          .get(cardId!)
          .listen(_cardStream.add, onError: _cardStream.addError);

      // Use the given card to populate the front and back text.
      _cardStream.take(1).listen((card) {
        _initialCardContent.add(
          _CardContent(front: card.front!, back: card.back!),
        );
      });
    } else {
      _cardStream.add(const Card());
    }

    _forcedActiveCardSide
        .add(Optional.of(isFrontSide ? CardSide.front : CardSide.back));

    return _viewModel = Rx.combineLatest7(
      _cardStream,
      _cardStream.switchMap((c) => _deckRepository.get(c.deck?.id ?? deckId)),
      _deckRepository.getAll().map((c) => c.totalCount!),
      _initialCardContent,
      Stream.value(isEdit),
      _forcedActiveCardSide,
      _isLoading,
      _createViewModel,
    );
  }

  UpsertCardViewModel _createViewModel(
    Card card,
    Deck parentDeck,
    int totalDecksCount,
    _CardContent content,
    bool isEdit,
    Optional<CardSide> forcedActiveCardSide,
    bool isLoading,
  ) {
    if (forcedActiveCardSide.isPresent) {
      resetText(_frontController, text: content.front);
      resetText(_backController, text: content.back);

      // Wait for the new ViewModel to reach the View before updating the
      // ViewModel again.
      unawaited(Future.delayed(
        const Duration(milliseconds: 200),
        () => _forcedActiveCardSide.add(const Optional.absent()),
      ));
    }

    // We should kick-start the download of any models needed for the Smart
    // Translate feature.
    // if (_isSmartTranslationPossible(deck)) {
    // unawaited(_downloadTranslationModels(deck));
    // }

    final hasEditPermission =
        parentDeck.viewerDeckMember!.role!.hasPermission(Permission.cardUpsert);

    final isInsertMirrorCard = card.id == null && parentDeck.createMirrorCard!;
    final isUpdateMirrorCard = card.id != null && card.mirrorCard != null;

    return UpsertCardViewModel(
      backTranslation: null,
      frontTranslation: null,
      isEdit: isEdit,
      isMirrorCard: isInsertMirrorCard || isUpdateMirrorCard,
      hasEditPermission: hasEditPermission,
      isLoading: isLoading,
      forcedActiveCardSide: forcedActiveCardSide,
      onUpsertTap:
          hasEditPermission ? () => _handleUpsertTap(parentDeck, card) : null,
      onMoveTap: totalDecksCount > 1
          ? () => _handleMoveTap(parentDeck.id!, card)
          : null,
      onDeleteTap: card.id != null ? () => _handleDeleteTap(card) : null,
      frontController: _frontController,
      backController: _backController,
    );
  }

  @override
  Future<void> dispose() async {
    await _cardSubscription?.cancel();
    await _cardStream.close();
    await _initialCardContent.close();
    await _forcedActiveCardSide.close();
    _frontController.dispose();
    _backController.dispose();
    await _isLoading.close();
    super.dispose();
  }

  Future<void> _handleUpsertTap(Deck deck, Card oldCard) async {
    if (_isLoading.value) {
      return;
    }
    _isLoading.add(true);

    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    // Trim the text to remove any leading or trailing newline characters.
    var cardContent = _CardContent(
      front: deltaToMarkdown(
        jsonEncode(_frontController.document.toDelta().toJson()),
      ).trim(),
      back: deltaToMarkdown(
        jsonEncode(_backController.document.toDelta().toJson()),
      ).trim(),
    );

    if (cardContent.front.isEmpty || cardContent.back.isEmpty) {
      messenger.showErrorSnackBar(theme: theme, text: i18n.missingCardContent);
      _isLoading.add(false);

      return;
    }

    final isUpdate = oldCard.id != null;

    if (cardContent.front != oldCard.front ||
        cardContent.back != oldCard.back) {
      try {
        cardContent = await _uploadLocalImages(cardContent);

        final card = oldCard.copyWith(
          deck: deck,
          front: cardContent.front,
          back: cardContent.back,
        );

        final isInsertMirrorCard = !isUpdate && deck.createMirrorCard!;
        final isUpdateMirrorCard = isUpdate && oldCard.mirrorCard != null;
        if (isInsertMirrorCard || isUpdateMirrorCard) {
          await _cardRepository.upsertMirrorCard(card);
        } else {
          await _cardRepository.upsert(card);
        }
      } on OperationException catch (e, s) {
        return _handleOperationException(e, s, i18n, messenger, theme);
      } on TimeoutException {
        return _handleTimeoutException(i18n, messenger, theme);
      } finally {
        if (!_isLoading.isClosed) {
          _isLoading.add(false);
        }
      }
    } else {
      _isLoading.add(false);
    }

    // In case an existing card was edited, the page should be popped to return
    // to the origin.
    if (isUpdate) {
      CustomNavigator.getInstance().pop();

      return;
    }

    _initialCardContent.add(emptyCardContent);
    _forcedActiveCardSide.add(Optional.of(CardSide.front));
  }

  Future<_CardContent> _uploadLocalImages(_CardContent content) async {
    final frontUrls = _mediaHandler.getImagesURLs(content.front);
    final backUrls = _mediaHandler.getImagesURLs(content.back);
    final urls = [...frontUrls, ...backUrls];

    final filteredImageUrls = await _getUploadableImageUrls(urls);

    var updatedContent = content;
    for (final imageUrl in filteredImageUrls) {
      final remoteUrl = await _mediaHandler.uploadImage(imageUrl);
      updatedContent = _CardContent(
        front: updatedContent.front.replaceAll(imageUrl, remoteUrl),
        back: updatedContent.back.replaceAll(imageUrl, remoteUrl),
      );
    }

    return updatedContent;
  }

  /// Returns a set of image urls that point to images that should be uploaded.
  ///
  /// Whether an image should be uploaded depends on whether it is only stored
  /// locally, the file size does not exceed any limits, and the image the
  /// given path points to still exists and is supported.
  Future<Set<String>> _getUploadableImageUrls(List<String?> imageUrls) async {
    final filteredImageUrls = Set<String>.from(imageUrls);

    _mediaHandler
      ..removeS3URLs(filteredImageUrls)
      ..removeURLsToUnsupportedFiles(filteredImageUrls);
    await _mediaHandler.removeURLsToTooLargeFiles(filteredImageUrls);

    return filteredImageUrls;
  }

  Future<void> _handleMoveTap(String parentDeckId, Card card) async {
    if (_isLoading.value) {
      return;
    }

    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    final newDeck = await showDialog<Deck>(
      context: context,
      builder: (_) => SelectDeckDialogComponent(parentDeckId),
    );
    if (newDeck == null) {
      return;
    }

    _isLoading.add(true);

    try {
      await _cardRepository.upsert(card.copyWith(deck: newDeck));
    } on OperationException catch (e, s) {
      return _handleOperationException(e, s, i18n, messenger, theme);
    } on TimeoutException {
      return _handleTimeoutException(i18n, messenger, theme);
    } finally {
      _isLoading.add(false);
    }

    messenger.showSuccessSnackBar(
      theme: theme,
      text: i18n.successfullyMovedCardTo(newDeck.name),
    );
  }

  Future<void> _handleDeleteTap(Card card) async {
    if (_isLoading.value) {
      return;
    }

    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    final isUserSure = await showDialog<bool?>(
      context: context,
      builder: (_) => DeleteDialog(
        title: S.of(context).deleteCard,
        content: S.of(context).deleteCardCautionText,
      ),
    );
    if (isUserSure == null || !isUserSure) {
      return;
    }

    _isLoading.add(true);

    try {
      await _cardRepository.remove(card);
    } on OperationException catch (e, s) {
      return _handleOperationException(e, s, i18n, messenger, theme);
    } on TimeoutException {
      return _handleTimeoutException(i18n, messenger, theme);
    } finally {
      _isLoading.add(false);
    }
    CustomNavigator.getInstance().pop();
  }

  /// Resets the input of the given [controller] to only contain [text].
  ///
  /// The cursor is placed at the end of the text.
  void resetText(QuillController controller, {required String text}) {
    controller
      // The selection first needs to be reset to the beginning so that it's
      // not at an invalid position once the text gets replaced.
      ..updateSelection(
        TextSelection.fromPosition(const TextPosition(offset: 0)),
        ChangeSource.LOCAL,
      )
      // Remove all text except the new line at the end.
      ..replaceText(0, controller.document.length - 1, '', null)
      ..compose(
        Delta.fromJson(jsonDecode(markdownToDelta(text)) as List),
        const TextSelection.collapsed(offset: 0),
        ChangeSource.LOCAL,
      )
      // Position the cursor at the end of the text.
      ..updateSelection(
        TextSelection.fromPosition(
          TextPosition(offset: controller.document.length - 1),
        ),
        ChangeSource.LOCAL,
      );
  }

  void _handleOperationException(
    OperationException e,
    StackTrace s,
    S i18n,
    ScaffoldMessengerState messenger,
    ThemeData theme,
  ) {
    var exceptionText = i18n.errorUnknownText;
    if (e.isNoInternet) {
      exceptionText = i18n.errorNoInternetText;
    } else if (e.isServerOffline) {
      exceptionText = i18n.errorWeWillFixText;
    } else {
      _logger.severe('Unexpected operation exception during card upsert', e, s);
    }

    messenger.showErrorSnackBar(theme: theme, text: exceptionText);
  }

  void _handleTimeoutException(
    S i18n,
    ScaffoldMessengerState messenger,
    ThemeData theme,
  ) {
    messenger.showErrorSnackBar(theme: theme, text: i18n.errorUnknownText);
  }
}

/// Represents the plain text contents of a single card.
class _CardContent {
  const _CardContent({required this.front, required this.back});

  final String front;
  final String back;
}
