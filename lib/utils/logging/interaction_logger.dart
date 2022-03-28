import 'dart:io';

import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/widgets.dart';

import '../../widgets/visual_element.dart';
import '../config.dart';
import 'custom_navigator_observer.dart';
import 'event_types.dart';
import 'visual_element_ids.dart';

/// A logger to log user interactions.
///
/// In most cases [VisualElement] should be used instead of this logger.
class InteractionLogger {
  /// Returns an singleton instance of [InteractionLogger].
  factory InteractionLogger.getInstance() =>
      _instance ??= InteractionLogger._();

  InteractionLogger._()
      // Amplitude only runs on Android and iOS, https://bit.ly/30JXCH1
      : _amplitude = Platform.isAndroid || Platform.isIOS
            ? Amplitude.getInstance()
            : null;

  static InteractionLogger? _instance;

  final Amplitude? _amplitude;

  void init() {
    _amplitude?.init(amplitudeKey);
    _amplitude?.trackingSessionEvents(true);
  }

  void setUserId(String userId) => _amplitude?.setUserId(userId);

  void logEvent(
    String eventType, {
    Map<String, String>? eventProperties,
    bool? outOfSession,
  }) {
    _amplitude?.logEvent(
      eventType,
      eventProperties: eventProperties,
      outOfSession: outOfSession,
    );
  }

  void logTap(VEs id, [Map<String, String>? eventProperties]) {
    _amplitude?.logEvent(
      'Tap on ${id.name}',
      eventProperties: {
        'id': id.name,
        'type': EventTypes.gestureTap.toString(),
        ...eventProperties ?? {},
      },
    );
  }

  void logSecondaryTap(VEs id, [Map<String, String>? eventProperties]) {
    _amplitude?.logEvent(
      'Secondary tap on ${id.name}',
      eventProperties: {
        'id': id.name,
        'type': EventTypes.gestureSecondaryTap.toString(),
        ...eventProperties ?? {},
      },
    );
  }

  void logLongPress(VEs id, [Map<String, String>? eventProperties]) {
    _amplitude?.logEvent(
      'Long press on ${id.name}',
      eventProperties: {
        'id': id.name,
        'type': EventTypes.gestureLongPress.toString(),
        ...eventProperties ?? {},
      },
    );
  }

  void logDrag(VEs id, [Map<String, String>? eventProperties]) {
    _amplitude?.logEvent(
      'Drag ${id.name}',
      eventProperties: {
        'id': id.name,
        'type': EventTypes.gestureDrag.toString(),
        ...eventProperties ?? {},
      },
    );
  }

  /// Logs user navigations
  ///
  /// This method should only be called from the [CustomNavigatorObserver]
  /// class.
  void logNavigation({
    required EventTypes type,
    required RouteSettings? from,
    required RouteSettings? to,
  }) {
    final fromText = from?.name != null ? 'from ${from!.name} ' : '';
    final toText = to?.name != null ? 'to ${to!.name}' : '';

    _amplitude?.logEvent(
      'Navigate $fromText$toText',
      eventProperties: {'type': type.toString()},
    );
  }
}
