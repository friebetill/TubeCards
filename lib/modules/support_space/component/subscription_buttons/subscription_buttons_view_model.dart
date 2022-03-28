import 'package:flutter/foundation.dart';

class SubscriptionButtonsViewModel {
  const SubscriptionButtonsViewModel({
    required this.hasSubscription,
    required this.onUnsubscribeTap,
  });

  final bool hasSubscription;

  final VoidCallback onUnsubscribeTap;
}
