import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/connection.dart';
import '../../../../data/models/deck.dart';
import '../../../../data/models/deck_member.dart';
import '../../../../data/models/role.dart';
import '../../../../data/repositories/deck_member_repository.dart';
import '../../../../utils/permission.dart';
import '../deck_member_options/deck_member_options_component.dart';
import 'member_list_component.dart';
import 'member_list_view_model.dart';

/// BLoC for the [MemberListComponent].
///
/// Exposes a [MemberListViewModel] for that component to use.
@injectable
class MemberListBloc {
  MemberListBloc(this._deckMemberRepository);

  final DeckMemberRepository _deckMemberRepository;

  Stream<MemberListViewModel>? _viewModel;
  Stream<MemberListViewModel>? get viewModel => _viewModel;

  /// Returns true when more members are loaded
  ///
  /// This happens when a new member connection page is loaded.
  bool _isLoadingContinuations = false;

  Stream<MemberListViewModel> createViewModel(Deck deck) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Rx.combineLatest2(
      _deckMemberRepository.getAll(
        deck.id!,
        fetchPolicy: FetchPolicy.CacheAndNetwork,
      ),
      Stream.value(deck),
      _createViewModel,
    );
  }

  MemberListViewModel _createViewModel(
    Connection<DeckMember> memberConnection,
    Deck deck,
  ) {
    return MemberListViewModel(
      members: memberConnection.nodes!,
      // memberCount can be null, when we get the cached result
      memberCount: memberConnection.totalCount,
      fetchMore: () => _fetchMore(memberConnection),
      showContinuationsLoadingIndicator:
          memberConnection.pageInfo!.hasNextPage!,
      isLongPressEnabled: (member) =>
          deck.viewerDeckMember!.role!
              .hasPermission(Permission.deckMemberDelete) &&
          member.role != Role.owner,
      onLongPress: _handleLongPress,
    );
  }

  Future<void> _fetchMore(Connection<DeckMember> connection) async {
    if (connection.pageInfo!.hasNextPage! && !_isLoadingContinuations) {
      _isLoadingContinuations = true;
      await connection.fetchMore!();
      _isLoadingContinuations = false;
    }
  }

  void _handleLongPress(BuildContext context, DeckMember member) {
    HapticFeedback.heavyImpact();

    showModalBottomSheet<void>(
      context: context,
      builder: (_) =>
          DeckMemberOptionsComponent(member.deck!.id!, member.user!.id!),
    );
  }
}
