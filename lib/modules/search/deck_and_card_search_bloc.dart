import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/models/card.dart';
import '../../data/models/connection.dart';
import '../../data/models/deck.dart';
import '../../data/preferences/user_history.dart';
import '../../data/repositories/card_repository.dart';
import '../../data/repositories/deck_repository.dart';
import '../../widgets/component/component_life_cycle_listener.dart';
import 'deck_and_card_search_delegate.dart';
import 'deck_and_card_search_view_model.dart';

/// BLoC for the [DeckAndCardSearchDelegate].
@injectable
class DeckAndCardSearchBloc with ComponentLifecycleListener {
  DeckAndCardSearchBloc(
    this._deckRepository,
    this._cardRepository,
    this._userHistory,
  );

  final DeckRepository _deckRepository;
  final CardRepository _cardRepository;
  final UserHistory _userHistory;

  final _decks = BehaviorSubject<Connection<Deck>?>.seeded(null);
  final _cards = BehaviorSubject<Connection<Card>?>.seeded(null);
  String? _lastSearchTerm;

  StreamSubscription<Connection<Deck>>? _decksSubscription;
  StreamSubscription<Connection<Card>>? _cardsSubscription;

  Stream<DeckAndCardSearchViewModel>? _viewModel;
  Stream<DeckAndCardSearchViewModel>? get viewModel => _viewModel;

  Stream<DeckAndCardSearchViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest3(
      _decks,
      _cards,
      _userHistory.recentDeckAndCardsSearchTerms,
      _createViewModel,
    );
  }

  DeckAndCardSearchViewModel _createViewModel(
    Connection<Deck>? deckConnection,
    Connection<Card>? cardConnection,
    List<String> recentSearchTerms,
  ) {
    return DeckAndCardSearchViewModel(
      deckConnection: deckConnection,
      cardConnection: cardConnection,
      recentSearchTerms: recentSearchTerms,
      addSearchTerm: _addSearchTerm,
      fetchMoreDecks: () => deckConnection?.fetchMore?.call(),
      fetchMoreCards: () => cardConnection?.fetchMore?.call(),
    );
  }

  @override
  void dispose() {
    _decksSubscription?.cancel();
    _cardsSubscription?.cancel();
    _decks.close();
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

    _decksSubscription?.cancel();
    _cardsSubscription?.cancel();

    _decks.add(null);
    _cards.add(null);

    _decksSubscription = _deckRepository
        .search(query)
        .listen(_decks.add, onError: _decks.addError);
    _cardsSubscription = _cardRepository
        .search(query)
        .listen(_cards.add, onError: _cards.addError);
  }
}
