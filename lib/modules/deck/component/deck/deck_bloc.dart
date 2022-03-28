import 'package:built_collection/built_collection.dart';
import 'package:ferry/ferry.dart';
import 'package:injectable/injectable.dart';
import 'package:recase/recase.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/average_learning_state.dart';
import '../../../../data/models/card.dart';
import '../../../../data/models/connection.dart';
import '../../../../data/models/deck.dart';
import '../../../../data/repositories/card_repository.dart';
import '../../../../data/repositories/deck_repository.dart';
import '../../../../data/repositories/marked_cards_repository.dart';
import '../../../../data/repositories/review_session_repository.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/permission.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../manage_members/manage_members_page.dart';
import '../../../review/review_page.dart';
import '../../../upsert_deck/page/upsert_deck_page.dart';
import '../../deck_page.dart';
import 'deck_component.dart';
import 'deck_view_model.dart';

/// BLoC for the [DeckComponent].
///
/// Exposes a [DeckViewModel] for that component to use.
@injectable
class DeckBloc with ComponentBuildContext {
  DeckBloc(
    this._deckRepository,
    this._cardRepository,
    this._markedCardsRepository,
    this._reviewSessionRepository,
  );

  final DeckRepository _deckRepository;
  final CardRepository _cardRepository;
  final MarkedCardsRepository _markedCardsRepository;
  final ReviewSessionRepository _reviewSessionRepository;

  late ValueStream<Connection<Card>> _dueCardConnection;
  late ValueStream<Connection<Card>> _allCardConnection;

  Stream<DeckViewModel>? _viewModel;
  Stream<DeckViewModel>? get viewModel => _viewModel;

  Stream<DeckViewModel> createViewModel(DeckArguments args) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    _dueCardConnection = _cardRepository
        .getDueCardsOfDeck(
          deckId: args.deckId,
          fetchPolicy: FetchPolicy.CacheAndNetwork,
        )
        .shareValue();
    _allCardConnection = _cardRepository
        .getAll(deckId: args.deckId, fetchPolicy: FetchPolicy.CacheAndNetwork)
        .shareValue();

    return _viewModel = Rx.combineLatest6(
      _deckRepository.get(
        args.deckId,
        fetchPolicy: FetchPolicy.CacheAndNetwork,
      ),
      _deckRepository.getLearningState(
        args.deckId,
        fetchPolicy: FetchPolicy.CacheAndNetwork,
      ),
      _dueCardConnection,
      _allCardConnection,
      Stream.value(args.hasCardUpsertPermission),
      _markedCardsRepository.get(),
      _createViewModel,
    );
  }

  DeckViewModel _createViewModel(
    Deck deck,
    AverageLearningState learningState,
    Connection<Card> dueCardConnection,
    Connection<Card> allCardConnection,
    bool hasCardUpsertPermission,
    BuiltList<String> markedCardsIds,
  ) {
    return DeckViewModel(
      id: deck.id!,
      hasCards: allCardConnection.totalCount! > 0,
      strength: learningState.strength!,
      totalDueCardsCount: deck.dueCardConnection!.totalCount!,
      totalCardsCount: allCardConnection.totalCount!,
      hasCardUpsertPermission: hasCardUpsertPermission,
      onEditTap: () => _handleEditTap(deck),
      onBackTap: () => _handleBackTap(markedCardsIds),
      onLearnTap: dueCardConnection.totalCount! > 0
          ? () => _handleLearnTap(deck.id!)
          : null,
      onPracticeTap:
          allCardConnection.totalCount! > 0 ? _handlePracticeTap : null,
      onManageMembersTap:
          deck.viewerDeckMember!.role!.hasPermission(Permission.deckMemberGet)
              ? () => _handleManageMembersTap(deck.id!)
              : null,
    );
  }

  void _handleEditTap(Deck deck) {
    CustomNavigator.getInstance().pushNamed(
      UpsertDeckPage.routeNameEdit,
      args: deck.id,
    );
  }

  void _handleManageMembersTap(String deckID) {
    CustomNavigator.getInstance()
        .pushNamed(ManageMembersPage.routeName, args: deckID);
  }

  void _handleBackTap(BuiltList<String> markedCardsIds) {
    if (markedCardsIds.isEmpty) {
      CustomNavigator.getInstance().pop();
    } else {
      _markedCardsRepository.clear();
    }
  }

  /// Navigates to the [ReviewPage] screen where the user can learn.
  Future<void> _handleLearnTap(String deckId) async {
    _reviewSessionRepository.createSession(
      connectionStream: _dueCardConnection,
      dryRun: false,
      title: S.of(context).dueCards.titleCase,
      loadLearningState: () {
        return _deckRepository
            .getLearningState(deckId, fetchPolicy: FetchPolicy.NetworkOnly)
            .first;
      },
    );
    await CustomNavigator.getInstance().pushNamed(ReviewPage.routeName);
  }

  /// Navigates to the [ReviewPage] screen where cards can be practised.
  ///
  /// The order of the cards will be shuffled before learning. The learn mode
  /// will be set to a dry run which means that the repetitions will not be
  /// recorded.
  Future<void> _handlePracticeTap() async {
    _reviewSessionRepository.createSession(
      connectionStream: _allCardConnection,
      dryRun: true,
      title: S.of(context).learnAllCards.titleCase,
      loadLearningState: null,
    );
    await CustomNavigator.getInstance().pushNamed(ReviewPage.routeName);
  }
}
