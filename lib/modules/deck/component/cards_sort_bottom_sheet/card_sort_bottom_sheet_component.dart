import 'package:flutter/material.dart';

import '../../../../data/models/cards_order_field.dart';
import '../../../../data/models/cards_sort_order.dart';
import '../../../../data/models/order_direction.dart';
import '../../../../i18n/i18n.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/list_tile_adapter.dart';
import 'card_sort_bottom_sheet_bloc.dart';
import 'card_sort_bottom_sheet_view_model.dart';

/// Bottom sheet used to select the attribute for sorting cards.
class CardsSortBottomSheetComponent extends StatelessWidget {
  const CardsSortBottomSheetComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<CardSortBottomSheetBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<CardSortBottomSheetViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            return _CardSortBottomSheetView(snapshot.data!);
          },
        );
      },
    );
  }
}

class _CardSortBottomSheetView extends StatelessWidget {
  const _CardSortBottomSheetView(this.viewModel);

  final CardSortBottomSheetViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildTitle(context),
          _buildCreationDateOption(context, viewModel.activeSortAttribute),
          _buildAlphabeticallyOption(context, viewModel.activeSortAttribute),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return ListTileAdapter(
      child: ListTile(
        title: Text(
          S.of(context).sortCards,
          style: TextStyle(color: Theme.of(context).iconTheme.color),
        ),
      ),
    );
  }

  Widget _buildCreationDateOption(
    BuildContext context,
    CardsSortOrder sortOrder,
  ) {
    Widget? trailing;
    if (sortOrder.field == CardsOrderField.createdAt) {
      trailing = Icon(
        sortOrder.direction == OrderDirection.ascending
            ? Icons.arrow_upward
            : Icons.arrow_downward,
        color: Theme.of(context).colorScheme.primary,
      );
    }

    return ListTileAdapter(
      child: ListTile(
        leading: Icon(
          Icons.date_range_outlined,
          color: Theme.of(context).iconTheme.color,
        ),
        trailing: trailing,
        title: Text(S.of(context).creationDate),
        onTap: () => viewModel.onTap(context, CardsOrderField.createdAt),
      ),
    );
  }

  Widget _buildAlphabeticallyOption(
    BuildContext context,
    CardsSortOrder sortOrder,
  ) {
    Widget? trailing;
    if (sortOrder.field == CardsOrderField.front) {
      trailing = Icon(
        sortOrder.direction == OrderDirection.ascending
            ? Icons.arrow_upward
            : Icons.arrow_downward,
        color: Theme.of(context).colorScheme.primary,
      );
    }

    return ListTileAdapter(
      child: ListTile(
        leading: Icon(
          Icons.sort_by_alpha_outlined,
          color: Theme.of(context).iconTheme.color,
        ),
        trailing: trailing,
        title: Text(S.of(context).alphabetically),
        onTap: () => viewModel.onTap(context, CardsOrderField.front),
      ),
    );
  }
}
