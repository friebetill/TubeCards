import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../data/models/reminder.dart';
import '../../../../data/preferences/reminders.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import '../../../reminder/component/weekday_picker.dart';
import '../../../reminder/weekday.dart';
import 'reminder_add_component.dart';
import 'reminder_add_view_model.dart';

/// BLoC for the [ReminderAddComponent].
///
/// Exposes a [ReminderAddViewModel] for that component to use.
@injectable
class ReminderAddBloc with ComponentBuildContext, ComponentLifecycleListener {
  ReminderAddBloc(this._reminders);

  final Reminders _reminders;

  final reminder = BehaviorSubject.seeded(Reminder.initial());

  Stream<ReminderAddViewModel>? _viewModel;
  Stream<ReminderAddViewModel>? get viewModel => _viewModel;

  Stream<ReminderAddViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = reminder.map(_createCardViewModel);
  }

  ReminderAddViewModel _createCardViewModel(Reminder reminder) {
    return ReminderAddViewModel(
      reminder: reminder,
      handleEditWeekdays: _handleEditWeekdays,
      handleEditTime: _handleEditTime,
      handleDone: _handleDone,
    );
  }

  @override
  void dispose() {
    reminder.close();
    super.dispose();
  }

  Future<void> _handleEditTime() async {
    final timeOfDay = await showTimePicker(
      context: context,
      initialTime: reminder.value.timeOfDay,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (timeOfDay == null) {
      return;
    }

    reminder.add(reminder.value.copyWith(timeOfDay: timeOfDay));
  }

  Future<void> _handleEditWeekdays() async {
    final weekdayStatus = await showDialog<Map<Weekday, bool>>(
      context: context,
      builder: (context) =>
          WeekdayPicker(weekdayStates: reminder.value.weekdayStatus.toMap()),
    );
    if (weekdayStatus == null) {
      return;
    }

    reminder.add(reminder.value.copyWith(
      weekdayStatus: BuiltMap.from(weekdayStatus),
    ));
  }

  Future<void> _handleDone() async {
    final hasPermission = await _askForPermission();
    if (!hasPermission) {
      return _handleNoPermission();
    }

    _reminders.upsert(reminder.value);
    CustomNavigator.getInstance().pop();
  }

  Future<bool> _askForPermission() async {
    if (Platform.isMacOS) {
      return (await FlutterLocalNotificationsPlugin()
              .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true)) ??
          false;
    }

    // The package NotificationPermissions doesn't yet support macOS.
    switch (await NotificationPermissions.getNotificationPermissionStatus()) {
      // `Provisional` and `Unknown` occur only on iOS
      case PermissionStatus.provisional:
      case PermissionStatus.unknown:
        return (await FlutterLocalNotificationsPlugin()
                .resolvePlatformSpecificImplementation<
                    IOSFlutterLocalNotificationsPlugin>()
                ?.requestPermissions(alert: true, badge: true, sound: true)) ??
            false;
      case PermissionStatus.denied:
        return false;
      default:
    }

    return true;
  }

  void _handleNoPermission() {
    return ScaffoldMessenger.of(context).showErrorSnackBar(
      theme: Theme.of(context),
      text: S.of(context).noPermissionToShowNotifications,
      snackBarAction: Platform.isAndroid || Platform.isIOS
          ? SnackBarAction(
              label: S.of(context).openSettings,
              onPressed: AppSettings.openNotificationSettings,
            )
          : null,
    );
  }
}

extension TimeOfDayToString on TimeOfDay {
  String toReadableString() {
    String addLeadingZeroIfNeeded(int value) {
      if (value < 10) {
        return '0$value';
      }

      return value.toString();
    }

    final hourLabel = addLeadingZeroIfNeeded(hour);
    final minuteLabel = addLeadingZeroIfNeeded(minute);

    return '$hourLabel:$minuteLabel';
  }
}
