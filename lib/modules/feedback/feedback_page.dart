import 'package:flutter/material.dart';

import 'component/feedback/feedback_component.dart';

/// The screen where the user can send us feedback.
class FeedbackPage extends StatelessWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  /// The name of the route to the [Feedback] screen.
  static const String routeName = '/preferences/feedback';

  @override
  Widget build(BuildContext context) => const FeedbackComponent();
}
