import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/connection.dart';
import '../../../../data/models/offer.dart';
import '../../../../data/preferences/user_history.dart';
import '../../../../data/repositories/offer_repository.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import 'offer_search_delegate.dart';
import 'offer_search_view_model.dart';

/// BLoC for the [OfferSearchDelegate].
@injectable
class OfferSearchBloc with ComponentLifecycleListener {
  OfferSearchBloc(this._offerRepository, this._userHistory);

  final OfferRepository _offerRepository;
  final UserHistory _userHistory;

  final _offers = BehaviorSubject<Connection<Offer>?>.seeded(null);
  String? _lastSearchTerm;

  StreamSubscription<Connection<Offer>>? _offersSubscription;

  Stream<OfferSearchViewModel>? _viewModel;
  Stream<OfferSearchViewModel>? get viewModel => _viewModel;

  Stream<OfferSearchViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest2(
      _offers,
      _userHistory.recentOfferSearchTerms,
      _createViewModel,
    );
  }

  OfferSearchViewModel _createViewModel(
    Connection<Offer>? offerConnection,
    List<String> recentSearchTerms,
  ) {
    return OfferSearchViewModel(
      offerConnection: offerConnection,
      recentSearchTerms: recentSearchTerms,
      addSearchTerm: _addSearchTerm,
      fetchMoreOffers: () => offerConnection?.fetchMore?.call(),
    );
  }

  @override
  void dispose() {
    _offersSubscription?.cancel();
    _offers.close();
    super.dispose();
  }

  void _addSearchTerm(String query) {
    /// We need to check whether the user submitted a new search request.
    /// Unfortunately, there is no [onSearch] callback that could be used
    /// in order to be notified about each search event. Checking against
    /// the last search term is a work around to ensure that the same search
    /// term is not added multiple times since [buildResults] can be called
    /// more than once for the same search term.
    if (query == _lastSearchTerm) {
      return;
    }

    _lastSearchTerm = query;
    _userHistory.addRecentOfferSearchTerm(query);

    _offersSubscription?.cancel();

    _offers.add(null);

    _offersSubscription = _offerRepository
        .search(query)
        .listen(_offers.add, onError: _offers.addError);
  }
}
