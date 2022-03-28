import 'package:flutter/foundation.dart';

class AcceptDeckInviteViewModel {
  AcceptDeckInviteViewModel({
    required this.deckName,
    required this.creatorFullName,
    required this.coverImageUrl,
    required this.isLoading,
    required this.onJoinTap,
    required this.onCancelTap,
  });

  final String deckName;
  final String creatorFullName;
  final String coverImageUrl;
  final bool isLoading;

  final VoidCallback onJoinTap;
  final VoidCallback onCancelTap;
}
