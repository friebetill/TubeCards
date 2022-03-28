import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../../../data/models/cards_sort_order.dart';
import '../../../../data/preferences/preferences.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../cards_sort_bottom_sheet/card_sort_bottom_sheet_component.dart';
import 'card_sort_button_view_model.dart';

@injectable
class CardSortButtonBloc with ComponentBuildContext {
  CardSortButtonBloc(this._preferences);

  final Preferences _preferences;

  Stream<CardSortButtonViewModel>? _viewModel;
  Stream<CardSortButtonViewModel>? get viewModel => _viewModel;

  Stream<CardSortButtonViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Stream.value(CardSortButtonViewModel(
      onTap: _handleCardsSortOptionsTap,
    ));
  }

  Future<void> _handleCardsSortOptionsTap() async {
    final cardsSortOrder = await showModalBottomSheet<CardsSortOrder>(
      context: context,
      builder: (_) => const CardsSortBottomSheetComponent(),
    );

    if (cardsSortOrder == null) {
      return;
    }
    await _preferences.cardsSortOrder.setValue(cardsSortOrder);
  }
}
