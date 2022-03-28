import 'package:flutter/material.dart';

import 'component/reminder_add/reminder_add_component.dart';

/// The screen to add a new reminder.
class ReminderAddPage extends StatelessWidget {
  const ReminderAddPage({Key? key}) : super(key: key);

  /// The name of the route to the [ReminderAddPage].
  static const String routeName = '/preferences/reminder/add';

  @override
  Widget build(BuildContext context) => const ReminderAddComponent();
}
