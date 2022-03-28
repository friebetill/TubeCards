import 'package:injectable/injectable.dart';

import '../../../../data/models/deck.dart';
import '../../../../data/repositories/deck_repository.dart';
import '../../../../utils/custom_navigator.dart';
import 'manage_members_viewmodel.dart';

/// BLoC for the [ManageMembersComponent].
///
/// Exposes a [ManageMembersViewModel] for that component to use.
@injectable
class ManageMembersBloc {
  ManageMembersBloc(this._deckRepository);

  final DeckRepository _deckRepository;

  Stream<ManageMembersViewModel>? _viewModel;
  Stream<ManageMembersViewModel>? get viewModel => _viewModel;

  Stream<ManageMembersViewModel> createViewModel(String deckId) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = _deckRepository.get(deckId).map(_createViewModel);
  }

  ManageMembersViewModel _createViewModel(Deck deck) {
    return ManageMembersViewModel(
      deck: deck,
      userRole: deck.viewerDeckMember!.role!,
      onBackTap: CustomNavigator.getInstance().pop,
    );
  }
}
