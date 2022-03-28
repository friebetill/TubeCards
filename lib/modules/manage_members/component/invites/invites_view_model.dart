import 'package:flutter/foundation.dart';

class InvitesViewModel {
  InvitesViewModel({
    required this.existViewerLink,
    required this.existEditorLink,
    required this.hasViewerLinkViewAccess,
    required this.hasViewerLinkUpsertAccess,
    required this.hasEditorLinkViewAccess,
    required this.hasEditorLinkUpsertAccess,
    required this.hasPublishPermission,
    required this.onInviteViewerTap,
    required this.onInviteEditorTap,
    required this.onStoreTap,
    required this.onPublishTap,
  });

  final bool existViewerLink;
  final bool existEditorLink;
  final bool hasViewerLinkViewAccess;
  final bool hasViewerLinkUpsertAccess;
  final bool hasEditorLinkViewAccess;
  final bool hasEditorLinkUpsertAccess;
  final bool hasPublishPermission;

  final VoidCallback onInviteViewerTap;
  final VoidCallback onInviteEditorTap;
  final VoidCallback? onStoreTap;
  final VoidCallback onPublishTap;
}
