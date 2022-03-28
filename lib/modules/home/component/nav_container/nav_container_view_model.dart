import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../data/models/user.dart';

class NavContainerViewModel {
  NavContainerViewModel({
    required this.user,
    required this.isLoading,
    required this.onAccountTap,
    required this.onAddDeckTap,
    required this.onSearchTap,
    required this.onSearchOfferTap,
    required this.onRefreshTap,
    required this.onImportTap,
    required this.onJoinDeckTap,
  });

  final User user;
  final bool isLoading;

  final VoidCallback onAccountTap;
  final VoidCallback onAddDeckTap;
  final VoidCallback onSearchTap;
  final VoidCallback onSearchOfferTap;
  final VoidCallback onRefreshTap;
  final VoidCallback onImportTap;
  final VoidCallback onJoinDeckTap;
}
