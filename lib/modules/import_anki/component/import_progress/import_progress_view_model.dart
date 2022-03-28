import 'package:flutter/foundation.dart';

import '../../../../utils/progress.dart';
import '../../../../widgets/import/progress_state.dart';

class ImportProgressViewModel {
  ImportProgressViewModel({
    required this.importState,
    required this.importProgress,
    required this.remainingTime,
    required this.onCloseTap,
    required this.onOpenEmailAppTap,
  });

  final ProgressState importState;
  final Progress? importProgress;

  /// The estimated remaining time until the import is completed.
  ///
  /// If the value is null, the remaining time can't yet be calculated
  /// and a placeholder is displayed.
  final Duration? remainingTime;

  final VoidCallback onCloseTap;
  final VoidCallback onOpenEmailAppTap;
}
