import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/list_tile_adapter.dart';
import 'select_deck_dialog_bloc.dart';
import 'select_deck_dialog_view_model.dart';

class SelectDeckDialogComponent extends StatelessWidget {
  const SelectDeckDialogComponent(this.excludedDeckId, {Key? key})
      : super(key: key);

  final String excludedDeckId;

  @override
  Widget build(BuildContext context) {
    return Component<SelectDeckDialogBloc>(
      createViewModel: (bloc) => bloc.createViewModel(excludedDeckId),
      builder: (context, bloc) {
        return StreamBuilder<SelectDeckDialogViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return _SelectDeckDialogView(snapshot.data!);
          },
        );
      },
    );
  }
}

class _SelectDeckDialogView extends StatelessWidget {
  const _SelectDeckDialogView(this.viewModel);

  final SelectDeckDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).moveTo),
      actions: <Widget>[_buildCancelButton(context)],
      content: _buildDeckNameList(viewModel),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: CustomNavigator.getInstance().pop,
      child: Text(S.of(context).cancel.toUpperCase()),
    );
  }

  Widget _buildDeckNameList(SelectDeckDialogViewModel viewModel) {
    final itemCount =
        viewModel.decks.length + (viewModel.showLoadingIndicator ? 1 : 0);

    return SizedBox(
      /// A width is required see https://stackoverflow.com/a/56355962/6169345
      width: double.maxFinite,
      child: LazyLoadScrollView(
        onEndOfPage: viewModel.fetchMore,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (viewModel.showLoadingIndicator &&
                index == viewModel.decks.length) {
              return const SizedBox(
                height: 50,
                width: 50,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return ListTileAdapter(
              child: ListTile(
                title: Text(viewModel.decks[index].name!),
                onTap: () =>
                    CustomNavigator.getInstance().pop(viewModel.decks[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}
