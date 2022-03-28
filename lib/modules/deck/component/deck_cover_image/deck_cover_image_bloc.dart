import 'package:injectable/injectable.dart';

import '../../../../data/models/deck.dart';
import '../../../../data/repositories/deck_repository.dart';
import 'deck_cover_image_component.dart';
import 'deck_cover_image_view_model.dart';

/// BLoC for the [DeckCoverImageComponent].
///
/// Exposes a [DeckCoverImageViewModel] for that component to use.
@injectable
class DeckCoverImageBloc {
  DeckCoverImageBloc(this._deckRepository);

  final DeckRepository _deckRepository;

  Stream<DeckCoverImageViewModel>? _viewModel;
  Stream<DeckCoverImageViewModel>? get viewModel => _viewModel;

  Stream<DeckCoverImageViewModel> createViewModel({required String deckId}) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = _deckRepository.get(deckId).map(_createViewModel);
  }

  DeckCoverImageViewModel _createViewModel(Deck deck) {
    return DeckCoverImageViewModel(
      deckId: deck.id!,
      coverImageUrl: deck.coverImage!.regularUrl!,
    );
  }
}
