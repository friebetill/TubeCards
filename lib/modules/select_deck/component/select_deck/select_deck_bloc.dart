import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/connection.dart';
import '../../../../data/models/deck.dart';
import '../../../../data/models/role.dart';
import '../../../../data/models/user.dart';
import '../../../../data/repositories/deck_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../offer_preview/offer_preview_page.dart';
import '../../../sign_up/sign_up_page.dart';
import 'select_deck_component.dart';
import 'select_deck_view_model.dart';

/// BLoC for the [SelectDeckComponent].
///
/// Exposes a [SelectDeckViewModel] for that component to use.
@injectable
class SelectDeckBloc {
  SelectDeckBloc(this._userRepository, this._deckRepository);

  final DeckRepository _deckRepository;
  final UserRepository _userRepository;

  Stream<SelectDeckViewModel>? _viewModel;
  Stream<SelectDeckViewModel>? get viewModel => _viewModel;

  Stream<SelectDeckViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest2(
      _userRepository.viewer(),
      _deckRepository.getAll(
          roleID: Role.owner.id, isPublic: false, isActive: null),
      _createViewModel,
    );
  }

  SelectDeckViewModel _createViewModel(
    User? viewer,
    Connection<Deck> deckConnection,
  ) {
    final navigator = CustomNavigator.getInstance();

    return SelectDeckViewModel(
      isAnonymous: viewer!.isAnonymous!,
      decks: deckConnection.nodes!,
      onDeckSelect: (deck) {
        navigator.pushNamed(OfferPreviewPage.routeName, args: deck.id);
      },
      onCreateAccountTap: () => navigator.pushNamed(SignUpPage.routeName),
    );
  }
}
