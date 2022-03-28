import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

/// An adapter that handles pitfalls when storing and retrieving JSON values.
///
/// The pitfalls are null errors when reading data and [TypeError]s during
/// deserialization. For [TypeError]s there is the callback [onTypeError] to
/// handle the error.
class SecureJsonPreferenceAdapter<T> extends PreferenceAdapter<T> {
  const SecureJsonPreferenceAdapter({
    required this.serializer,
    required this.deserializer,
    required this.onTypeError,
  });

  final Object Function(T) serializer;

  // ignore: avoid_annotating_with_dynamic
  final T Function(dynamic) deserializer;

  /// Is called when an [TypeError] is thrown during deserialization.
  final T Function(TypeError, StackTrace)? onTypeError;

  @override
  T? getValue(SharedPreferences preferences, String key) {
    try {
      final value = preferences.getString(key);
      if (value == null) {
        return null;
      }

      final decoded = jsonDecode(value);

      return deserializer(decoded);

      // ignore: avoid_catching_errors
    } on TypeError catch (e, s) {
      // This is necessary because the error can occur if the wrong data type
      // is read, for example with getString instead of getInt. The error cannot
      // be handled in advance because we do not know what data is stored.
      return onTypeError!(e, s);
    }
  }

  @override
  Future<bool> setValue(SharedPreferences preferences, String key, T value) {
    final serializedValue = serializer(value);

    return preferences.setString(key, jsonEncode(serializedValue));
  }
}
