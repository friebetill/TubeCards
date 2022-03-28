import 'package:flutter/material.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/icon_sized_loading_indicator.dart';
import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/list_tile_adapter.dart';
import '../../../../widgets/visual_element.dart';
import 'deck_member_options_bloc.dart';
import 'deck_member_options_view_model.dart';

/// Bottom sheet to display options that the user has for a deck member.
class DeckMemberOptionsComponent extends StatelessWidget {
  const DeckMemberOptionsComponent(this._deckId, this._userId, {Key? key})
      : super(key: key);

  final String _deckId;
  final String _userId;

  @override
  Widget build(BuildContext context) {
    return Component<DeckMemberOptionsBloc>(
      createViewModel: (bloc) => bloc.createViewModel(_deckId, _userId),
      builder: (context, bloc) {
        return StreamBuilder<DeckMemberOptionsViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            return _DeckMemberOptionsView(snapshot.data!);
          },
        );
      },
    );
  }
}

class _DeckMemberOptionsView extends StatefulWidget {
  const _DeckMemberOptionsView(this.viewModel);

  final DeckMemberOptionsViewModel viewModel;

  @override
  _DeckMemberOptionsViewState createState() => _DeckMemberOptionsViewState();
}

class _DeckMemberOptionsViewState extends State<_DeckMemberOptionsView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildTitle(context),
        _buildMakeOwnerOption(context),
        if (widget.viewModel.showMakeEditorButton)
          _buildMakeEditorOption(context),
        if (widget.viewModel.showMakeViewerButton)
          _buildMakeViewerOption(context),
        _buildRemoveOption(context),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    final user = widget.viewModel.deckMember.user!;

    return ListTileAdapter(
      child: ListTile(
        title: Text(
          '${user.firstName} ${user.lastName}',
          style: TextStyle(color: Theme.of(context).iconTheme.color),
        ),
      ),
    );
  }

  Widget _buildMakeOwnerOption(BuildContext context) {
    return ListTileAdapter(
      child: VisualElement(
        id: VEs.makeOwnerTile,
        childBuilder: (controller) {
          return ListTile(
            leading: !widget.viewModel.showOwnerLoadingIndicator
                ? const Icon(Icons.supervisor_account_outlined)
                : IconSizedLoadingIndicator(
                    color: Theme.of(context).iconTheme.color,
                  ),
            title: Text(S.of(context).makeOwner),
            onTap: () {
              controller.logTap();
              widget.viewModel.onMakeOwnerTap();
            },
          );
        },
      ),
    );
  }

  Widget _buildMakeEditorOption(BuildContext context) {
    return ListTileAdapter(
      child: VisualElement(
        id: VEs.makeEditorTile,
        childBuilder: (controller) {
          return ListTile(
            leading: !widget.viewModel.showEditorLoadingIndicator
                ? const Icon(Icons.edit_outlined)
                : IconSizedLoadingIndicator(
                    color: Theme.of(context).iconTheme.color,
                  ),
            title: Text(S.of(context).makeEditor),
            onTap: () {
              controller.logTap();
              widget.viewModel.onMakeEditorTap();
            },
          );
        },
      ),
    );
  }

  Widget _buildMakeViewerOption(BuildContext context) {
    return ListTileAdapter(
      child: VisualElement(
        id: VEs.makeViewerTile,
        childBuilder: (controller) {
          return ListTile(
            leading: !widget.viewModel.showViewerLoadingIndicator
                ? const Icon(Icons.visibility_outlined)
                : IconSizedLoadingIndicator(
                    color: Theme.of(context).iconTheme.color,
                  ),
            title: Text(S.of(context).makeViewer),
            onTap: () {
              controller.logTap();
              widget.viewModel.onMakeViewerTap();
            },
          );
        },
      ),
    );
  }

  Widget _buildRemoveOption(BuildContext context) {
    return ListTileAdapter(
      child: VisualElement(
        id: VEs.removeMemberTile,
        childBuilder: (controller) {
          return ListTile(
            leading: !widget.viewModel.showDeleteLoadingIndicator
                ? Icon(
                    Icons.remove_circle_outline,
                    color: Theme.of(context).colorScheme.error,
                  )
                : IconSizedLoadingIndicator(
                    color: Theme.of(context).iconTheme.color,
                  ),
            title: Text(
              S.of(context).removeFromDeck,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () {
              controller.logTap();
              widget.viewModel.onDeleteTap();
            },
          );
        },
      ),
    );
  }
}
