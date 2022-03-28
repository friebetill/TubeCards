import 'package:flutter/foundation.dart';

typedef AnalyzeFileErrorCallback
    = AsyncValueSetter<void Function(String, [AsyncCallback?])>;

class AnalyzeFileViewModel {
  const AnalyzeFileViewModel({
    required this.errorText,
    required this.onOpenEmailAppTap,
  });

  final String? errorText;
  final VoidCallback? onOpenEmailAppTap;
}
