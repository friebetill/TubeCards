import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/card.dart';
import '../../../../data/models/connection.dart';
import '../../../../data/models/deck.dart';
import '../../../../data/repositories/card_repository.dart';
import '../../../../data/repositories/deck_repository.dart';
import '../../../../data/repositories/marked_cards_repository.dart';
import '../../../../graphql/operation_exception.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/permission.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import '../../../offer/offer_page.dart';
import '../delete_dialog.dart';
import '../select_deck_dialog/select_deck_dialog_component.dart';
import 'app_bar_view_model.dart';

@injectable
class AppBarBloc with ComponentBuildContext, ComponentLifecycleListener {
  AppBarBloc(
    this._deckRepository,
    this._cardRepository,
    this._markedCardsRepository,
  );

  final DeckRepository _deckRepository;
  final CardRepository _cardRepository;
  final MarkedCardsRepository _markedCardsRepository;

  final _logger = Logger((AppBarBloc).toString());

  Stream<AppBarViewModel>? _viewModel;
  Stream<AppBarViewModel>? get viewModel => _viewModel;

  late BehaviorSubject<bool> _showDeleteLoadingIndicator;
  late BehaviorSubject<bool> _showPopupMenuLoadingIndicator;

  Stream<AppBarViewModel> createViewModel(
    String deckId,
    VoidCallback? onEditTap,
    VoidCallback? onManageMembersTap,
  ) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    _showDeleteLoadingIndicator = BehaviorSubject.seeded(false);
    _showPopupMenuLoadingIndicator = BehaviorSubject.seeded(false);

