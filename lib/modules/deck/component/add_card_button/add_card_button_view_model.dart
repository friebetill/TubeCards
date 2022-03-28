import 'package:flutter/foundation.dart';

class AddCardButtonViewModel {
  AddCardButtonViewModel({required this.buttonText, required this.onPressed});

  final String buttonText;
  final VoidCallback onPressed;
}
