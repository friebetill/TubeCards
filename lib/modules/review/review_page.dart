import 'package:flutter/material.dart';

import 'component/review/review_component.dart';

/// The screen with which the user can review his cards.
class ReviewPage extends StatelessWidget {
  const ReviewPage({Key? key}) : super(key: key);

  /// The name of the route to the [ReviewPage].
  static const String routeName = '/review';

  @override
  Widget build(BuildContext context) => const ReviewComponent();
}
