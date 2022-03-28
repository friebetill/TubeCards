import 'package:flutter/foundation.dart';

class AccountDeletionViewModel {
  AccountDeletionViewModel({
    required this.isDeleting,
    required this.onKeepAccountTap,
    required this.onDeleteAccountTap,
  });

  bool isDeleting;

  final VoidCallback onKeepAccountTap;
  final VoidCallback onDeleteAccountTap;
}
