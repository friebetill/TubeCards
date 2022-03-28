import 'package:flutter/foundation.dart';

import '../../../../data/models/card.dart';

class CardItemViewModel {
  CardItemViewModel({
    required this.card,
    required this.previewText,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onAvatarTap,
  });

  Card card;
  String previewText;
  bool isSelected;

  VoidCallback onTap;
  VoidCallback onLongPress;
  VoidCallback onAvatarTap;
}
