import 'package:flutter/material.dart';

import '../../../utils/responsiveness/breakpoints.dart';

Widget buildResponsiveBackground({required Widget child}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          elevation: constraints.maxWidth < Breakpoint.mobileToLarge ? 0 : 6,
          borderRadius: BorderRadius.circular(10),
          child: child,
        ),
      );
    },
  );
}
