import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../../../data/models/reminder.dart';
import '../../../../data/preferences/reminders.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../weekday.dart';
import 'reminder_tile_component.dart';
import 'reminder_tile_view_model.dart';

/// BLoC for the [ReminderTileComponent].
///
/// Exposes a [ReminderTileViewModel] for that component to use.
@injectable
class ReminderTileBloc with ComponentBuildContext {
  ReminderTileBloc(this._reminders);

  final Reminders _reminders;

  Stream<ReminderTileViewModel>? _viewModel;
  Stream<ReminderTileViewModel>? get viewModel => _viewModel;

  Stream<ReminderTileViewModel> createViewModel(int reminderId) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = _reminders.get().map((rs) {
      return rs.singleWhere((r) => r.id == reminderId);
    }).map((r) {
      return ReminderTileViewModel(
        reminder: r,
        onToggleReminder: (value) => _onToggleReminder(value, r),
        onWeeklyTimeEdit: () => _handleEditWeeklyTime(r),
        toggleWeekday: (w) => _toggleWeekday(w, r),
        deleteReminder: () => _deleteReminder(r),
      );
    });
  }

  void _onToggleReminder(bool value, Reminder reminder) {
    _reminders.upsert(reminder.copyWith(enabled: value));
  }

  Future<void> _handleEditWeeklyTime(Reminder reminder) async {
    final timeOfDay =
        await showTimePicker(context: context, initialTime: reminder.timeOfDay);

    if (timeOfDay == null) {
      return;
    }
    _reminders.upsert(reminder.copyWith(timeOfDay: timeOfDay));
  }

  Future<void> _toggleWeekday(Weekday weekday, Reminder reminder) async {
    // Optimistically show the new value to provide a more fluent user
    // experience.
    final weekdayStatusBuilder = reminder.weekdayStatus.toBuilder();
    weekdayStatusBuilder[weekday] = !reminder.weekdayStatus[weekday]!;
    _reminders
        .upsert(reminder.copyWith(weekdayStatus: weekdayStatusBuilder.build()));
  }

  void _deleteReminder(Reminder reminder) => _reminders.delete(reminder);
}
