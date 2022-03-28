import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../../data/models/deck.dart';
import '../../../../i18n/i18n.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/list_tile_adapter.dart';
import '../../../preferences/component/preference_title.dart';
import '../../../shared/user_avatar_component.dart';
import 'member_list_bloc.dart';
import 'member_list_view_model.dart';

class MemberListComponent extends StatelessWidget {
  const MemberListComponent(this._deck, this._scrollController, {Key? key})
      : super(key: key);

  final Deck _deck;
  final ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return Component<MemberListBloc>(
      createViewModel: (bloc) => bloc.createViewModel(_deck),
      builder: (context, bloc) {
        return StreamBuilder<MemberListViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _showErrorIndicator(context);
            }
            if (!snapshot.hasData) {
              return _showLoadingIndicator(context);
            }

            return _MemberListView(snapshot.data!, _scrollController);
          },
        );
      },
    );
  }

  Widget _showErrorIndicator(BuildContext context) {
    return MultiSliver(
      children: [
        SliverToBoxAdapter(child: PreferenceTitle(S.of(context).members)),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outlined, size: 32),
                const SizedBox(height: 16),
                Text(
                  S.of(context).errorUnknownText,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _showLoadingIndicator(BuildContext context) {
    return MultiSliver(
      children: [
        SliverToBoxAdapter(child: PreferenceTitle(S.of(context).members)),
        const SliverFillRemaining(
          hasScrollBody: false,
          child: SizedBox(
            height: 72,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }
}

@immutable
class _MemberListView extends StatefulWidget {
  const _MemberListView(this.viewModel, this.scrollController, {Key? key})
      : super(key: key);

  final MemberListViewModel viewModel;
  final ScrollController scrollController;

  @override
  _MemberListViewState createState() => _MemberListViewState();
}

class _MemberListViewState extends State<_MemberListView> {
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(() {
      if (widget.scrollController.position.extentAfter < 50) {
        widget.viewModel.fetchMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final memberCountText = widget.viewModel.memberCount == null
        ? ''
        : '(${widget.viewModel.memberCount})';
    final loadingIndicatorOffset =
        widget.viewModel.showContinuationsLoadingIndicator ? 1 : 0;

    return MultiSliver(
      children: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverAppBarDelegate(
            minHeight: 30,
            maxHeight: 30,
            child: PreferenceTitle('${S.of(context).members} $memberCountText'),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            _buildMemberTile,
            childCount:
                widget.viewModel.members.length + loadingIndicatorOffset,
          ),
        ),
      ],
    );
  }

  Widget _buildMemberTile(BuildContext context, int index) {
    if (index == widget.viewModel.members.length &&
        widget.viewModel.showContinuationsLoadingIndicator) {
      return const SizedBox(
        height: 56,
        width: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final member = widget.viewModel.members[index];
    final onLongPress = widget.viewModel.isLongPressEnabled(member)
        ? () => widget.viewModel.onLongPress(context, member)
        : null;

    return ListTileAdapter(
      child: GestureDetector(
        onSecondaryTap: onLongPress,
        child: ListTile(
          leading: UserAvatarComponent(user: member.user!),
          title: Text(
            '${member.user!.firstName} ${member.user!.lastName}',
            softWrap: false,
            maxLines: 1,
            overflow: TextOverflow.fade,
          ),
          trailing: Text(
            member.role!.toDisplayTitle(context),
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
          onLongPress: onLongPress,
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
