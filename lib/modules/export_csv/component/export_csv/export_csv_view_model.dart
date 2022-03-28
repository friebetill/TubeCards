import 'package:flutter/foundation.dart';

class ExportCSVViewModel {
  const ExportCSVViewModel({
    required this.showEmailField,
    required this.isLoading,
    required this.emailErrorText,
    required this.onEmailChanged,
    required this.onExportTap,
    required this.onLinkTap,
    required this.onImageTap,
  });

  final bool showEmailField;
  final bool isLoading;
  final String? emailErrorText;

  final ValueChanged<String> onEmailChanged;
  final VoidCallback onExportTap;
  final Function(String, String?, String) onLinkTap;
  final ValueChanged<String> onImageTap;
}
