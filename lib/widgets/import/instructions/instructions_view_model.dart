import 'package:flutter/foundation.dart';

class InstructionsViewModel {
  InstructionsViewModel({
    required this.onSelectFileTap,
    required this.onLinkTap,
    required this.appBarTitle,
    required this.markdownBody,
  });

  final String appBarTitle;
  final String markdownBody;

  final VoidCallback onSelectFileTap;
  final Future<void> Function(String, String?, String) onLinkTap;
}
