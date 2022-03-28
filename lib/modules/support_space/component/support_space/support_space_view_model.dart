import 'package:flutter/foundation.dart';

class SupportSpaceViewModel {
  const SupportSpaceViewModel({
    required this.hasSubscriptions,
    required this.onPayPalButtonTap,
  });

  final bool hasSubscriptions;
  final VoidCallback onPayPalButtonTap;
}
