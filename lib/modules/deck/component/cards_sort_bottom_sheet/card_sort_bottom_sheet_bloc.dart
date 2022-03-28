import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

import '../../../../data/models/cards_order_field.dart';
import '../../../../data/models/cards_sort_order.dart';
import '../../../../data/models/order_direction.dart';
import '../../../../data/preferences/preferences.dart';
import '../../../../utils/custom_navigator.dart';
import 'card_sort_bottom_sheet_view_model.dart';

@injectable
class CardSortBottomSheetBloc {
  CardSortBottomSheetBloc(this._preferences);

  final Preferences _preferences;

  Stream<CardSortBottomSheetViewModel>? _viewModel;
  Stream<CardSortBottomSheetViewModel>? get viewModel => _viewModel;

  Stream<CardSortBottomSheetViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = _preferences.cardsSortOrder.map(
      (s) => CardSortBottomSheetViewModel(
        activeSortAttribute: s,
        onTap: (context, field) => _handleTap(context, field, s),
      ),
    );
  }

  void _handleTap(
    BuildContext context,
    CardsOrderField field,
    CardsSortOrder oldSortOrder,
  ) {
    var sortOrder =
        CardsSortOrder(field: field, direction: OrderDirection.descending);

    if (oldSortOrder == sortOrder) {
      sortOrder = sortOrder.copyWith(direction: OrderDirection.ascending);
    }

    CustomNavigator.getInstance().pop(sortOrder);
  }
}
