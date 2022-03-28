import 'package:flutter/material.dart';

import '../../../../data/models/deck.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/list_tile_adapter.dart';
import '../../../../widgets/visual_element.dart';
import 'invites_bloc.dart';
import 'invites_view_model.dart';

class InvitesComponent extends StatelessWidget {
  const InvitesComponent(this._deck, {Key? key}) : super(key: key);

  final Deck _deck;

  @override
  Widget build(BuildContext context) {
    return Component<InvitesBloc>(
      createViewModel: (bloc) => bloc.createViewModel(_deck),
      builder: (context, bloc) {
        return StreamBuilder<InvitesViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const _InvitesViewSkeleton();
            }

            return _InvitesView(viewModel: snapshot.data!);
          },
        );
      },
    );
  }
}

@immutable
class _InvitesView extends StatelessWidget {
  const _InvitesView({required this.viewModel, Key? key}) : super(key: key);

  final InvitesViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInviteViewerTile(context),
        _buildInviteEditorTile(context),
        if (viewModel.onStoreTap != null)
          _buildStoreTile(context)
        else
          _buildPublishTile(context)
      ],
    );
  }

  Widget _buildInviteViewerTile(BuildContext context) {
    final isEnabled = viewModel.hasViewerLinkUpsertAccess ||
        (viewModel.hasViewerLinkViewAccess && viewModel.existViewerLink);

    String tooltipMessage;
    if (isEnabled) {
      tooltipMessage = S.of(context).inviteViewers;
    } else if (!viewModel.existViewerLink) {
      tooltipMessage = S.of(context).notAllowedByOwner;
    } else {
      tooltipMessage = S.of(context).noPermission;
    }

    return VisualElement(
      id: VEs.inviteViewerTile,
      childBuilder: (controller) {
        return ListTileAdapter(
          child: Tooltip(
            message: tooltipMessage,
            child: ListTile(
              enabled: isEnabled,
              title: Text(S.of(context).inviteViewers),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context)
                    .selectedRowColor
                    .withAlpha(isEnabled ? 255 : 100),
                child: Icon(
                  Icons.visibility_outlined,
                  color: isEnabled
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).disabledColor,
                ),
              ),
              onTap: () {
                controller.logTap();
                viewModel.onInviteViewerTap();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildInviteEditorTile(BuildContext context) {
    final isEnabled = viewModel.hasEditorLinkUpsertAccess ||
        (viewModel.hasEditorLinkViewAccess && viewModel.existEditorLink);

    String tooltipMessage;
    if (isEnabled) {
      tooltipMessage = S.of(context).inviteEditors;
    } else if (!viewModel.existEditorLink) {
      tooltipMessage = S.of(context).notAllowedByOwner;
    } else {
      tooltipMessage = S.of(context).noPermission;
    }

    return VisualElement(
      id: VEs.inviteEditorTile,
      childBuilder: (controller) {
        return ListTileAdapter(
          child: Tooltip(
            message: tooltipMessage,
            child: ListTile(
              enabled: isEnabled,
              title: Text(S.of(context).inviteEditors),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context)
                    .selectedRowColor
                    .withAlpha(isEnabled ? 255 : 100),
                child: Icon(
                  Icons.edit_outlined,
                  color: isEnabled
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).disabledColor,
                ),
              ),
              onTap: () {
                controller.logTap();
                viewModel.onInviteEditorTap();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStoreTile(BuildContext context) {
    return VisualElement(
      id: VEs.storeTile,
      childBuilder: (controller) {
        return ListTileAdapter(
          child: Tooltip(
            message: S.of(context).store,
            child: ListTile(
              title: Text(S.of(context).store),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).selectedRowColor,
                child: Icon(
                  Icons.store_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              onTap: () {
                controller.logTap();
                viewModel.onStoreTap!();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPublishTile(BuildContext context) {
    final isEnabled = viewModel.hasPublishPermission;

    String tooltipMessage;
    if (isEnabled) {
      tooltipMessage = S.of(context).publish;
    } else {
      tooltipMessage = S.of(context).noPermission;
    }

    return VisualElement(
      id: VEs.publishTile,
      childBuilder: (controller) {
        return ListTileAdapter(
          child: Tooltip(
            message: tooltipMessage,
            child: ListTile(
              enabled: isEnabled,
              title: Text(S.of(context).publish),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context)
                    .selectedRowColor
                    .withAlpha(isEnabled ? 255 : 100),
                child: Icon(
                  Icons.store,
                  color: isEnabled
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).disabledColor,
                ),
              ),
              onTap: () {
                controller.logTap();
                viewModel.onPublishTap();
              },
            ),
          ),
        );
      },
    );
  }
}

class _InvitesViewSkeleton extends StatelessWidget {
  const _InvitesViewSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInviteViewerTile(context),
        _buildInviteEditorTile(context),
      ],
    );
  }

  Widget _buildInviteViewerTile(BuildContext context) {
    return ListTileAdapter(
      child: ListTile(
        enabled: false,
        title: Text(S.of(context).inviteViewers),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).selectedRowColor.withAlpha(100),
          child: Icon(
            Icons.visibility_outlined,
            color: Theme.of(context).disabledColor,
          ),
        ),
      ),
    );
  }

  Widget _buildInviteEditorTile(BuildContext context) {
    return ListTileAdapter(
      child: ListTile(
        enabled: false,
        title: Text(S.of(context).inviteEditors),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).selectedRowColor.withAlpha(100),
          child: Icon(
            Icons.edit_outlined,
            color: Theme.of(context).disabledColor,
          ),
        ),
      ),
    );
  }
}
