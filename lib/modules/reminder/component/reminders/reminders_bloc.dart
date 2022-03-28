import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../data/models/reminder.dart';
import '../../../../data/preferences/reminders.dart';
import 'reminders_component.dart';
import 'reminders_view_model.dart';

/// BLoC for the [RemindersComponent].
///
/// Exposes a [RemindersViewModel] for that component to use.
@injectable
class RemindersBloc {
  RemindersBloc(this._reminders);

  final Reminders _reminders;

  Stream<RemindersViewModel>? _viewModel;
  Stream<RemindersViewModel>? get viewModel => _viewModel;

  Stream<RemindersViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = _reminders
        .get()
        .map(sortReminders)
        .map((reminders) => RemindersViewModel(reminders: reminders));
  }

  List<Reminder> sortReminders(List<Reminder> reminders) {
    return reminders
      ..sort((a, b) {
        final aMinutes = a.timeOfDay.hour * 60 + a.timeOfDay.minute;
        final bMinutes = b.timeOfDay.hour * 60 + b.timeOfDay.minute;

        return aMinutes - bMinutes;
      });
  }
}