    return _viewModel = Rx.combineLatest8(
      Stream.value(onEditTap),
      Stream.value(onManageMembersTap),
      Stream.value(deckId),
      _deckRepository.get(deckId),
      _deckRepository.getAll(),
      _markedCardsRepository.get(),
      _showDeleteLoadingIndicator,
      _showPopupMenuLoadingIndicator,
      _createViewModel,
    );
  }

  AppBarViewModel _createViewModel(
    VoidCallback? onEditTap,
    VoidCallback? onManageMembersTap,
    String deckId,
    Deck deck,
    Connection<Deck> deckConnection,
    BuiltList<String> markedCardsIds,
    bool showDeleteLoadingIndicator,
    bool showPopUpMenuLoadingIndicator,
  ) {
    final hasUpdateDeckPermission =
        deck.viewerDeckMember!.role!.hasPermission(Permission.deckUpdate);
    final hasUpdateCardPermission =
        deck.viewerDeckMember!.role!.hasPermission(Permission.cardUpsert);
    final hasDeleteCardPermission =
        deck.viewerDeckMember!.role!.hasPermission(Permission.cardDelete);

    return AppBarViewModel(
      deckName: deck.name!,
      decksCount: deckConnection.totalCount!,
      markedCardsIds: markedCardsIds,
      showDeleteLoadingIndicator: showDeleteLoadingIndicator,
      showPopupMenuLoadingIndicator: showPopUpMenuLoadingIndicator,
      hasEditDeckPermission: hasUpdateDeckPermission,
      hasEditCardPermission: hasUpdateCardPermission,
      hasDeleteCardPermission: hasDeleteCardPermission,
      onManageMembersTap: onManageMembersTap,
      onOfferTap: deck.offer?.id != null
          ? () => _handleOfferTap(deck.offer!.id!)
          : null,
      onMoveTap: () => _handleMoveMarkedCards(markedCardsIds, deckId),
      onDeleteTap: () => _handleDeleteMarkedCardsTap(markedCardsIds),
      // Set this callback to null if appropriate to fix the swipe back gesture
      // on iOS, see https://bit.ly/3oagWUu for details.
      onSettingsTap: onEditTap,
      onBackTap: () => _handleBackTap(markedCardsIds),
      onWillPop:
          markedCardsIds.isEmpty ? null : () => _handleWillPop(markedCardsIds),
    );
  }

  @override
  void dispose() {
    _showDeleteLoadingIndicator.close();
    _showPopupMenuLoadingIndicator.close();
    super.dispose();
  }

  void _handleBackTap(BuiltList<String> markedCardsIds) {
    if (markedCardsIds.isEmpty) {
      CustomNavigator.getInstance().pop();
    } else {
      _markedCardsRepository.clear();
    }
  }

  void _handleOfferTap(String offerId) {
    CustomNavigator.getInstance().pushNamed(OfferPage.routeName, args: offerId);
  }

  Future<void> _handleMoveMarkedCards(
    BuiltList<String> markedCardsIds,
    String deckId,
  ) async {
    if (_isLoading()) {
      return;
    }

    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    final newDeck = await showDialog<Deck>(
      context: context,
      builder: (context) => SelectDeckDialogComponent(deckId),
    );
    if (newDeck == null) {
      return;
    }

    _showPopupMenuLoadingIndicator.add(true);

    var success = false;
    try {
      final futures = <Future>[];
      for (final id in markedCardsIds) {
        var card = await _cardRepository
            .get(id, fetchPolicy: FetchPolicy.CacheOnly)
            .first;
        card = card.copyWith(deck: newDeck);
        if (card.mirrorCard != null) {
          futures.add(_cardRepository.upsertMirrorCard(card));
        } else {
          futures.add(_cardRepository.upsert(card));
        }
      }
      await Future.wait(futures);
      success = true;
    } on OperationException catch (e, s) {
      _handleOperationException(i18n, messenger, theme, e, s);
    } on TimeoutException {
      _handleTimeoutException(i18n, messenger, theme);
    } on Exception catch (e, s) {
      _logger.severe('Unexpected exception during moving cards', e, s);
      messenger.showErrorSnackBar(
        theme: theme,
        text: i18n.errorUnknownText,
      );
    } finally {
      _showPopupMenuLoadingIndicator.add(false);
    }

    if (success) {
      messenger.showSuccessSnackBar(
        theme: theme,
        text: markedCardsIds.length == 1
            ? i18n.successfullyMovedCardTo(newDeck.name)
            : i18n.successfullyMovedCardsTo(newDeck.name),
      );
      _markedCardsRepository.clear();
    }
  }

  Future<void> _handleDeleteMarkedCardsTap(
    BuiltList<String> markedCardsIds,
  ) async {
    if (_isLoading()) {
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

    _showDeleteLoadingIndicator.add(true);

    var success = false;
    try {
      final futures = <Future>[];
      for (final id in markedCardsIds) {
        futures.add(_cardRepository.remove(Card(id: id)));
      }
      await Future.wait(futures);
      success = true;
    } on OperationException catch (e, s) {
      _handleOperationException(i18n, messenger, theme, e, s);
    } on TimeoutException {
      _handleTimeoutException(i18n, messenger, theme);
    } on Exception catch (e, s) {
      _logger.severe('Unexpected exception during card deletion', e, s);
      messenger.showErrorSnackBar(
        theme: theme,
        text: i18n.errorUnknownText,
      );
    } finally {
      _showDeleteLoadingIndicator.add(false);
    }

    if (success) {
      messenger.showSuccessSnackBar(
        theme: theme,
        text: markedCardsIds.length == 1
            ? i18n.successfullyDeletedCard
            : i18n.successfullyDeletedCards,
      );
      _markedCardsRepository.clear();
    }
  }

  bool _isLoading() {
    return _showPopupMenuLoadingIndicator.value ||
        _showDeleteLoadingIndicator.value;
  }

  void _handleOperationException(
    S i18n,
    ScaffoldMessengerState messenger,
    ThemeData theme,
    OperationException e,
    StackTrace s,
  ) {
    var exceptionText = i18n.errorUnknownText;
    if (e.isNoInternet) {
      exceptionText = i18n.errorNoInternetText;
    } else if (e.isServerOffline) {
      exceptionText = i18n.errorWeWillFixText;
    } else {
      _logger.severe('Operation exception during card moving/deletion', e, s);
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

  /// Resolves to true, when the enclosing route should be popped.
  Future<bool> _handleWillPop(BuiltList<String> markedCardsIds) async {
    if (markedCardsIds.isEmpty) {
      return true;
    }

    _markedCardsRepository.clear();

    return false;
  }
}
