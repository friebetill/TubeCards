import 'package:flutter/material.dart';

import '../utils/logging/interaction_logger.dart';
import '../utils/logging/visual_element_ids.dart';

/// A visual element is an element of the UI.
///
/// Visual elements are used to log user interactions.
/// An example how to log a tap event:
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return VisualElement(
///     id: VEs.button,
///     childBuilder: (controller) {
///       return Button(
///         onPressed: () {
///           controller.logTap();
///           viewModel.onTap();
///         },
///       );
///     },
///   );
/// }
/// ```
class VisualElement extends StatelessWidget {
  VisualElement({required this.id, required this.childBuilder, Key? key})
      : controller = VisualElementController(id),
        super(key: key);

  final VEs id;
  final Widget Function(VisualElementController) childBuilder;
  final VisualElementController controller;

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return childBuilder(controller);
  }
}

class VisualElementController {
  VisualElementController(this.id);

  BuildContext? context;

  final VEs id;

  void logTap({Map<String, String>? eventProperties}) {
    InteractionLogger.getInstance().logTap(id, {
      ...?eventProperties,
      ...?_getCurrentRoute(),
    });
  }

  void logSecondaryTap({Map<String, String>? eventProperties}) {
    InteractionLogger.getInstance().logSecondaryTap(id, {
      ...?eventProperties,
      ...?_getCurrentRoute(),
    });
  }

  void logLongPress({Map<String, String>? eventProperties}) {
    InteractionLogger.getInstance().logLongPress(id, {
      ...?eventProperties,
      ...?_getCurrentRoute(),
    });
  }

  Map<String, String>? _getCurrentRoute() {
    if (context == null) {
      return null;
    }

    final route = ModalRoute.of(context!)?.settings.name;
    if (route == null) {
      return null;
    } else {
      return {'ROUTE': route};
    }
  }
}
