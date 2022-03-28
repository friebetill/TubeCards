import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/card.dart';
import '../../../../data/models/connection.dart';
import '../../../../data/preferences/user_history.dart';
import '../../../../data/repositories/card_repository.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import 'card_search_view_model.dart';

/// BLoC for the [DeckAndCardSearchDelegate].
@injectable
class CardSearchBloc with ComponentLifecycleListener {
  CardSearchBloc(this._cardRepository, this._userHistory);

  final CardRepository _cardRepository;
  final UserHistory _userHistory;

  final _cards = BehaviorSubject<Connection<Card>?>.seeded(null);
  String? _lastSearchTerm;
  late String _deckId;

  StreamSubscription<Connection<Card>>? _cardsSubscription;

  Stream<CardSearchViewModel>? _viewModel;
  Stream<CardSearchViewModel>? get viewModel => _viewModel;

  Stream<CardSearchViewModel> createViewModel(String deckId) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    _deckId = deckId;

    return _viewModel = Rx.combineLatest2(
      _cards,
      _userHistory.recentDeckAndCardsSearchTerms,
      _createViewModel,
    );
  }

  CardSearchViewModel _createViewModel(
    Connection<Card>? cardConnection,
    List<String> recentSearchTerms,
  ) {
    return CardSearchViewModel(
      cardConnection: cardConnection,
      recentSearchTerms: recentSearchTerms,
      addSearchTerm: _addSearchTerm,
      fetchMoreCards: () => cardConnection?.fetchMore?.call(),
    );
  }

  @override
  void dispose() {
    _cardsSubscription?.cancel();
    _cards.close();
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
    _userHistory.addRecentSearchTerm(query);

    _cardsSubscription?.cancel();

    _cards.add(null);

    _cardsSubscription = _cardRepository
        .search(query, deckId: _deckId)
        .listen(_cards.add, onError: _cards.addError);
  }
}
