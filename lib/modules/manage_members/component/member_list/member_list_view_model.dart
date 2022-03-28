import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';

import '../../../../data/models/deck_member.dart';

class MemberListViewModel {
  MemberListViewModel({
    required this.members,
    required this.memberCount,
    required this.showContinuationsLoadingIndicator,
    required this.fetchMore,
    required this.isLongPressEnabled,
    required this.onLongPress,
  });

  final BuiltList<DeckMember> members;
  final int? memberCount;
  final bool showContinuationsLoadingIndicator;

  final VoidCallback fetchMore;
  final bool Function(DeckMember member) isLongPressEnabled;
  final Function(BuildContext context, DeckMember member) onLongPress;
}
