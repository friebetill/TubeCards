import 'package:flutter/foundation.dart';

/// Sets the load state to true while [function] is executed.
Future<void> loadDuring(
  AsyncCallback function, {
  required ValueChanged<bool> setLoading,
}) async {
  setLoading(true);
  await function();
  setLoading(false);
}
