import 'package:flutter/widgets.dart';

import '../../../../data/models/cards_order_field.dart';
import '../../../../data/models/cards_sort_order.dart';

class CardSortBottomSheetViewModel {
  CardSortBottomSheetViewModel({
    required this.activeSortAttribute,
    required this.onTap,
  });

  final CardsSortOrder activeSortAttribute;

  final void Function(BuildContext, CardsOrderField) onTap;
}
