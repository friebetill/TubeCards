import 'package:flutter/cupertino.dart';

class JoinSharedDeckViewModel {
  JoinSharedDeckViewModel({
    required this.linkErrorText,
    required this.isLoading,
    required this.emailTextController,
    required this.onJoinTap,
    required this.onPasteLinkTap,
  });

  final String? linkErrorText;
  final bool isLoading;
  final TextEditingController emailTextController;

  final VoidCallback onJoinTap;
  final VoidCallback onPasteLinkTap;
}
