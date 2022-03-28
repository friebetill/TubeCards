import 'package:flutter/material.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/icon_sized_loading_indicator.dart';
import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/list_tile_adapter.dart';
import '../../../../widgets/visual_element.dart';
import 'deck_options_bloc.dart';
import 'deck_options_view_model.dart';

/// Bottom sheet to display options that the user has for a deck.
class DeckOptionsComponent extends StatelessWidget {
  const DeckOptionsComponent(this._deckId, {Key? key}) : super(key: key);

  final String _deckId;

  @override
  Widget build(BuildContext context) {
    return Component<DeckOptionsBloc>(
      createViewModel: (bloc) => bloc.createViewModel(_deckId),
      builder: (context, bloc) {
        return StreamBuilder<DeckOptionsViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              // The height is measured.
              const deckOptionsViewHeight = 144.0;

              return const SizedBox(height: deckOptionsViewHeight);
            }

            return _DeckOptionsView(snapshot.data!);
          },
        );
      },
    );
  }
}

class _DeckOptionsView extends StatelessWidget {
  const _DeckOptionsView(this.viewModel);

  final DeckOptionsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildTitle(context),
          _buildIsActiveOption(context, viewModel.isActive),
          if (viewModel.hasDeletePermission)
            _buildDeleteOption(context)
          else
            _buildLeaveOption(context),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return ListTileAdapter(
      child: ListTile(
        title: Text(
          viewModel.deckName,
          style: TextStyle(color: Theme.of(context).iconTheme.color),
        ),
      ),
    );
  }

  Widget _buildIsActiveOption(BuildContext context, bool isActive) {
    return ListTileAdapter(
      child: ListTile(
        leading: !viewModel.showIsActiveLoadingIndicator
            ? Icon(
                isActive
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Theme.of(context).iconTheme.color,
              )
            : IconSizedLoadingIndicator(
                color: Theme.of(context).iconTheme.color,
              ),
        title: Text(
          isActive ? S.of(context).deactivate : S.of(context).activate,
        ),
        onTap: viewModel.onIsActiveTap,
      ),
    );
  }

  Widget _buildDeleteOption(BuildContext context) {
    return ListTileAdapter(
      child: Tooltip(
        message: S.of(context).deleteDeck,
        child: VisualElement(
          id: VEs.deleteDeckTile,
          childBuilder: (controller) {
            return ListTile(
              leading: !viewModel.showDeleteLoadingIndicator
                  ? Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).iconTheme.color,
                    )
                  : IconSizedLoadingIndicator(
                      color: Theme.of(context).iconTheme.color,
                    ),
              title: Text(S.of(context).delete),
              onTap: () {
                viewModel.onDeleteTap();
                controller.logTap();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLeaveOption(BuildContext context) {
    return ListTileAdapter(
      child: Tooltip(
        message: S.of(context).leaveDeck,
        child: ListTile(
          leading: !viewModel.showLeaveLoadingIndicator
              ? Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).iconTheme.color,
                )
              : IconSizedLoadingIndicator(
                  color: Theme.of(context).iconTheme.color,
                ),
          title: Text(S.of(context).leave),
          onTap: viewModel.onLeaveTap,
        ),
      ),
    );
  }
}
