import 'package:flutter/foundation.dart';

import '../../../../data/models/reminder.dart';
import '../../weekday.dart';

class ReminderTileViewModel {
  ReminderTileViewModel({
    required this.reminder,
    required this.toggleWeekday,
    required this.onToggleReminder,
    required this.onWeeklyTimeEdit,
    required this.deleteReminder,
  });

  final Reminder reminder;
  final ValueChanged<bool> onToggleReminder;
  final ValueChanged<Weekday> toggleWeekday;
  final VoidCallback onWeeklyTimeEdit;
  final VoidCallback deleteReminder;
}
