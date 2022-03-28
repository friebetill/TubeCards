import 'dart:async';

import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/deck.dart';
import '../../../../data/models/offer.dart';
import '../../../../data/models/role.dart';
import '../../../../data/models/user.dart';
import '../../../../data/repositories/offer_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../graphql/operation_exception.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/permission.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import '../../../deck/deck_page.dart';
import 'offer_view_model.dart';

/// BLoC for the [OfferComponent].
///
/// Exposes a [OfferViewModel] for that component to use.
@injectable
class OfferBloc with ComponentBuildContext, ComponentLifecycleListener {
  OfferBloc(this._offerRepository, this._userRepository);

  final OfferRepository _offerRepository;
  final UserRepository _userRepository;

  Stream<OfferViewModel>? _viewModel;
  Stream<OfferViewModel>? get viewModel => _viewModel;

  final _logger = Logger((OfferBloc).toString());

  final _isSubscribeLoading = BehaviorSubject.seeded(false);
  final _isUnsubscribeLoading = BehaviorSubject.seeded(false);
  final _isDeleteOfferLoading = BehaviorSubject.seeded(false);

  Stream<OfferViewModel> createViewModel(String offerId) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest5(
      _offerRepository.get(offerId, fetchPolicy: FetchPolicy.CacheAndNetwork),
      _userRepository.viewer(),
      _isSubscribeLoading,
      _isUnsubscribeLoading,
      _isDeleteOfferLoading,
      _createViewModel,
    );
  }

  OfferViewModel _createViewModel(
    Offer offer,
    User? viewer,
    bool isSubscribeLoading,
    bool isUnsubscribeLoading,
    bool isDeleteLoading,
  ) {
    final viewerRole = offer.deck!.viewerDeckMember?.role;

    return OfferViewModel(
      deck: offer.deck!,
      offer: offer,
      viewer: viewer!,
      creator: offer.creator!,
      isSubscribeLoading: isSubscribeLoading,
      isUnsubscribeLoading: isUnsubscribeLoading,
      isDeleteLoading: isDeleteLoading,
      onSubscribeTap: offer.deck?.viewerDeckMember?.role == null
          ? () => _handleSubscribeTap(offer.id!)
          : null,
      onUnsubscribeTap: offer.deck?.viewerDeckMember?.role == Role.subscriber
          ? () => _handleUnsubscribeTap(offer.id!)
          : null,
      onOpenTap: offer.deck?.viewerDeckMember?.role != null
          ? () => _handleOpenTap(offer.deck!)
          : null,
      showRateOffer: offer.hasViewerBought!,
      onDeleteOfferTap:
          viewerRole != null && viewerRole.hasPermission(Permission.offerDelete)
              ? () => _handleDeleteOfferTap(offer.id!)
              : null,
    );
  }

  @override
  void dispose() {
    _isSubscribeLoading.close();
    _isUnsubscribeLoading.close();
    _isDeleteOfferLoading.close();
    super.dispose();
  }

  Future<void> _handleSubscribeTap(String offerId) async {
    if (_isLoading()) {
      return;
    }

    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    _isSubscribeLoading.add(true);
    try {
      await _offerRepository.subscribe(offerId);
    } on OperationException catch (e, s) {
      _handleOperationException(i18n, messenger, theme, e, s);
    } on TimeoutException {
      messenger.showErrorSnackBar(theme: theme, text: i18n.errorUnknownText);
    } on Exception catch (e, s) {
      _logger.severe('Unexpected exception during subscribing offer', e, s);
      messenger.showErrorSnackBar(theme: theme, text: i18n.errorUnknownText);
    } finally {
      _isSubscribeLoading.add(false);
    }
  }

  Future<void> _handleUnsubscribeTap(String offerId) async {
    if (_isLoading()) {
      return;
    }

    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    _isUnsubscribeLoading.add(true);
    try {
      await _offerRepository.unsubscribe(offerId);
    } on OperationException catch (e, s) {
      _handleOperationException(i18n, messenger, theme, e, s);
    } on TimeoutException {
      messenger.showErrorSnackBar(theme: theme, text: i18n.errorUnknownText);
    } on Exception catch (e, s) {
      _logger.severe('Unexpected exception during unsubscribing offer', e, s);
      messenger.showErrorSnackBar(theme: theme, text: i18n.errorUnknownText);
    } finally {
      _isUnsubscribeLoading.add(false);
    }
  }

  void _handleOpenTap(Deck deck) {
    CustomNavigator.getInstance().pushNamed(
      DeckPage.routeName,
      args: DeckArguments(
        deckId: deck.id!,
        hasCardUpsertPermission:
            deck.viewerDeckMember!.role!.hasPermission(Permission.cardUpsert),
      ),
    );
  }

  Future<void> _handleDeleteOfferTap(String offerID) async {
    if (_isLoading()) {
      return;
    }

    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    _isDeleteOfferLoading.add(true);
    try {
      await _offerRepository.deleteOffer(offerID);
      CustomNavigator.getInstance().pop();
    } on OperationException catch (e, s) {
      _handleOperationException(i18n, messenger, theme, e, s);
    } on TimeoutException {
      messenger.showErrorSnackBar(theme: theme, text: i18n.errorUnknownText);
    } on Exception catch (e, s) {
      _logger.severe('Unexpected exception during offer deletion', e, s);
      messenger.showErrorSnackBar(theme: theme, text: i18n.errorUnknownText);
    } finally {
      _isDeleteOfferLoading.add(false);
    }
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
      _logger.severe('Exception during subscribe/unsubcribe offer', e, s);
    }

    messenger.showErrorSnackBar(theme: theme, text: exceptionText);
  }

  bool _isLoading() {
    return _isSubscribeLoading.value ||
        _isUnsubscribeLoading.value ||
        _isDeleteOfferLoading.value;
  }
}
