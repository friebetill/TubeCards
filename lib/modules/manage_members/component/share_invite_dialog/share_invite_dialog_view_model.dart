import 'package:flutter/foundation.dart';

import '../../../../data/models/role.dart';

class ShareInviteDialogViewModel {
  ShareInviteDialogViewModel({
    required this.role,
    required this.link,
    required this.showLinkLoadingIndicator,
    required this.showGenerateLinkButton,
    required this.showDeleteLinkButton,
    required this.showDeleteLinkLoadingIndicator,
    required this.showCopiedLinkIndicator,
    required this.onLinkTap,
    required this.onShare,
    required this.onDeleteTap,
  });

  final Role role;
  final Uri? link;
  final bool showLinkLoadingIndicator;
  final bool showGenerateLinkButton;
  final bool showDeleteLinkButton;
  final bool showDeleteLinkLoadingIndicator;
  final bool showCopiedLinkIndicator;

  final VoidCallback onLinkTap;
  final VoidCallback onShare;
  final VoidCallback onDeleteTap;
}
