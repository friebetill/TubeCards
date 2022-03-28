import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/connection.dart';
import '../../../../data/models/deck.dart';
import '../../../../data/repositories/deck_repository.dart';
import '../../../../utils/permission.dart';
import 'select_deck_dialog_view_model.dart';

@injectable
class SelectDeckDialogBloc {
  SelectDeckDialogBloc(this._deckRepository);

  final DeckRepository _deckRepository;

  Stream<SelectDeckDialogViewModel>? _viewModel;
  Stream<SelectDeckDialogViewModel>? get viewModel => _viewModel;

  Stream<SelectDeckDialogViewModel> createViewModel(String excludedDeckId) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest2(
      Stream.value(excludedDeckId),
      _deckRepository.getAll(),
      _createViewModel,
    );
  }

  SelectDeckDialogViewModel _createViewModel(
    String excludedDeckId,
    Connection<Deck> connection,
  ) {
    final decks = connection.nodes!.rebuild(
      (b) => b.removeWhere((d) =>
          d.id == excludedDeckId ||
          !d.viewerDeckMember!.role!.hasPermission(Permission.cardUpsert)),
    );

    return SelectDeckDialogViewModel(
      fetchMore: connection.fetchMore!,
      showLoadingIndicator: connection.pageInfo!.hasNextPage!,
      decks: decks,
    );
  }
}
