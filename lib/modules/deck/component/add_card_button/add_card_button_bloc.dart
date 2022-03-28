import 'package:injectable/injectable.dart';

import '../../../../data/models/deck.dart';
import '../../../../data/repositories/deck_repository.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../upsert_card/upsert_card_page.dart';
import 'add_card_button_component.dart';
import 'add_card_button_view_model.dart';

/// BLoC for the [AddCardButtonComponent].
///
/// Exposes a [AddCardButtonViewModel] for that component to use.
@injectable
class AddCardButtonBloc with ComponentBuildContext {
  AddCardButtonBloc(this._deckRepository);

  final DeckRepository _deckRepository;

  Stream<AddCardButtonViewModel>? _viewModel;
  Stream<AddCardButtonViewModel>? get viewModel => _viewModel;

  Stream<AddCardButtonViewModel> createViewModel({required String deckId}) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = _deckRepository.get(deckId).map(_createViewModel);
  }

  AddCardButtonViewModel _createViewModel(Deck deck) {
    return AddCardButtonViewModel(
      buttonText: deck.createMirrorCard!
          ? S.of(context).addBidirectionalCard
          : S.of(context).addCard,
      onPressed: () => _navigateToUpsertCardScreen(deck.id!),
    );
  }

  void _navigateToUpsertCardScreen(String deckId) {
    CustomNavigator.getInstance().pushNamed(
      UpsertCardPage.routeNameAdd,
      args: UpsertCardArguments(deckId: deckId),
    );
  }
}
