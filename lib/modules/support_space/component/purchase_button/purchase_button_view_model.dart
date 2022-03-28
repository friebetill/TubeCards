import 'package:flutter/foundation.dart';

class PurchaseButtonViewModel {
  PurchaseButtonViewModel({
    required this.text,
    required this.onTap,
    required this.isLoading,
  });
  final String text;
  final bool isLoading;

  final VoidCallback onTap;
}
