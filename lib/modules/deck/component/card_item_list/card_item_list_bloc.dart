import 'package:ferry/ferry.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/card.dart';
import '../../../../data/models/connection.dart';
import '../../../../data/preferences/preferences.dart';
import '../../../../data/repositories/card_repository.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import 'card_item_list_component.dart';
import 'card_item_list_view_model.dart';

/// BLoC for the [CardItemListComponent].
///
/// Exposes a [CardItemListViewModel] for that component to use.
@injectable
class CardItemListBloc with ComponentLifecycleListener {
  CardItemListBloc(this._cardRepository, this._preferences);

  final CardRepository _cardRepository;
  final Preferences _preferences;

  /// Stream that returns true when the cards are initially loaded
  ///
  /// Includes the initial loading when the sort order is changed and the
  /// cards weren't previously downloaded in this sort order.
  final _isLoadingInitialData = BehaviorSubject.seeded(true);

  /// Returns true when more cards are loaded
  ///
  /// This happens when a new card connection page is loaded.
  bool _isLoadingContinuations = false;

  Stream<CardItemListViewModel>? _viewModel;
  Stream<CardItemListViewModel>? get viewModel => _viewModel;

  Stream<CardItemListViewModel> createViewModel(String deckId) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    final cardConnection = _preferences.cardsSortOrder.switchMap((sortOrder) {
      _isLoadingInitialData.add(true);

      return _cardRepository
          .getAll(
        deckId: deckId,
        fetchPolicy: FetchPolicy.CacheAndNetwork,
        sortOrder: sortOrder,
      )
          .doOnData((_) {
        if (_isLoadingInitialData.value) {
          _isLoadingInitialData.add(false);
        }
      });
    });

    return _viewModel = Rx.combineLatest2(
      cardConnection,
      _isLoadingInitialData,
      _createViewModel,
    );
  }

  CardItemListViewModel _createViewModel(
    Connection<Card> connection,
    bool isLoadingInitialData,
  ) {
    return CardItemListViewModel(
      cards: connection.nodes!,
      showInitialLoadingIndicator: isLoadingInitialData,
      showContinuationsLoadingIndicator: connection.pageInfo!.hasNextPage!,
      fetchMore: () => _fetchMore(connection),
    );
  }

  @override
  void dispose() {
    _isLoadingInitialData.close();
    super.dispose();
  }

  Future<void> _fetchMore(Connection<Card> connection) async {
    if (connection.pageInfo!.hasNextPage! && !_isLoadingContinuations) {
      _isLoadingContinuations = true;
      await connection.fetchMore!();
      _isLoadingContinuations = false;
    }
  }
}
