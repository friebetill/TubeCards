import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'component/reminders/reminders_component.dart';

/// The screen on which all set reminders can be configured and are displayed.
class RemindersPage extends StatelessWidget {
  const RemindersPage({Key? key}) : super(key: key);

  /// The name of the route to the [RemindersPage] screen.
  static const String routeName = '/preferences/reminders';

  @override
  Widget build(BuildContext context) => const RemindersComponent();
}
