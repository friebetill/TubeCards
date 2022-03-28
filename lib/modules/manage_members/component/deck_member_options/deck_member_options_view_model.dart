import 'package:flutter/foundation.dart';

import '../../../../data/models/deck_member.dart';

class DeckMemberOptionsViewModel {
  DeckMemberOptionsViewModel({
    required this.deckMember,
    required this.showMakeEditorButton,
    required this.showMakeViewerButton,
    required this.showOwnerLoadingIndicator,
    required this.showEditorLoadingIndicator,
    required this.showViewerLoadingIndicator,
    required this.showDeleteLoadingIndicator,
    required this.onMakeOwnerTap,
    required this.onMakeEditorTap,
    required this.onMakeViewerTap,
    required this.onDeleteTap,
  });

  final DeckMember deckMember;
  final bool showMakeEditorButton;
  final bool showMakeViewerButton;
  final bool showOwnerLoadingIndicator;
  final bool showEditorLoadingIndicator;
  final bool showViewerLoadingIndicator;
  final bool showDeleteLoadingIndicator;

  final VoidCallback onMakeOwnerTap;
  final VoidCallback onMakeEditorTap;
  final VoidCallback onMakeViewerTap;
  final VoidCallback onDeleteTap;
}
