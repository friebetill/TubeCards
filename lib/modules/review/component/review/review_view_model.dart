import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../../data/models/confidence.dart';

class ReviewViewModel {
  ReviewViewModel({
    required this.frontText,
    required this.backText,
    required this.isFrontSide,
    required this.slideInOnToggle,
    required this.slideOutRightOnToggle,
    required this.slideOutLeftOnToggle,
    required this.triggerRightCardShift,
    required this.triggerLeftCardShift,
    required this.onFlipTap,
    required this.onCardLabeled,
    required this.onLeftDistanceCrossed,
    required this.onRighttDistanceCrossed,
    required this.emphasizeKnownCardLabelButton,
    required this.emphasizeNotKnownCardLabelButton,
  });

  /// Text of the front side of the card.
  final String? frontText;

  /// Text of the back side of the card.
  final String? backText;

  /// True when the front of the card is displayed and false for the back.
  final bool isFrontSide;

  final bool slideInOnToggle;
  final bool slideOutRightOnToggle;
  final bool slideOutLeftOnToggle;

  final VoidCallback triggerRightCardShift;
  final VoidCallback triggerLeftCardShift;

  final bool emphasizeKnownCardLabelButton;
  final bool emphasizeNotKnownCardLabelButton;

  final ValueSetter<bool> onLeftDistanceCrossed;
  final ValueSetter<bool> onRighttDistanceCrossed;

  /// The callback that is called when the card should be flipped.
  final VoidCallback onFlipTap;

  /// The callback that is called when the card is labeled.
  final ValueSetter<Confidence> onCardLabeled;
}
