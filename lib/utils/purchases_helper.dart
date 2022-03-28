import 'dart:io';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Identifies the user for purchases
///
/// If the user is already identified, an alias from the old account to the
/// new account will be created. This is useful when transferring an
/// anonymous account to a normal account, this will ensure that no purchases
/// from the anonymous account are lost.
Future<void> identifyForPurchases(String userId) async {
  if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
    return;
  }

  try {
    final oldUserId = await Purchases.appUserID;
    if (oldUserId != userId) {
      await Purchases.logIn(userId);
    }
  } on PlatformException catch (e, s) {
    // Not serious, as the user is identified again before the purchase
    Logger('PurchasesExtension')
        .fine('Exception during RevenueCats identification', e, s);
  }
}
