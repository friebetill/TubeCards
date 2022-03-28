import 'package:built_collection/built_collection.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/card.dart';
import '../../../../data/repositories/marked_cards_repository.dart';
import '../../../../utils/card_utils.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../upsert_card/upsert_card_page.dart';
import 'card_item_component.dart';
import 'card_item_view_model.dart';

/// BLoC for the [CardItemComponent].
///
/// Exposes a [CardItemViewModel] for that component to use.
@injectable
class CardItemBloc {
  CardItemBloc(this._markedCardsRepository);

  final MarkedCardsRepository _markedCardsRepository;

  Stream<CardItemViewModel>? _viewModel;
  Stream<CardItemViewModel>? get viewModel => _viewModel;

  Stream<CardItemViewModel> createViewModel(Stream<Card> card) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest2(
      card,
      _markedCardsRepository.get(),
      _createViewModel,
    );
  }

  CardItemViewModel _createViewModel(
    Card card,
    BuiltList<String> markedCardIds,
  ) {
    final isSelected = markedCardIds.any((id) => id == card.id);

    return CardItemViewModel(
      card: card,
      previewText: getPreview(card.front!),
      isSelected: isSelected,
      onTap: () => _openCardEditPage(card),
      onLongPress: () => _handleSelectedStatusChange(card, markedCardIds),
      onAvatarTap: () => _handleSelectedStatusChange(card, markedCardIds),
    );
  }

  void _openCardEditPage(Card card) {
    CustomNavigator.getInstance().pushNamed(
      UpsertCardPage.routeNameEdit,
      args: UpsertCardArguments(deckId: card.deck!.id!, cardId: card.id),
    );
  }

  void _handleSelectedStatusChange(
    Card card,
    BuiltList<String> markedCardsIds,
  ) {
    HapticFeedback.selectionClick();

    if (markedCardsIds.contains(card.id)) {
      _markedCardsRepository.remove(card.id);
    } else {
      _markedCardsRepository.upsert(card.id!);
    }
  }
}
