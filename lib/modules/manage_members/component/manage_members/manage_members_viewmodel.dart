import 'package:flutter/widgets.dart';

import '../../../../data/models/deck.dart';
import '../../../../data/models/role.dart';

class ManageMembersViewModel {
  const ManageMembersViewModel({
    required this.deck,
    required this.userRole,
    required this.onBackTap,
  });

  final Deck deck;
  final Role userRole;

  final VoidCallback onBackTap;
}
