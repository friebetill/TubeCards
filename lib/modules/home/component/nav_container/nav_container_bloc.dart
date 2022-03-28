import 'dart:async';

import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/connection.dart';
import '../../../../data/models/deck.dart';
import '../../../../data/models/user.dart';
import '../../../../data/repositories/card_repository.dart';
import '../../../../data/repositories/deck_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../graphql/operation_exception.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import '../../../account/account_page.dart';
import '../../../import_export/import_export_page.dart';
import '../../../join_shared_deck/join_shared_deck_page.dart';
import '../../../offer_search/component/offer_search/offer_search_delegate.dart';
import '../../../search/deck_and_card_search_delegate.dart';
import '../../../upsert_deck/page/upsert_deck_page.dart';
import 'nav_container_component.dart';
import 'nav_container_view_model.dart';

/// BLoC for the [NavContainerComponent].
///
/// Exposes a [NavContainerViewModel] for that component to use.
@injectable
class NavContainerBloc with ComponentBuildContext, ComponentLifecycleListener {
  NavContainerBloc(
    this._userRepository,
    this._deckRepository,
    this._cardRepository,
  );

  final UserRepository _userRepository;
  final DeckRepository _deckRepository;
  final CardRepository _cardRepository;

  final _logger = Logger((NavContainerBloc).toString());

  Stream<NavContainerViewModel>? _viewModel;
  Stream<NavContainerViewModel>? get viewModel => _viewModel;

  final _isLoading = BehaviorSubject.seeded(false);

  Stream<NavContainerViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest3(
      _userRepository.viewer(),
      _deckRepository.getAll(fetchPolicy: FetchPolicy.CacheAndNetwork),
      _isLoading,
      _createViewModel,
    );
  }

  NavContainerViewModel _createViewModel(
    User? user,
    Connection<Deck> deckConnection,
    bool isLoading,
  ) {
    return NavContainerViewModel(
      user: user!,
      isLoading: isLoading,
      onAddDeckTap: () =>
          CustomNavigator.getInstance().pushNamed(UpsertDeckPage.routeNameAdd),
      onAccountTap: () =>
          CustomNavigator.getInstance().pushNamed(AccountPage.routeName),
      onSearchTap: () => showSearch(
        context: context,
        delegate: DeckAndCardSearchDelegate(),
      ),
      onSearchOfferTap: () => showSearch(
        context: context,
        delegate: OfferSearchDelegate(),
      ),
      onRefreshTap: _handleRefreshTap,
      onImportTap: () =>
          CustomNavigator.getInstance().pushNamed(ImportExportPage.routeName),
      onJoinDeckTap: () =>
          CustomNavigator.getInstance().pushNamed(JoinSharedDeckPage.routeName),
    );
  }

  @override
  void dispose() {
    _isLoading.close();
    super.dispose();
  }

  Future<void> _handleRefreshTap() async {
    _isLoading.add(true);

    final i18n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    try {
      await Future.wait([
        _deckRepository.getAll(fetchPolicy: FetchPolicy.NetworkOnly).first,
        _deckRepository
            .getAll(fetchPolicy: FetchPolicy.NetworkOnly, isActive: false)
            .first,
        _cardRepository.getAll(fetchPolicy: FetchPolicy.NetworkOnly).first,
        _cardRepository.getDueCards(fetchPolicy: FetchPolicy.NetworkOnly).first,
      ]);
    } on OperationException catch (e, s) {
      var exceptionText = i18n.errorUnknownText;
      if (e.isNoInternet) {
        exceptionText = i18n.errorNoInternetText;
      } else if (e.isServerOffline) {
        exceptionText = i18n.errorWeWillFixText;
      } else {
        _logger.severe('Operation exception during home page refresh', e, s);
      }

      messenger.showErrorSnackBar(theme: theme, text: exceptionText);
    } finally {
      if (!_isLoading.isClosed) {
        _isLoading.add(false);
      }
    }
  }
}
