import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../data/models/role.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/icon_sized_loading_indicator.dart';
import '../../../../widgets/component/component.dart';
import 'share_invite_dialog_bloc.dart';
import 'share_invite_dialog_view_model.dart';

class ShareInviteDialogComponent extends StatelessWidget {
  const ShareInviteDialogComponent({
    required this.deckId,
    required this.role,
    Key? key,
  }) : super(key: key);

  final String deckId;
  final Role role;

  @override
  Widget build(BuildContext context) {
    return Component<ShareInviteDialogBloc>(
      createViewModel: (bloc) =>
          bloc.createViewModel(deckId: deckId, role: role),
      builder: (context, bloc) {
        return StreamBuilder<ShareInviteDialogViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            return _ShareInviteDialogView(snapshot.data!);
          },
        );
      },
    );
  }
}

class _ShareInviteDialogView extends StatelessWidget {
  const _ShareInviteDialogView(this._viewModel);

  final ShareInviteDialogViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildPictogram(context),
          const SizedBox(height: 16),
          _buildTitle(context),
          const SizedBox(height: 12),
          _buildSubtitle(context),
          const SizedBox(height: 24),
          _buildLink(context),
        ],
      ),
    );
  }

  Widget _buildPictogram(BuildContext context) {
    return CircleAvatar(
      radius: 36,
      backgroundColor: Theme.of(context).selectedRowColor,
      child: Icon(
        _viewModel.role == Role.viewer
            ? Icons.visibility_outlined
            : Icons.edit_outlined,
        size: 36,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      _viewModel.role == Role.viewer
          ? S.of(context).inviteViewers
          : S.of(context).inviteEditors,
      style: Theme.of(context).textTheme.headline5,
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Text(
        _viewModel.role == Role.viewer
            ? S.of(context).viewerRightsText
            : S.of(context).editorRightsText,
        style: Theme.of(context)
            .textTheme
            .bodyText2!
            .copyWith(color: Theme.of(context).hintColor),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLink(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).selectedRowColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: _viewModel.showLinkLoadingIndicator
            ? const Center(child: IconSizedLoadingIndicator())
            : _viewModel.showGenerateLinkButton
                ? _buildGenerateLinkText(context)
                : _buildLinkAndButtons(context),
      ),
    );
  }

  Widget _buildGenerateLinkText(BuildContext context) {
    return Tooltip(
      message: S.of(context).copy,
      child: TextButton(
        onPressed: _viewModel.onLinkTap,
        child: Text(S.of(context).generateLink.toUpperCase()),
      ),
    );
  }

  Widget _buildLinkAndButtons(BuildContext context) {
    final linkText = _buildSimpleLinkText(_viewModel.link!);
    final linkTextStyle =
        Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 16);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 12),
        Expanded(
          child: Center(
            child: !_viewModel.showCopiedLinkIndicator
                ? SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Tooltip(
                      message: S.of(context).copy,
                      child: TextButton(
                        onPressed: _viewModel.onLinkTap,
                        child: Text(
                          linkText.toUpperCase(),
                          style: linkTextStyle,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                  )
                : Text(
                    S.of(context).linkCopied,
                    style: linkTextStyle,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
          ),
        ),
        if (Platform.isAndroid || Platform.isIOS) const SizedBox(width: 12),
        if (Platform.isAndroid || Platform.isIOS)
          Material(
            type: MaterialType.transparency,
            child: IconButton(
              padding: const EdgeInsets.all(12),
              icon: const Icon(Icons.share_outlined),
              tooltip: S.of(context).share,
              onPressed: _viewModel.onShare,
            ),
          ),
        if (_viewModel.showDeleteLinkButton) const SizedBox(width: 12),
        if (_viewModel.showDeleteLinkButton)
          Material(
            type: MaterialType.transparency,
            child: IconButton(
              padding: const EdgeInsets.all(12),
              icon: !_viewModel.showDeleteLinkLoadingIndicator
                  ? const Icon(Icons.delete_outlined)
                  : const IconSizedLoadingIndicator(),
              tooltip: S.of(context).delete,
              onPressed: _viewModel.onDeleteTap,
            ),
          ),
        const SizedBox(width: 12),
      ],
    );
  }

  String _buildSimpleLinkText(Uri inviteUrl) {
    return '${inviteUrl.host}${inviteUrl.path}';
  }
}
