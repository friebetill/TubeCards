import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/card.dart';
import '../../../../data/models/connection.dart';
import '../../../../data/models/deck.dart';
import '../../../../data/models/offer.dart';
import '../../../../data/models/user.dart';
import '../../../../data/repositories/card_repository.dart';
import '../../../../data/repositories/deck_repository.dart';
import '../../../../data/repositories/offer_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../graphql/operation_exception.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../home/home_page.dart';
import '../../../manage_members/manage_members_page.dart';
import '../../../offer/offer_page.dart';
import '../../../upsert_deck/page/upsert_deck_page.dart';
import 'offer_preview_component.dart';
import 'offer_preview_view_model.dart';

/// BLoC for the [OfferPreviewComponent].
///
/// Exposes a [OfferPreviewViewModel] for that component to use.
@injectable
class OfferPreviewBloc with ComponentBuildContext {
  OfferPreviewBloc(
    this._userRepository,
    this._deckRepository,
    this._cardRepository,
    this._offerRepository,
  );

  final _logger = Logger((OfferPreviewBloc).toString());

  final UserRepository _userRepository;
  final DeckRepository _deckRepository;
  final CardRepository _cardRepository;
  final OfferRepository _offerRepository;

  Stream<OfferPreviewViewModel>? _viewModel;
  Stream<OfferPreviewViewModel>? get viewModel => _viewModel;

  final _isLoading = BehaviorSubject.seeded(false);

  Stream<OfferPreviewViewModel> createViewModel(String deckId) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest4(
      _userRepository.viewer(),
      _deckRepository.get(deckId),
      _cardRepository.getAll(deckId: deckId),
      _isLoading,
      _createViewModel,
    );
  }

  OfferPreviewViewModel _createViewModel(
    User? viewer,
    Deck deck,
    Connection<Card> cardConnection,
    bool isLoading,
  ) {
    return OfferPreviewViewModel(
      deckName: deck.name!,
      description: deck.description!,
      coverImageUrl: deck.coverImage!.regularUrl!,
      cardSamples: BuiltList(cardConnection.nodes!.take(5)),
      cardsCount: cardConnection.totalCount!,
      creator: viewer!,
      isLoading: isLoading,
      onEditTap: () => _handleEditTap(deck.id!),
      onPublishTap: () => _handlePublishTap(deck.id!),
    );
  }

  void _handleEditTap(String deckId) {
    CustomNavigator.getInstance().pushNamed(
      UpsertDeckPage.routeNameEdit,
      args: deckId,
    );
  }

  Future<void> _handlePublishTap(String deckID) async {
    if (_isLoading.value) {
      return;
    }

    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    Offer? upsertedOffer;

    _isLoading.add(true);
    try {
      upsertedOffer = await _offerRepository.addOffer(deckID);
    } on OperationException catch (e, s) {
      _handleOperationException(i18n, messenger, theme, e, s);
    } on TimeoutException {
      messenger.showErrorSnackBar(theme: theme, text: i18n.errorUnknownText);
    } on Exception catch (e, s) {
      _logger.severe('Unexpected exception during adding an offer', e, s);
      messenger.showErrorSnackBar(theme: theme, text: i18n.errorUnknownText);
    } finally {
      _isLoading.add(false);
    }

    if (upsertedOffer == null) {
      return;
    }

    await CustomNavigator.getInstance().pushNamedAndRemoveUntil(
      OfferPage.routeName,
      (route) =>
          route is ModalRoute &&
          (route.settings.name == HomePage.routeName ||
              route.settings.name == ManageMembersPage.routeName),
      args: upsertedOffer.id,
    );
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
      _logger.severe('Operation exception during adding an offer', e, s);
    }

    messenger.showErrorSnackBar(theme: theme, text: exceptionText);
  }
}
