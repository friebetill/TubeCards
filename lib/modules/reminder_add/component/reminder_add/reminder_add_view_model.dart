import 'package:flutter/foundation.dart';

import '../../../../data/models/reminder.dart';

class ReminderAddViewModel {
  ReminderAddViewModel({
    required this.reminder,
    required this.handleEditWeekdays,
    required this.handleEditTime,
    required this.handleDone,
  });

  final Reminder reminder;

  final VoidCallback handleEditWeekdays;
  final VoidCallback handleEditTime;
  final VoidCallback handleDone;
}
