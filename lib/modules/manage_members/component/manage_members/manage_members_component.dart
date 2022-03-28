import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/tooltip_message.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/page_callback_shortcuts.dart';
import '../../../../widgets/simple_skeleton.dart';
import '../access_rights_tile_view.dart';
import '../invites/invites_component.dart';
import '../member_list/member_list_component.dart';
import 'manage_members_bloc.dart';
import 'manage_members_viewmodel.dart';

class ManageMembersComponent extends StatelessWidget {
  const ManageMembersComponent(this.deckId, {Key? key}) : super(key: key);

  final String deckId;

  @override
  Widget build(BuildContext context) {
    return Component<ManageMembersBloc>(
      createViewModel: (bloc) => bloc.createViewModel(deckId),
      builder: (context, bloc) {
        return StreamBuilder<ManageMembersViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SimpleSkeleton(appBarTitle: S.of(context).manageMembers);
            }

            return _ManageMembersView(snapshot.data!);
          },
        );
      },
    );
  }
}

class _ManageMembersView extends StatefulWidget {
  const _ManageMembersView(this.viewModel);

  final ManageMembersViewModel viewModel;

  @override
  State<_ManageMembersView> createState() => _ManageMembersViewState();
}

class _ManageMembersViewState extends State<_ManageMembersView> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return PageCallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        LogicalKeySet(LogicalKeyboardKey.escape): widget.viewModel.onBackTap,
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).manageMembers),
          elevation: 0,
          leading: IconButton(
            icon: const BackButtonIcon(),
            onPressed: widget.viewModel.onBackTap,
            tooltip: backTooltip(context),
          ),
        ),
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                AccessRightsTileView(userRole: widget.viewModel.userRole),
                InvitesComponent(widget.viewModel.deck),
                const Divider(),
              ]),
            ),
            MemberListComponent(widget.viewModel.deck, _scrollController),
          ],
        ),
      ),
    );
  }
}
