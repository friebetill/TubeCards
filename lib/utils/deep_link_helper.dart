import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uni_links/uni_links.dart';

/// Adds a wrapper around the uni_links library.
@singleton
class DeepLinkHelper {
  DeepLinkHelper() {
    _postInitialLink();
    if (Platform.isAndroid || Platform.isIOS) {
      _deepLinkStreamSubscription = linkStream.listen(deepLinks.add);
    }
  }

  late final StreamSubscription<String?> _deepLinkStreamSubscription;
  final BehaviorSubject<String?> deepLinks = BehaviorSubject();

  void clear() => deepLinks.add(null);

  Future<void> _postInitialLink() async {
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        final initialLink = await getInitialLink();
        if (initialLink != null) {
          deepLinks.add(initialLink);
        }
      } finally {
        // NO-OP
      }
    }
  }

  void dispose() {
    deepLinks.close();
    _deepLinkStreamSubscription.cancel();
  }
}
