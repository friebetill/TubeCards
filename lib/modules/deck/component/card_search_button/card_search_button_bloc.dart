import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../../../widgets/component/component_build_context.dart';
import '../card_search/card_search_delegate.dart';
import 'card_search_button_view_model.dart';

@injectable
class CardSearchButtonBloc with ComponentBuildContext {
  CardSearchButtonBloc();

  Stream<CardSearchButtonViewModel>? _viewModel;
  Stream<CardSearchButtonViewModel>? get viewModel => _viewModel;

  Stream<CardSearchButtonViewModel> createViewModel(String deckId) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Stream.value(CardSearchButtonViewModel(
      onTap: () => _handleTap(deckId),
    ));
  }

  void _handleTap(String deckId) {
    showSearch(
      context: context,
      delegate: CardSearchDelegate(deckId: deckId),
    );
  }
}
