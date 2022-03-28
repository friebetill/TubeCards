class EventTypes {
  const EventTypes._(this._value);

  final String _value;

  // Gesture events
  static const gestureTap = EventTypes._('GESTURE_TAP');
  static const gestureSecondaryTap = EventTypes._('GESTURE_SECONDARY_TAP');
  static const gestureLongPress = EventTypes._('GESTURE_LONG_PRESS');
  static const gestureDrag = EventTypes._('GESTURE_DRAG');

  // Navigation events
  static const navigationPush = EventTypes._('NAVIGATION_PUSH');
  static const navigationReplace = EventTypes._('NAVIGATION_REPLACE');
  static const navigationPop = EventTypes._('NAVIGATION_POP');

  @override
  String toString() => _value;
}
