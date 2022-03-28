import 'package:flutter/widgets.dart';

import 'breakpoints.dart';

// Form factor of devices.
enum FormFactor {
  // Phones
  small,
  // Tablets and above
  large,
}

FormFactor getFormFactor(BuildContext context) {
  // Use .shortestSide to detect device type regardless of orientation
  final deviceWidth = MediaQuery.of(context).size.shortestSide;

  return deviceWidth > Breakpoint.mobileToLarge
      ? FormFactor.large
      : FormFactor.small;
}
