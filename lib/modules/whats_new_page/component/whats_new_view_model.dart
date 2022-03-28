import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../utils/release_notes.dart';

class WhatsNewViewModel {
  WhatsNewViewModel({
    required this.text,
    required this.onContinueTap,
    required this.onLinkTap,
    required this.onImageTap,
  });

  final LocalizedText text;
  final VoidCallback onContinueTap;
  final Function(String, String?, String) onLinkTap;
  final ValueChanged<String> onImageTap;
}
